# Lazarus to HarmonyOS 

### 1. 修改fpc.cfg

编辑fpc\bin\x86_64-Win64\fpc.cfg，为 ohos 编译添加 Qt 库：
```
#IFDEF cpuamd64 
#IFDEF ohos 
-XPllvm- 
-FDD:\fpcupdeluxe34_new/fpc/bin/x86_64-win64 
-FlF:\Huawei\Qt-5.12.12-ohos-x86\lib 
-FlF:/Huawei/DevEcoStudio/sdk/default/openharmony/native/sysroot/usr/lib/x86_64-linux-ohos 
-Cg 
-k-LF:/Huawei/DevEcoStudio/sdk/default/openharmony/native/sysroot/usr/lib 
-k-LF:\Huawei\Qt-5.12.12-ohos-x86\lib 
-k-lQt5Pas
-k-lQt5Core 
-k-lQt5Gui 
-k-lQt5Widgets
-k--sysroot=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native/sysroot 
#ENDIF 
#ENDIF 
```

以上示例为x86_64的配置，其他CPU参考以上内容添加。

### 3. 修改原LCL工程为 library

复制原lazarus的工程文件为libOHOS_QT_Lazarus.lpr，修改其内容为：

```pascal
library OHOS_QT_Lazarus;

{$mode objfpc}{$H+}
{$longstrings on}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Classes, forms, Interfaces, uMainForm;

procedure InitAndShowForm; cdecl; export;
begin
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainWin, MainWin);
  MainWin.Show;
  Application.Run;
end;

exports
  InitAndShowForm;

begin
end.
```

### 编译

1. **项目选项 → 编译选项 → 目标和平台**：

   `目标操作系统(-T)` 下拉列表中选择 **OHOS**

   `目标CPU架构(-P)` 下拉列表中选择 **x86_64**  或其他( aarch64、arm ... )

2. **项目选项 → 当前LCL控件集配(LCLWidgetType)**：必须选为 **qt5**

现在就可以按 Ctrl 或 Shift + F9 编译出库文件了。

手工编译指令示例：

```
ppcrossx64.exe -Tohos -Px86_64 -MObjFPC -Scghi -O2 -Sg -Cg -Ur -dohos -vewnhibq ^
  -Filib\x86_64-ohos ^
  -FUlib\x86_64-ohos -FE. ^
  -FuD:\fpcupdeluxe34_new\lazarus\lcl\units\x86_64-ohos\qt5 ^
  -FuD:\fpcupdeluxe34_new\lazarus\lcl\units\x86_64-ohos ^
  -FuD:\fpcupdeluxe34_new\lazarus\components\lazutils\lib\x86_64-ohos ^
  -olibOHOS_QT_Lazarus.so ^
  OHOS_QT_Lazarus.lpr 
```



