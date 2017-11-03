REM Get the path where the files are located
SET mypath=%~dp0
echo %mypath:~0,-1%

REM Replace "\" with "\\" so that the path can be read by R
setlocal ENABLEDELAYEDEXPANSION
set word=\\
set str=%mypath%
# set str=%str:\=!word!%
echo %str%
for /r "%str%" %%a in (*.msi) do msiexec.exe /i "%%~fa"
