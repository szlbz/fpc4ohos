**获取 DevEco 项目模板**

在以下地址获取最新的用于构建最终 OpenHarmony  Qt 应用程序的 DevEco 项目模板。这将用于在 HarmonyOS 设备上运行 Qt 应用程序。

获取最新模版: http://codereview.qtcompany.cn:29416/template/

将 DevEco 项目模板放入已知位置<deveco-project>。

**复制 Qt 库文件**

转到文件夹<deveco-project> \entry 并创建子文件夹 \entry\libs\x86_64

将  libQt5Pas.so 
	libqohos.so 
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