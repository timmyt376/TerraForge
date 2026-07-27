"""
TerraForge Launcher v1.01 — Minecraft-style menu with world management & settings
"""

import tkinter as tk
from tkinter import ttk, font as tkfont, messagebox
import subprocess, os, json, random, glob
import urllib.request, threading

VERSION = "2.0"

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LUANTI_DIR = os.path.join(BASE_DIR, "luanti-5.10.0-win64", "bin")
LUANTI_EXE = os.path.join(LUANTI_DIR, "luanti.exe")
LUANTI_ROOT = os.path.join(BASE_DIR, "luanti-5.10.0-win64")
WORLDS_DIR = os.path.join(LUANTI_ROOT, "worlds")
CONFIG_FILE = os.path.join(BASE_DIR, "terraforge_config.json")

# Color palette
C_BG = "#0d0d1a"
C_BG2 = "#1a1a2e"
C_BG3 = "#252540"
C_ACCENT = "#4a9eff"
C_GREEN = "#2d5a27"
C_GREEN_H = "#3d7a37"
C_RED = "#5a2727"
C_RED_H = "#7a3737"
C_GREY = "#3d3d3d"
C_GREY_H = "#555555"
C_TEXT = "#ffffff"
C_TEXT_DIM = "#aabbcc"
C_TEXT_DARK = "#556677"
C_GOLD = "#ffaa00"


