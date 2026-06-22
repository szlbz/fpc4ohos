# FPC for HarmonyOS 

| 路径 | 说明 |
|------|------|
| fpc | 已支持鸿蒙OS Target的fpcmake及ppcx64 |
| fpc331| FPC3.3.1 patchs |
| lazarus | Lazarus IDE 编译配置 |
| libQt5Pas | 编译适用于 HarmonyOS 的 Pascal-Qt 接口库libQt5Pas.so |
| Lazarus_QT_Project | Lazarus Build to HarmonyOS 的示例工程 |
| LazarusOHOS_Wrapper | 鸿蒙调用QT工程，该QT工程负责调用Lazarus编译的.so（Wrapper） |
| OHOS_HAP_Project | 鸿蒙HAP工程，该工程执行 Wrapper 调用 Lazarus 工程 |
| napilib | NAPI Lib 接口支持库（ArkTS） |

---

## fpc for harmonyOS

#### 前提

​	先在华为开发者官网下载安装 **`DevEco Studio`**(注意：安装时指定的安装路径中不要包括空格)

​	[DevEco Studio-鸿蒙应用集成开发环境（IDE）-华为开发者联盟](https://developer.huawei.com/consumer/cn/deveco-studio/)

#### 安装FPC：

​	先通过 fpcupdeluxe 安装 fpc 3.3.1 

​	将本项目 fpc 目录下的内容，复制到 fpcupdeluxe\fpc 目录替换原文件

​	将本项目 fpc331 目录下的patchs内容，复制到 fpcupdeluxe\fpcsrc 目录替换原文件

​	进入 fpcsrc 目录执行 build.bat ，构建 FPC 及 RTL

	注意：在windows下，这里让as.exe构建程序是由{ARCH}-ohos-as.exe去调用{ARCH}-ohos-as.bat，该bat内容最末尾应该是`%*`而不是`%%*`（单独执行build内命令时,有可能会错误的生成2个%%）

---

#### 安装Lazarus：

​	通过 fpcupdeluxe 安装 lazarus (版本可选stable)

​	按照本项目 lazarus 目录下的 README.MD 说明，为 Lazarus 增加 OHOS 鸿蒙系统编译选项

---

## lazarus build to harmonyOS

#### 前提

​	安装 **`Qt5.12.12`**   [qt.io/download](https://www.qt.io/download)

​	下载 **`Qt for HarmonyOS`**  [Qt5.12.12 Open Source Release for HarmonyOS zh - Qt Wiki](https://wiki.qt.io/Qt5.12.12_Open_Source_Release_for_HarmonyOS_zh)

安装参考：

​	[Qt for HarmonyOS zh - Qt Wiki](https://wiki.qt.io/Qt_for_HarmonyOS_zh)

​	[HarmonyOS鸿蒙PC的QT应用开发：(一、开发环境搭建)](https://blog.csdn.net/qq8864/article/details/159958545)

​	[HarmonyOS鸿蒙PC的QT应用开发：(二、第一个HelloWorld)](https://blog.csdn.net/qq8864/article/details/159968066)

编译出 HarmonyOS 版的 Qt-5.12.12-ohos-{cpuTarget} QT库。

```
注意：Qt for HarmonyOS分2个不同的版本：
商业版Qt的QPA插件为`libqohos.so`
开源版Qt的QPA插件为`libplugins_platforms_qopenharmony.so`
```

---

基于Qt for harmonyOS 编译出 libQt5Pas.so

通过 NATIVE_OHOS_SDK 编译出 libLazarusOHOS_Wrapper.so

通过 Lazarus 编译出 libLazarus_QT_Project.so

复制编译出的2个.so到 OHOS_HAP_Project\entry\libs\\{osTarget}\ 目录(如x86_64)下。

---

## FPC NAPI SUPPORT
FPC NAPI SUPPORT 是 Free Pascal 对 OpenHarmony NAPI 的完整适配层，使 Pascal 代码能编译为 ArkTS 可调用的原生 .so 模块。

napilib.pp	NAPI 接口绑定库，提供全部 C API 的 Pascal 声明（类型、枚举、函数）

使用流程：

fpc + napilib → libxxx.so → HAP → ArkTS import → 调用 Pascal 函数

只需在 Pascal 中定义 cdecl 回调函数，通过 RegisterNAPIMethod 注册，然后 napi_module_register 关联到导出入口。编译产物直接放入 HAP 的 libs/<abi>/ 目录即可被 ArkTS import。