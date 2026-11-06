@echo off
setlocal
pushd "%~dp0.."
set "ROJO_TOOL=%USERPROFILE%\.aftman\bin\rojo.exe"
if not "%~1"=="" set "ROJO_TOOL=%~1"
if not exist "%ROJO_TOOL%" set "ROJO_TOOL=rojo"
if not exist build mkdir build
"%ROJO_TOOL%" sourcemap default.project.json --output sourcemap.json
if errorlevel 1 goto failed
"%ROJO_TOOL%" build default.project.json --output build/validation.rbxlx
if errorlevel 1 goto failed
echo PASS: Rojo mapping and place build. Check VS Code Problems and playtest in Studio.
popd
exit /b 0
:failed
echo FAILED: Check the error above. Ensure the pinned Rojo tool is installed.
popd
exit /b 1