class TerraForgeLauncher:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title(f"TerraForge Launcher v{VERSION}")
        self.root.configure(bg=C_BG)
        self.root.protocol("WM_DELETE_WINDOW", self._quit)

        win_w, win_h = 854, 520
        sw = self.root.winfo_screenwidth()
        sh = self.root.winfo_screenheight()
        self.root.geometry(f"{win_w}x{win_h}+{(sw-win_w)//2}+{(sh-win_h)//2}")
        self.root.resizable(False, False)

        self.config = self._load_config()
        self.worlds_cache = []
        self.update_available = None
        self.update_check_done = False

        # Ensure worlds directory exists
        os.makedirs(WORLDS_DIR, exist_ok=True)

        self._build_ui()
        self._show_screen("main")
        self._check_for_updates_async()

    def _load_config(self):
        defaults = {
            "username": "Player",
            "window_mode": "fullscreen",
            "sound_volume": 80,
            "render_distance": 12,
            "fov": 75,
            "last_world": "",
        }
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE) as f:
                    return {**defaults, **json.load(f)}
            except: pass
        return defaults

    def _save_config(self):
        with open(CONFIG_FILE, "w") as f:
            json.dump(self.config, f, indent=2)

    def _scan_worlds(self):
        """Scan for existing Luanti worlds and return list of world info dicts."""
        worlds = []
        if not os.path.exists(WORLDS_DIR):
            os.makedirs(WORLDS_DIR, exist_ok=True)
            return worlds

        for d in sorted(os.listdir(WORLDS_DIR)):
            wdir = os.path.join(WORLDS_DIR, d)
            if not os.path.isdir(wdir):
                continue
            wmt = os.path.join(wdir, "world.mt")
            gameid = "terraforge"
            if os.path.exists(wmt):
                with open(wmt) as f:
                    for line in f:
                        if line.startswith("gameid"):
                            gameid = line.split("=", 1)[1].strip()
            # Count map.sqlite or map.db
            map_files = glob.glob(os.path.join(wdir, "map.*"))
            size = sum(os.path.getsize(f) for f in map_files) if map_files else 0
            worlds.append({
                "name": d,
                "path": wdir,
                "gameid": gameid,
                "size": size,
                "players": "1",
            })
        return worlds

    def _create_world(self, name, seed="", gamemode="survival"):
        """Create a new world directory with world.mt."""
        wdir = os.path.join(WORLDS_DIR, name)
        if os.path.exists(wdir):
            return False, f"World '{name}' already exists!"
        os.makedirs(wdir, exist_ok=True)
        with open(os.path.join(wdir, "world.mt"), "w") as f:
            f.write(f"gameid = terraforge\n")
            f.write(f"backend = sqlite3\n")
            f.write(f"player_backend = sqlite3\n")
            f.write(f"auth_backend = sqlite3\n")
            if seed:
                f.write(f"seed = {seed}\n")
            if gamemode == "creative":
                f.write(f"creative_mode = true\n")
                f.write(f"enable_damage = false\n")
            else:
                f.write(f"creative_mode = false\n")
                f.write(f"enable_damage = true\n")
        return True, wdir

    def _launch_game(self, world_name):
        """Launch Luanti with the given world."""
        wdir = os.path.join(WORLDS_DIR, world_name)
        if not os.path.exists(wdir):
            # Create default world
            success, result = self._create_world(world_name)
            if not success:
                messagebox.showerror("Error", result)
                return
            wdir = result

        if not os.path.exists(LUANTI_EXE):
            messagebox.showerror("Error", f"luanti.exe not found at:\n{LUANTI_EXE}")
            return

        # Build Luanti config args
        args = [LUANTI_EXE, "--gameid", "terraforge", "--world", wdir, "--go",
                "--name", self.config["username"]]

        if self.config["window_mode"] == "fullscreen":
            args.append("--fullscreen")

        self._set_buttons_enabled(False)
        self._show_loading_screen(world_name)

        try:
            # Create a watcher batch: launches game, reopens launcher on exit
            watcher = os.path.join(BASE_DIR, ".launch_watcher.bat")
            launcher_bat = os.path.join(BASE_DIR, "start_terraforge.bat")
            args_str = f'--gameid terraforge --world "{wdir}" --go --name "{self.config["username"]}"'
            if self.config["window_mode"] == "fullscreen":
                args_str += " --fullscreen"
            with open(watcher, "w") as f:
                f.write(f'''@echo off
cd /d "{LUANTI_DIR}"
start /wait "" luanti.exe {args_str}
start "" "{launcher_bat}"
del "%~f0"
''')
            self.config["last_world"] = world_name
            self._save_config()
            self.root.after(1500, lambda: self._close_and_launch(watcher))
        except Exception as e:
            messagebox.showerror("Launch Error", str(e))
            self._set_buttons_enabled(True)
            self._show_screen("singleplayer")

    # ─── UI BUILDING ───────────────────────────────────

    def _build_ui(self):
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)

        # Main container
        self.container = tk.Frame(self.root, bg=C_BG)
        self.container.grid(row=0, column=0, sticky="nsew")

        # Prebuild all screens
        self.screens = {}
        self._build_main_menu()
        self._build_singleplayer()
        self._build_settings()

    def _clear_container(self):
        for w in self.container.winfo_children():
            w.destroy()

    def _show_screen(self, name):
        self._clear_container()
        self._status_text = None
        self._current_screen = name
        if name in self.screens:
            self.screens[name]()

    # ─── SHARED WIDGETS ────────────────────────────────

    def _draw_starfield(self, canvas, w, h):
        random.seed(42)
        for _ in range(100):
            sx = random.randint(0, w)
            sy = random.randint(0, h)
            b = random.randint(80, 200)
            sz = random.choice([1, 1, 1, 2])
            canvas.create_oval(sx, sy, sx+sz, sy+sz,
                               fill=f"#{b:02x}{b:02x}{b:02x}", outline="")

    def _draw_gradient(self, canvas, w, h):
        for y in range(h):
            r = int(13 + (y/h)*15)
            g = int(13 + (y/h)*12)
            b = int(26 + (y/h)*10)
            canvas.create_line(0, y, w, y, fill=f"#{r:02x}{g:02x}{b:02x}")

    def _make_button(self, canvas, text, cmd, x, y, w, h, color, hover_c, font_size=12):
        rect = canvas.create_rectangle(x, y, x+w, y+h, fill=color,
                                       outline="#555566", width=1)
        txt = canvas.create_text(x+w//2, y+h//2, text=text, fill=C_TEXT,
                                 font=("Segoe UI", font_size, "bold"))

        def on_enter(_):
            canvas.itemconfig(rect, fill=hover_c)
            canvas.config(cursor="hand2")
        def on_leave(_):
            canvas.itemconfig(rect, fill=color)
            canvas.config(cursor="")
        def on_click(_):
            cmd()

        for tag in (rect, txt):
            canvas.tag_bind(tag, "<Enter>", on_enter)
            canvas.tag_bind(tag, "<Leave>", on_leave)
            canvas.tag_bind(tag, "<Button-1>", on_click)
        return rect, txt

    def _show_status(self, text):
        if self._status_text:
            self.canvas.delete(self._status_text)
        if text:
            self._status_text = self.canvas.create_text(
                430, 370, text=text, fill="#88ff88",
                font=("Segoe UI", 11, "italic"))
        return self._status_text

    def _set_buttons_enabled(self, enabled):
        self._btns_enabled = enabled

    # ─── MAIN MENU ─────────────────────────────────────

    def _build_main_menu(self):
        def show():
            self.canvas = tk.Canvas(self.container, width=854, height=520,
                                    highlightthickness=0, bg=C_BG)
            self.canvas.pack(fill="both", expand=True)
            self._draw_gradient(self.canvas, 854, 520)
            self._draw_starfield(self.canvas, 854, 520)

            # Title
            self.canvas.create_text(432, 82, text="MINELIKE", fill="#1a1a1a",
                                    font=("Courier New", 52, "bold"), anchor="center")
            self.canvas.create_text(430, 80, text="MINELIKE", fill=C_ACCENT,
                                    font=("Courier New", 52, "bold"), anchor="center")
            self.canvas.create_text(430, 125, text="~ Open Minecraft-like Game ~",
                                    fill=C_TEXT_DIM, font=("Segoe UI", 11, "italic"),
                                    anchor="center")
            self.canvas.create_text(430, 148, text="v1.01 — Luanti Engine",
                                    fill=C_TEXT_DARK, font=("Segoe UI", 9), anchor="center")

            # Buttons
            bx, bw = (854-280)//2, 280
            buttons = [
                ("▶  Singleplayer", self._show_screen_sp, C_GREEN, C_GREEN_H),
                ("🌐  Multiplayer", self._show_popup_sp, C_GREY, C_GREY_H),
                ("⚙  Settings", self._show_screen_st, C_GREY, C_GREY_H),
                ("📦  Mods", self._show_popup_mods, C_GREY, C_GREY_H),
                ("⬆  Check Updates", self._show_update_dialog, C_GREY, C_GREY_H),
                ("✕  Quit", self._quit, C_RED, C_RED_H),
            ]
            for i, (text, cmd, c, hc) in enumerate(buttons):
                self._make_button(self.canvas, text, cmd, bx, 195+i*52, bw, 42, c, hc)

            self.canvas.create_text(430, 505, text="github.com/solis/mineline",
                                    fill=C_TEXT_DARK, font=("Segoe UI", 8), anchor="center")
        self.screens["main"] = show

    def _show_popup_sp(self):
        self._popup("Multiplayer", "Multiplayer coming in v2.0!\n\nLuanti supports servers natively.\nServer browser and friends list in progress.")

    def _show_popup_mods(self):
        self._popup("Mod Support", "Mod System — Coming in v2.0\n\n✨ Bedrock addon (.mcpack) loader\n✨ Java mod bridge (Fabric/Forge)\n✨ Lua script API\n✨ Built-in mod browser")

    # ─── SINGLEPLAYER SCREEN ───────────────────────────

    def _build_singleplayer(self):
        def show():
            self.canvas = tk.Canvas(self.container, width=854, height=520,
                                    highlightthickness=0, bg=C_BG)
            self.canvas.pack(fill="both", expand=True)
            self._draw_gradient(self.canvas, 854, 520)
            self._draw_starfield(self.canvas, 854, 520)

            # Header
            self._make_button(self.canvas, "← Back", lambda: self._show_screen("main"),
                              20, 15, 70, 32, C_GREY, C_GREY_H, 10)
            self.canvas.create_text(430, 35, text="Singleplayer",
                                    fill=C_ACCENT, font=("Segoe UI", 20, "bold"),
                                    anchor="center")

            # World list frame (embedded in canvas)
            self.world_frame = tk.Frame(self.canvas, bg=C_BG2, highlightthickness=0)
            self.canvas.create_window(430, 180, window=self.world_frame,
                                      anchor="center", width=600, height=280)

            self._refresh_world_list()

            # Create New button
            self._make_button(self.canvas, "+  Create New World",
                              self._show_create_world_screen,
                              277, 340, 300, 40, C_GREEN, C_GREEN_H, 12)

        self.screens["singleplayer"] = show

    def _refresh_world_list(self):
        for w in self.world_frame.winfo_children():
            w.destroy()
        self.worlds_cache = self._scan_worlds()

        if not self.worlds_cache:
            tk.Label(self.world_frame, text="No worlds yet. Create one!",
                     fg=C_TEXT_DIM, bg=C_BG2,
                     font=("Segoe UI", 12)).pack(pady=100)
            return

        for world in self.worlds_cache:
            f = tk.Frame(self.world_frame, bg=C_BG3, highlightbackground="#334",
                         highlightthickness=1, padx=12, pady=6)
            f.pack(fill="x", padx=10, pady=4)

            name_label = tk.Label(f, text=world["name"], fg=C_TEXT, bg=C_BG3,
                                  font=("Segoe UI", 13, "bold"), anchor="w")
            name_label.pack(side="left", fill="x", expand=True)

            size_str = f"{world['size']/1024:.0f} KB" if world['size'] else "New"
            info = tk.Label(f, text=size_str, fg=C_TEXT_DIM, bg=C_BG3,
                            font=("Segoe UI", 9))
            info.pack(side="right", padx=(5,5))

            play_btn = tk.Button(f, text="▶ Play", command=lambda n=world["name"]: self._launch_game(n),
                                 bg=C_GREEN, fg="white", font=("Segoe UI", 10, "bold"),
                                 activebackground=C_GREEN_H, relief="flat",
                                 padx=15, pady=2, cursor="hand2")
            play_btn.pack(side="right", padx=(5,0))

    # ─── CREATE WORLD SCREEN ────────────────────────

    def _show_create_world_screen(self):
        """Embedded Create World screen in the main window."""
        self._clear_container()
        self.canvas = tk.Canvas(self.container, width=854, height=520,
                                highlightthickness=0, bg=C_BG)
        self.canvas.pack(fill="both", expand=True)
        self._draw_gradient(self.canvas, 854, 520)
        self._draw_starfield(self.canvas, 854, 520)

        # Back button
        self._make_button(self.canvas, "← Back",
                          lambda: self._show_screen("singleplayer"),
                          20, 15, 70, 32, C_GREY, C_GREY_H, 10)

        # Title
        self.canvas.create_text(430, 65, text="Create New World",
                                fill=C_ACCENT, font=("Segoe UI", 22, "bold"),
                                anchor="center")

        # Form frame embedded on canvas
        form = tk.Frame(self.canvas, bg=C_BG2, highlightbackground="#334",
                        highlightthickness=1)
        self.canvas.create_window(430, 250, window=form, anchor="center",
                                  width=450, height=300)

        # World Name
        tk.Label(form, text="World Name:", fg=C_TEXT_DIM, bg=C_BG2,
                 font=("Segoe UI", 12)).grid(row=0, column=0, sticky="w",
                                             padx=(30,10), pady=(25,5))
        name_var = tk.StringVar(value="New World")
        name_entry = tk.Entry(form, textvariable=name_var, bg=C_BG3, fg=C_TEXT,
                              font=("Segoe UI", 12), insertbackground=C_TEXT,
                              relief="flat", bd=3, width=30)
        name_entry.grid(row=0, column=1, sticky="ew", padx=(0,30), pady=(25,5))

        # Seed
        tk.Label(form, text="Seed (optional):", fg=C_TEXT_DIM, bg=C_BG2,
                 font=("Segoe UI", 12)).grid(row=1, column=0, sticky="w",
                                             padx=(30,10), pady=5)
        seed_var = tk.StringVar()
        seed_entry = tk.Entry(form, textvariable=seed_var, bg=C_BG3, fg=C_TEXT,
                              font=("Segoe UI", 12), insertbackground=C_TEXT,
                              relief="flat", bd=3, width=30)
        seed_entry.grid(row=1, column=1, sticky="ew", padx=(0,30), pady=5)

        # Game Mode
        tk.Label(form, text="Game Mode:", fg=C_TEXT_DIM, bg=C_BG2,
                 font=("Segoe UI", 12)).grid(row=2, column=0, sticky="w",
                                             padx=(30,10), pady=5)
        mode_var = tk.StringVar(value="survival")
        mode_frame = tk.Frame(form, bg=C_BG2)
        mode_frame.grid(row=2, column=1, sticky="w", padx=(0,30), pady=5)

        for mode, label in [("survival", "Survival"), ("creative", "Creative")]:
            rb = tk.Radiobutton(mode_frame, text=label, variable=mode_var,
                                value=mode, bg=C_BG2, fg=C_TEXT, selectcolor=C_BG3,
                                activebackground=C_BG2, activeforeground=C_ACCENT,
                                font=("Segoe UI", 11), cursor="hand2")
            rb.pack(side="left", padx=(0,20))

        # Buttons row
        btn_y = 330
        self._make_button(self.canvas, "Cancel",
                          lambda: self._show_screen("singleplayer"),
                          277, btn_y, 130, 38, C_RED, C_RED_H, 12)

        def create():
            name = name_var.get().strip()
            if not name:
                self._show_status_msg("Please enter a world name.")
                return
            seed = seed_var.get().strip()
            success, result = self._create_world(name, seed, mode_var.get())
            if not success:
                self._show_status_msg(result)
                return
            self._refresh_world_list()
            self._launch_game(name)

        def create_only():
            """Create but don't play."""
            name = name_var.get().strip()
            if not name:
                self._show_status_msg("Please enter a world name.")
                return
            seed = seed_var.get().strip()
            success, result = self._create_world(name, seed, mode_var.get())
            if not success:
                self._show_status_msg(result)
                return
            self._show_screen("singleplayer")

        self._make_button(self.canvas, "Create", create_only,
                          417, btn_y, 130, 38, C_GREY, C_GREY_H, 12)
        self._make_button(self.canvas, "Create & Play", create,
                          277, btn_y + 48, 270, 38, C_GREEN, C_GREEN_H, 12)

    def _show_status_msg(self, msg):
        """Show a temporary status message on the current canvas."""
        self.canvas.delete("status_msg")
        self.canvas.create_text(430, 480, text=msg, fill=C_GOLD,
                                font=("Segoe UI", 11), anchor="center",
                                tags="status_msg")
        self.root.after(3000, lambda: self.canvas.delete("status_msg"))

    # ─── SETTINGS SCREEN ───────────────────────────────

    def _build_settings(self):
        def show():
            self.canvas = tk.Canvas(self.container, width=854, height=520,
                                    highlightthickness=0, bg=C_BG)
            self.canvas.pack(fill="both", expand=True)
            self._draw_gradient(self.canvas, 854, 520)
            self._draw_starfield(self.canvas, 854, 520)

            # Header
            self._make_button(self.canvas, "← Back", lambda: self._show_screen("main"),
                              20, 15, 70, 32, C_GREY, C_GREY_H, 10)
            self.canvas.create_text(430, 35, text="Settings",
                                    fill=C_ACCENT, font=("Segoe UI", 20, "bold"),
                                    anchor="center")

            # Settings form embedded in canvas
            sf = tk.Frame(self.canvas, bg=C_BG2, highlightbackground="#334",
                          highlightthickness=1)
            self.canvas.create_window(430, 255, window=sf, anchor="center",
                                      width=550, height=280)

            row = 0

            # Username
            tk.Label(sf, text="Player Name:", fg=C_TEXT_DIM, bg=C_BG2,
                     font=("Segoe UI", 11)).grid(row=row, column=0, sticky="w",
                                                  padx=(20,10), pady=8)
            name_var = tk.StringVar(value=self.config["username"])
            name_entry = tk.Entry(sf, textvariable=name_var, bg=C_BG3, fg=C_TEXT,
                                  font=("Segoe UI", 11), insertbackground=C_TEXT,
                                  relief="flat", bd=3, width=25)
            name_entry.grid(row=row, column=1, sticky="ew", padx=(0,20), pady=8)
            row += 1

            # Window mode
            tk.Label(sf, text="Window Mode:", fg=C_TEXT_DIM, bg=C_BG2,
                     font=("Segoe UI", 11)).grid(row=row, column=0, sticky="w",
                                                  padx=(20,10), pady=8)
            win_var = tk.StringVar(value=self.config["window_mode"])
            win_combo = ttk.Combobox(sf, textvariable=win_var, state="readonly",
                                     values=["fullscreen", "windowed", "borderless"],
                                     font=("Segoe UI", 11), width=22)
            win_combo.grid(row=row, column=1, sticky="ew", padx=(0,20), pady=8)
            row += 1

            # Volume
            tk.Label(sf, text="Sound Volume:", fg=C_TEXT_DIM, bg=C_BG2,
                     font=("Segoe UI", 11)).grid(row=row, column=0, sticky="w",
                                                  padx=(20,10), pady=8)
            vol_var = tk.IntVar(value=self.config["sound_volume"])
            vol_scale = tk.Scale(sf, from_=0, to=100, orient="horizontal",
                                 variable=vol_var, bg=C_BG2, fg=C_TEXT,
                                 activebackground=C_ACCENT, highlightthickness=0,
                                 troughcolor=C_BG3, sliderlength=20, length=220)
            vol_scale.grid(row=row, column=1, sticky="ew", padx=(0,20), pady=8)
            row += 1

            # Render Distance
            tk.Label(sf, text="Render Distance:", fg=C_TEXT_DIM, bg=C_BG2,
                     font=("Segoe UI", 11)).grid(row=row, column=0, sticky="w",
                                                  padx=(20,10), pady=8)
            rd_var = tk.IntVar(value=self.config["render_distance"])
            rd_scale = tk.Scale(sf, from_=6, to=32, orient="horizontal",
                                variable=rd_var, bg=C_BG2, fg=C_TEXT,
                                activebackground=C_ACCENT, highlightthickness=0,
                                troughcolor=C_BG3, sliderlength=20, length=220)
            rd_scale.grid(row=row, column=1, sticky="ew", padx=(0,20), pady=8)
            row += 1

            # FOV
            tk.Label(sf, text="Field of View:", fg=C_TEXT_DIM, bg=C_BG2,
                     font=("Segoe UI", 11)).grid(row=row, column=0, sticky="w",
                                                  padx=(20,10), pady=8)
            fov_var = tk.IntVar(value=self.config["fov"])
            fov_scale = tk.Scale(sf, from_=50, to=120, orient="horizontal",
                                 variable=fov_var, bg=C_BG2, fg=C_TEXT,
                                 activebackground=C_ACCENT, highlightthickness=0,
                                 troughcolor=C_BG3, sliderlength=20, length=220)
            fov_scale.grid(row=row, column=1, sticky="ew", padx=(0,20), pady=8)
            row += 1

            # Save button (below the form on the canvas)
            def save_settings():
                self.config["username"] = name_var.get().strip() or "Player"
                self.config["window_mode"] = win_var.get()
                self.config["sound_volume"] = vol_var.get()
                self.config["render_distance"] = rd_var.get()
                self.config["fov"] = fov_var.get()
                self._save_config()
                self._popup("Saved", "Settings saved successfully!\nRestart the game to apply changes.")

            self._make_button(self.canvas, "💾  Save Settings", save_settings,
                              327, 400, 200, 38, C_GREEN, C_GREEN_H, 12)

            # Reset button
            def reset_settings():
                self.config = self._load_config()  # We need to reload defaults
                defaults = {
                    "username": "Player", "window_mode": "fullscreen",
                    "sound_volume": 80, "render_distance": 12, "fov": 75,
                    "last_world": "",
                }
                self.config = defaults
                self._save_config()
                self._popup("Reset", "Settings reset to defaults.")
                self._show_screen("settings")

            self._make_button(self.canvas, "↺ Reset", reset_settings,
                              327, 445, 200, 32, C_GREY, C_GREY_H, 10)

        self.screens["settings"] = show

    # ─── HELPERS ───────────────────────────────────────

    def _show_screen_sp(self):
        self._show_screen("singleplayer")

    def _show_screen_st(self):
        self._show_screen("settings")

    def _popup(self, title, message):
        msg = tk.Toplevel(self.root)
        msg.title(title)
        msg.configure(bg=C_BG2)
        msg.geometry("400x280")
        x = self.root.winfo_x() + 227
        y = self.root.winfo_y() + 120
        msg.geometry(f"+{x}+{y}")
        tk.Label(msg, text=title, fg=C_ACCENT, bg=C_BG2,
                 font=("Segoe UI", 16, "bold")).pack(pady=(25, 15))
        tk.Label(msg, text=message, fg=C_TEXT_DIM, bg=C_BG2,
                 font=("Segoe UI", 11), justify="center").pack(pady=10)
        tk.Button(msg, text="OK", command=msg.destroy, bg=C_GREEN, fg="white",
                  font=("Segoe UI", 11, "bold"), activebackground=C_GREEN_H,
                  relief="flat", padx=30, pady=5, cursor="hand2").pack(pady=20)
        msg.transient(self.root)
        msg.grab_set()

    def _quit(self):
        self._save_config()
        self.root.destroy()

    # ─── LOADING SCREEN ─────────────────────────────

    def _show_loading_screen(self, world_name):
        """Show a full loading overlay when launching a world."""
        self._clear_container()
        self.canvas = tk.Canvas(self.container, width=854, height=520,
                                highlightthickness=0, bg=C_BG)
        self.canvas.pack(fill="both", expand=True)

        # Dark gradient
        for y in range(520):
            r = int(13 + (y / 520) * 10)
            g = int(13 + (y / 520) * 8)
            b = int(26 + (y / 520) * 8)
            self.canvas.create_line(0, y, 854, y, fill=f"#{r:02x}{g:02x}{b:02x}")

        # Loading text
        self.canvas.create_text(430, 180, text="LOADING",
                                fill=C_ACCENT, font=("Courier New", 36, "bold"),
                                anchor="center")

        # World name
        self.canvas.create_text(430, 225, text=f'"{world_name}"',
                                fill=C_TEXT_DIM, font=("Segoe UI", 14, "italic"),
                                anchor="center")

        # Animated dots
        self._loading_dots = 0
        self._loading_world = world_name
        self._animate_loading()

    def _animate_loading(self):
        """Animate loading dots."""
        if not hasattr(self, '_loading_dots'):
            return
        self._loading_dots = (self._loading_dots % 4) + 1
        dots = "." * self._loading_dots

        self.canvas.delete("loading_dots")
        self.canvas.create_text(430, 270,
                                text=f"Launching{dots}",
                                fill=C_TEXT_DIM, font=("Segoe UI", 12),
                                anchor="center", tags="loading_dots")

        self.canvas.delete("loading_hint")
        self.canvas.create_text(430, 320,
                                text="TerraForge will launch in a moment",
                                fill=C_TEXT_DARK, font=("Segoe UI", 10),
                                anchor="center", tags="loading_hint")
        self._loading_job = self.root.after(500, self._animate_loading)

    def _close_and_launch(self, watcher_path):
        """Close launcher and launch game via watcher batch that reopens launcher on exit."""
        if os.path.exists(watcher_path):
            subprocess.Popen([watcher_path], shell=True, cwd=BASE_DIR)
        self._save_config()
        self.root.destroy()

    # ─── AUTO UPDATE ──────────────────────────────────

    UPDATE_CHECK_URL = "https://raw.githubusercontent.com/timmyt376/TerraForge/main/launcher_version.txt"
    UPDATE_DL_URL = "https://github.com/timmyt376/TerraForge/archive/refs/tags/v{}.zip"

    def _check_for_updates_async(self):
        """Check GitHub for newer version in a background thread."""
        def check():
            try:
                req = urllib.request.Request(
                    self.UPDATE_CHECK_URL,
                    headers={"User-Agent": f"TerraForgeLauncher/{VERSION}"}
                )
                with urllib.request.urlopen(req, timeout=5) as resp:
                    remote_version = resp.read().decode().strip()
                self.update_available = remote_version
                self.update_check_done = True
                is_newer = self._version_compare(remote_version, VERSION)
                if is_newer:
                    self.root.after(0, self._show_update_notification)
            except Exception:
                self.update_check_done = True

        threading.Thread(target=check, daemon=True).start()

    def _version_compare(self, v1, v2):
        """Compare version strings. Returns True if v1 > v2."""
        try:
            p1 = [int(x) for x in v1.replace("v", "").split(".")]
            p2 = [int(x) for x in v2.replace("v", "").split(".")]
            return p1 > p2
        except:
            return False

    def _show_update_notification(self):
        """Show update badge on main menu if update available."""
        if self.update_available and self._current_screen == "main":
            self.canvas.create_text(
                750, 15, text="⬆ UPDATE", fill=C_GOLD,
                font=("Segoe UI", 9, "bold"), anchor="ne"
            )

    def _show_update_dialog(self):
        """Show update dialog with download option."""
        if not self.update_available:
            self._popup("Check Updates",
                        f"TerraForge v{VERSION}\n\nYou're on the latest version!")
            return

        ver = self.update_available
        dialog = tk.Toplevel(self.root)
        dialog.title("Update Available")
        dialog.configure(bg=C_BG2)
        dialog.geometry("450x300")
        x = self.root.winfo_x() + 202
        y = self.root.winfo_y() + 110
        dialog.geometry(f"+{x}+{y}")

        tk.Label(dialog, text="⬆  Update Available", fg=C_GOLD, bg=C_BG2,
                 font=("Segoe UI", 16, "bold")).pack(pady=(20, 10))

        tk.Label(dialog, text=f"v{VERSION}  →  v{ver}", fg=C_ACCENT, bg=C_BG2,
                 font=("Segoe UI", 14)).pack(pady=5)

        tk.Label(dialog, text=f"New version {ver} is ready to download.",
                 fg=C_TEXT_DIM, bg=C_BG2, font=("Segoe UI", 11)).pack(pady=5)

        tk.Label(dialog, text="The launcher will restart after updating.",
                 fg=C_TEXT_DARK, bg=C_BG2, font=("Segoe UI", 10, "italic")).pack(pady=5)

        # Progress bar (hidden initially)
        self._update_progress = tk.ttk.Progressbar(
            dialog, mode="indeterminate", length=300
        )
        self._update_status = tk.Label(dialog, text="", fg=C_TEXT_DIM, bg=C_BG2,
                                        font=("Segoe UI", 10))

        btn_frame = tk.Frame(dialog, bg=C_BG2)
        btn_frame.pack(pady=15)

        def start_update():
            for w in btn_frame.winfo_children():
                w.config(state="disabled")
            self._update_progress.pack(pady=10)
            self._update_status.pack()
            self._update_status.config(text="Downloading update...")
            self._update_progress.start(10)
            dialog.update()
            threading.Thread(target=lambda: self._download_and_install(ver, dialog),
                             daemon=True).start()

        tk.Button(btn_frame, text="Later", command=dialog.destroy,
                  bg=C_RED, fg="white", font=("Segoe UI", 11, "bold"),
                  activebackground=C_RED_H, relief="flat", padx=20, pady=4,
                  cursor="hand2").pack(side="left", padx=10)

        tk.Button(btn_frame, text="⬇  Download & Install", command=start_update,
                  bg=C_GREEN, fg="white", font=("Segoe UI", 11, "bold"),
                  activebackground=C_GREEN_H, relief="flat", padx=20, pady=4,
                  cursor="hand2").pack(side="left", padx=10)

        dialog.transient(self.root)
        dialog.grab_set()

    def _download_and_install(self, version, dialog):
        """Download update zip and install it."""
        import zipfile
        dl_url = self.UPDATE_DL_URL.format(version)
        tmp_dir = os.path.join(BASE_DIR, ".update_temp")
        zip_path = os.path.join(tmp_dir, f"update_{version}.zip")

        try:
            os.makedirs(tmp_dir, exist_ok=True)

            # Download
            self.root.after(0, lambda: self._update_status.config(
                text=f"Downloading v{version}..."))
            req = urllib.request.Request(dl_url, headers={
                "User-Agent": f"TerraForgeLauncher/{VERSION}"})
            with urllib.request.urlopen(req, timeout=60) as resp:
                total = int(resp.headers.get("Content-Length", 0))
                downloaded = 0
                chunk_size = 65536
                with open(zip_path, "wb") as f:
                    while True:
                        chunk = resp.read(chunk_size)
                        if not chunk:
                            break
                        f.write(chunk)
                        downloaded += len(chunk)
                        if total > 0:
                            pct = int(downloaded * 100 / total)
                            if pct % 10 == 0:
                                self.root.after(0, lambda p=pct: self._update_status.config(
                                    text=f"Downloading... {p}%"))

            # Extract
            self.root.after(0, lambda: self._update_status.config(
                text="Installing update..."))
            extract_dir = os.path.join(tmp_dir, "extracted")
            with zipfile.ZipFile(zip_path, "r") as zf:
                # The zip contains a root folder like TerraForge-main/
                members = zf.namelist()
                # Find the root folder name
                root_folder = members[0].split("/")[0] + "/"
                for m in members:
                    rel = m[len(root_folder):] if m.startswith(root_folder) else m
                    if not rel:
                        continue
                    target = os.path.join(BASE_DIR, rel)
                    if m.endswith("/"):
                        os.makedirs(target, exist_ok=True)
                    else:
                        os.makedirs(os.path.dirname(target), exist_ok=True)
                        with open(target, "wb") as f:
                            f.write(zf.read(m))

            # Write updated version file
            with open(os.path.join(BASE_DIR, "launcher_version.txt"), "w") as f:
                f.write(version + "\n")

            self.root.after(0, lambda: self._update_status.config(
                text="Update installed! Restarting..."))

            # Create restart script
            restart_bat = os.path.join(tmp_dir, "restart_launcher.bat")
            launcher_path = os.path.join(BASE_DIR, "start_terraforge.bat")
            with open(restart_bat, "w") as f:
                f.write(f"""@echo off
timeout /t 2 /nobreak >nul
start "" "{launcher_path}"
del "%~f0"
""")

            self.root.after(500, lambda: [
                dialog.destroy(),
                self.root.destroy(),
                subprocess.Popen([restart_bat], shell=True, cwd=tmp_dir)
            ])

        except Exception as e:
            self.root.after(0, lambda: self._update_status.config(
                text=f"Update failed: {str(e)[:50]}"))
            self.root.after(0, lambda: self._update_progress.stop())
            # Cleanup
            import shutil
            shutil.rmtree(tmp_dir, ignore_errors=True)

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    TerraForgeLauncher().run()
