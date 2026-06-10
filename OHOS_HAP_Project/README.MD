## Qt5.12.12（ohos-Business）

**获取 DevEco 项目模板**

在以下地址获取最新的用于构建最终 OpenHarmony  Qt 应用程序的 DevEco 项目模板。这将用于在 HarmonyOS 设备上运行 Qt 应用程序。

获取最新模版: http://codereview.qtcompany.cn:29416/template/

将 DevEco 项目模板放入已知位置<deveco-project>。

**复制 Qt 库文件**

转到文件夹<deveco-project> \entry 并创建子文件夹 \entry\libs\x86_64

将  libQt5Pas.so 
	**libqohos.so** 
	libQt5Core.so 
	libQt5Gui.so 
	libQt5Network.so 
	libQt5PrintSupport.so 
	libQt5Widgets.so 
以及 libLazarusOHOS_Wrapper.so 	
还有lazarus编译出的 libOHOS_QT_Lazarus.so
复制到 <deveco-project>\entry\libs\x86_64 文件夹。

**修改 ets 中的初始加载**

打开文件 <deveco-project>\entry\src\main\ets\common\QtAppConstants.ets。将 APP_LIBRARY_NAME 变量更改为我们要使用的库的名称（libLazarusOHOS_Wrapper.so）：

**构建并运行应用程序**

确保设备已连接。连接后，它应该在 DevEco Studio 模拟器中可见。

---
---

## *Qt5.15.12（openharmony-Open）*

1.打开DevEco Studio，选择"Create Project"。

2.选择"Native C++"模板，创建好空工程。

3.拷贝QtSDK中openharmony/qtbase目录下的文件夹到DevEco工程中的 entry\src\main\ets 目录下覆盖。

	QtSDK(5.15.1x) 可在 https://gitcode.com/openharmony-sig/qt/releases 下载你需要的版本。

4.修改拷贝到 entry\src\main\ets\entryability 目录下的 EntryAbility.ets 文件，修改加载的.so库如下：

	private launchApplication = "libLazarusOHOS_Wrapper.so" //"libentry.so"

5.确保 entry\src\main\module.json5 文件中，EntryAbility 的 "launchType" 设置为 "specified"（指定实例模式，适用于多窗口）
