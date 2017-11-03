REM Get the path where the files are located
SET mypath=%~dp0
echo %mypath:~0,-1%

REM Replace "\" with "\\" so that the path can be read by R
setlocal ENABLEDELAYEDEXPANSION
set word=\\
set str=%mypath%
# set str=%str:\=!word!%
echo %str%

mpm.exe --repository='%str%' --install=framed
mpm.exe --repository='%str%' --install=babel-portuges
mpm.exe --repository='%str%' --install=url
mpm.exe --repository='%str%' --install=upquote
