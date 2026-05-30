
SET FPCBASE=D:\fpcupdeluxe34_new

SET NATIVE_OHOS_SDK=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native
SET LLVMDIR=%NATIVE_OHOS_SDK%/llvm
SET SYSROOT=%NATIVE_OHOS_SDK%/sysroot

set PATH=%FPCBASE%\fpc\bin\x86_64-win64;%PATH%
 
cd %FPCBASE%\fpcsrc
fpcmake.exe -Tall -w
cd compiler
fpcmake.exe -Tall -w
cd utils
fpcmake.exe -Tall -w
cd ..\..
cd packages
fpcmake.exe -Tall -w
cd build
fpcmake.exe -Tall -w
copy /y MakeFile MakeFile.pkg
cd ..
call regenmakefiles.bat
cd ..
cd utils
fpcmake.exe -Tall -w
cd build
fpcmake.exe -Tall -w
copy /y MakeFile MakeFile.pkg
cd ..\..
cd installer
fpcmake.exe -Tall -w
cd ..
cd rtl
fpcmake.exe -Tall -w
cd ohos
fpcmake.exe -Tall -w
cd..
call regenmakefiles.bat
cd..

REM 编译原生 FPC：原生编译器（ppcx64.exe） + 原生 RTL（x86_64-win64）
make clean all install INSTALL_PREFIX=%FPCBASE%\fpc FPC=ppcx64

REM 符号链接：需要管理员权限运行
mklink "%FPCBASE%\fpc\bin\x86_64-win64\llvm-clang.exe" "%LLVMDIR%\bin\clang.exe"  
mklink "%FPCBASE%\fpc\bin\x86_64-win64\llvm-as.exe"    "%LLVMDIR%\bin\clang.exe"  
mklink "%FPCBASE%\fpc\bin\x86_64-win64\llvm-ld.exe"    "%LLVMDIR%\bin\ld.lld.exe" 
mklink "%FPCBASE%\fpc\bin\x86_64-win64\llvm-ar.exe"    "%LLVMDIR%\bin\llvm-ar.exe"
mklink "%FPCBASE%\fpc\bin\x86_64-win64\llvm-nm.exe"    "%LLVMDIR%\bin\llvm-nm.exe"
mklink "%FPCBASE%\fpc\bin\x86_64-win64\llvm-objdump.exe" "%LLVMDIR%\bin\llvm-objdump.exe"  
mklink "%FPCBASE%\fpc\bin\x86_64-win64\llvm-strip.exe" "%LLVMDIR%\bin\llvm-strip.exe"  


REM 构建交叉编译器
make compiler_cycle OS_TARGET=ohos CPU_TARGET=aarch64 FPC=ppcx64 CROSSINSTALL=1 OPT="-O- -fPIC -O2" CROSSOPT=" -O- -Sg -Cg -O2 -Ur -dohos -Fl%SYSROOT%/usr/lib -k--sysroot=%SYSROOT%" INSTALL_PREFIX=%FPCBASE%\fpc AS="%LLVMDIR%/bin/clang.exe -c -x assembler --sysroot=%SYSROOT%" BINUTILSPREFIX=llvm-
 
REM 编译交叉 FPC + OHOS RTL（win64 → ohos）：交叉编译器（ppcrossx64.exe） + 交叉 RTL（x86_64-ohos）
make crossinstall OS_TARGET=ohos CPU_TARGET=aarch64 OPT="-O- -fPIC -O2" CROSSOPT=" -O- -Sg -Cg -O2 -Ur -dohos -Fl%SYSROOT%/usr/lib -k--sysroot=%SYSROOT%" INSTALL_PREFIX=%FPCBASE%\fpc AS="%LLVMDIR%/bin/clang.exe -c -x assembler --sysroot=%SYSROOT%" BINUTILSPREFIX=llvm-




