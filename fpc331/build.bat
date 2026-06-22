rem 以下修改为你的路径
SET FPCBASE=D:\lazarus4.6_fpc331
SET OHOS_ARCH=x86_64
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

REM Only x86_64, aarch64
REM 符号链接：需要管理员权限运行
del "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-*.*" 
mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-clang.exe" "%LLVMDIR%\bin\clang.exe" 
@copy /y batchlauncher.exe "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-as.exe"
@echo "%LLVMDIR%\bin\clang.exe" -c -x assembler --target=%OHOS_ARCH%-linux-ohos --sysroot=%SYSROOT% -D__MUSL__ %%* > "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-as.bat"
mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-ld.exe"    "%LLVMDIR%\bin\ld.lld.exe" 
mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-ar.exe"    "%LLVMDIR%\bin\llvm-ar.exe"
mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-nm.exe"    "%LLVMDIR%\bin\llvm-nm.exe"
mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-objdump.exe" "%LLVMDIR%\bin\llvm-objdump.exe"  
mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-strip.exe" "%LLVMDIR%\bin\llvm-strip.exe"  

REM loongarch64(or riscv64, arm) 
REM mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-as.exe" "F:\loongarch-ohos-sdk\loongarch64-linux\loongarch64-unknown-linux-gnu-as.exe"
REM mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-ld.exe" "F:\loongarch-ohos-sdk\loongarch64-linux\loongarch64-unknown-linux-gnu-ld.exe"
REM mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-ar.exe"    "F:\loongarch-ohos-sdk\loongarch64-linux\loongarch64-unknown-linux-gnu-ar.exe"
REM mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-nm.exe"    "F:\loongarch-ohos-sdk\loongarch64-linux\loongarch64-unknown-linux-gnu-nm.exe"
REM mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-objdump.exe" "F:\loongarch-ohos-sdk\loongarch64-linux\loongarch64-unknown-linux-gnu-objdump.exe"  
REM mklink "%FPCBASE%\fpc\bin\x86_64-win64\%OHOS_ARCH%-ohos-strip.exe" "F:\loongarch-ohos-sdk\loongarch64-linux\loongarch64-unknown-linux-gnu-strip.exe" 

REM 构建交叉编译器
make compiler_cycle OS_TARGET=ohos CPU_TARGET=%OHOS_ARCH% FPC=ppcx64 CROSSINSTALL=1 OPT="-O- -fPIC -O2" CROSSOPT=" -O- -Sg -Cg -O2 -Ur -dohos -Fl%SYSROOT%/usr/lib -k--sysroot=%SYSROOT%" INSTALL_PREFIX=%FPCBASE%\fpc 
 
REM 编译交叉 FPC + OHOS RTL（win64 → ohos）：交叉编译器（ppcrossx64.exe） + 交叉 RTL（x86_64-ohos）
make crossinstall OS_TARGET=ohos CPU_TARGET=%OHOS_ARCH% OPT="-O- -fPIC -O2" CROSSOPT=" -O- -Sg -Cg -O2 -Ur -dohos -Fl%SYSROOT%/usr/lib -k--sysroot=%SYSROOT%" INSTALL_PREFIX=%FPCBASE%\fpc 