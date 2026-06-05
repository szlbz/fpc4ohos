# 交叉编译 LibQt5Pas.so

复制 Qt5Pas.pro 文件到 lazarus\lcl\interfaces\qt5\cbindings 目录覆盖原文件。

执行构建指令：

Qt5.12.12-（ohos-Business）
```
SET NATIVE_OHOS_SDK=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native
SET OHOS_TARGET_ARCH=x86_64   # 或 aarch64 / arm ++> SET OHOS_TARGET_ARCH=arm64-v8a

set QT_OHOS_BIN=F:/Huawei/Qt-5.12.12-ohos-x86/bin
set TOOLCHAIN=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native/llvm/bin
set PATH=%QT_OHOS_BIN%;%TOOLCHAIN%;D:\Qt\Qt5.12.12\Tools\mingw730_64\bin;%PATH%

qmake.exe -o Makefile ..\cbindings\Qt5Pas.pro -spec ohos-clang "CONFIG+=qml_debug"

mingw32-make -j8
```

Qt5.15.12-（openharmony-Open）
```
SET NATIVE_OHOS_SDK=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native
SET OHOS_SDK_PATH=F:/Huawei/DevEcoStudio/sdk/default/openharmony
SET OHOS_TARGET_ARCH=x86_64   # 或 aarch64 / arm ++> SET OHOS_TARGET_ARCH=arm64-v8a

set QT_OHOS_BIN=F:/Huawei/Qt/Qt-5.15.12-ohos-x86_64/bin
set TOOLCHAIN=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native/llvm/bin
set PATH=%QT_OHOS_BIN%;%TOOLCHAIN%;D:\Qt\Qt5.12.12\Tools\mingw730_64\bin;%PATH%

%QT_OHOS_BIN%\qmake.exe -o Makefile ..\cbindings\Qt5Pas.pro -spec oh-clang "CONFIG+=qml_debug"

mingw32-make -j8
```