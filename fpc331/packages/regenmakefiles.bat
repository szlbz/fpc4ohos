@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    set "PACKAGEDIR=%cd%"
) else (
    set "PACKAGEDIR=%~1"
)

if not exist "%PACKAGEDIR%" (
    echo The directory %PACKAGEDIR% does not exist
    pause
    exit /b 1
)

if not exist "%PACKAGEDIR%\build\Makefile.pkg" (
    echo This script must be executed in the rtl directory or have an argument to specify the package directory
    echo not exist %PACKAGEDIR%\build\Makefile.pkg
    pause
    exit /b 1
)

if exist "%PACKAGEDIR%\..\utils\fpcm\fpcmake.exe" (
    set "FPCMAKE=%PACKAGEDIR%\..\utils\fpcm\fpcmake.exe"
) else (
    set "FPCMAKE=fpcmake.exe"
)

cd /d "%PACKAGEDIR%"
echo Makefile...
%FPCMAKE% -q -Tall

echo build/Makefile.pkg...
%FPCMAKE% -Tall -q -o Makefile.pkg "%PACKAGEDIR%\build\Makefile.fpc"

echo 正在移除 FCL 包冲突行...
if exist "%PACKAGEDIR%\build\Makefile.pkg" (
    :: 用批处理原生方式删除含 PACKAGE_NAME=fcl 的行，不需要安装 sed
    findstr /v /c:"PACKAGE_NAME=fcl" "%PACKAGEDIR%\build\Makefile.pkg" > "%PACKAGEDIR%\build\tmp_file"
    move /y "%PACKAGEDIR%\build\tmp_file" "%PACKAGEDIR%\build\Makefile.pkg" >nul
)

echo fpmkunit Makefile...
if exist "%PACKAGEDIR%\fpmkunit\Makefile.fpc" (
    %FPCMAKE% -Tall -q "%PACKAGEDIR%\fpmkunit\Makefile.fpc"
)

echo.
echo ok
echo.

exit /b 0