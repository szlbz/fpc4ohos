# Qt5 应用入口桥接库 

https://wiki.qt.io/Qt_for_HarmonyOS/zh

Qt for HarmonyOS 通过其 ohos-clang QPA 插件，将 Qt 的窗口系统与鸿蒙的 ArkUI 进行了深度适配，为上层应用提供了成熟的 UI 渲染与事件处理通道。

基于Qt for harmonyOS 让 Lazarus 的 LCL-Qt5 程序，通过 libQt5Pas.so（桥接库）也能间接调用 Qt5 的原生库（libQt5Widgets.dll 等）。

`libLazarusOHOS_Wrapper.so` 是一个 **C++ Qt 桥接库**，作用：

1. **创建 `C++ 的 main 接口`**（OHOS 只能调用C++接口，但Lazarus只能导出C接口，必须通过C++工程做Wrapper）
2. **加载并调用 C 接口的 Pascal 库**（`libOHOS_QT_Lazarus.so` 的 `InitAndShowForm`）
3. **运行 Qt 事件循环**（`application.run()`）

结构：
```
libLazarusOHOS_Wrapper.so (C++)
├── main()
│   └── InitAndShowForm()                 // 调用 Pascal 端创建/显示窗口，进入 Qt 事件循环
│
libOHOS_QT_Lazarus.so (Pascal/LCL)
    └── InitAndShowForm()
        ├── Application.Initialize        // 复用已存在的 QApplication
        ├── CreateForm + Show             // QPA 会介入并利用 HarmonyOS 的原生 API 来创建实际的窗口
        └── ProcessMessages 循环          // 事件处理
```

没有libLazarusOHOS_Wrapper.so，OHOS 上不能调用pascal的C接口，LCL Qt5 窗口无法显示。

---

执行下列指令编译libLazarusOHOS_Wrapper.so

```cmd
SET NATIVE_OHOS_SDK=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native
SET SYSROOT=%NATIVE_OHOS_SDK%/sysroot
SET QT5DIR=F:\Huawei\Qt-5.12.12-ohos-x86

%NATIVE_OHOS_SDK%/llvm/bin/clang++ -shared ^
  -o libLazarusOHOS_Wrapper.so ^
  -L"%SYSROOT%/usr/lib/x86_64-linux-ohos" ^
  -lc ^
  --sysroot="%SYSROOT%" -target x86_64-linux-ohos -fPIC ^
  libLazarusOHOS_Wrapper.cpp 
```

