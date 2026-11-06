@echo off
setlocal
pushd "%~dp0.."
set "ROJO_TOOL=%USERPROFILE%\.aftman\bin\rojo.exe"
if not exist "%ROJO_TOOL%" set "ROJO_TOOL=rojo"
"%ROJO_TOOL%" serve default.project.json
set "SERVE_RESULT=%ERRORLEVEL%"
popd
exit /b %SERVE_RESULT%
