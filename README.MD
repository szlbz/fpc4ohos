# FPC for HarmonyOS 

| 路径 | 说明 |
|------|------|
| fpc | 已支持鸿蒙OS Target的fpcmake及ppcx64 |
| fpc331| FPC3.3.1 patchs |
| lazarus | Lazarus IDE 编译配置 |
| LazarusOHOS_Wrapper | 鸿蒙调用QT工程，该QT工程负责调用Lazarus编译的.so（Wrapper） |
| Lazarus_QT_Project | Lazarus Build to HarmonyOS 的示例工程 |
| OHOS_HAP_Project | 鸿蒙HAP工程，该工程执行 Wrapper 调用 Lazarus 工程 |

---

先通过 fpcupdeluxe 安装 fpc 3.3.1 

将本项目 fpc 目录下的内容，复制到 fpcupdeluxe\fpc 目录替换原文件

将本项目 fpc331 目录下的patchs内容，复制到 fpcupdeluxe\fpcsrc 目录替换原文件

进入 fpcsrc 目录执行 build.bat ，构建 FPC 及 RTL

---

通过 fpcupdeluxe 安装 lazarus (版本可选stable)

按照本项目 lazarus 目录下的 README.MD 说明，为 Lazarus 增加 OHOS 鸿蒙系统编译选项

---

通过 NATIVE_OHOS_SDK 编译出 libLazarusOHOS_Wrapper.so

通过 Lazarus 编译出 libLazarus_QT_Project.so

复制编译出的2个.so到 OHOS_HAP_Project\entry\libs\\{osTarget}\ 目录(如x86_64)下。

---
