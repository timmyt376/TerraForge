@echo off
REM TerraForge Launcher - Opens the Minecraft-style menu
cd /d "%~dp0"
echo Starting TerraForge Launcher...

REM Try python3, then python, then py
python3 launcher.py 2>nul
if errorlevel 1 (
    python launcher.py 2>nul
    if errorlevel 1 (
        py launcher.py
    )
)

echo Launcher closed.
