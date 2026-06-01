# Lazarus to HarmonyOS 

### 1. 修改IDE文件

| 文件 | 修改 |
|------|------|
| `components/codetools/definetemplates.pas` | `FPCOperatingSystemNames` 和 `FPCOperatingSystemCaptions` 数组从 39 扩展到 40，添加 `'ohos'` / `'OHOS'` |
| `components/codetools/definetemplates.pas` | `GetDefaultSrcOSForTargetOS` 添加 `ohos` → 返回 `'unix'`（OHOS 基于 Linux 内核） |
| `ide/buildlazdialog.pas` | "Build Lazarus" 对话框的 OS 列表 TargetOSComboBox 中添加 `'OHOS'` |

components、ide 目录下为lazarus4.6的ide已修改好的文件。其他版本ide参考上表自行修改即可。

### 2. 修改fpc.cfg

编辑fpc\bin\x86_64-Win64\fpc.cfg，在文件末添加：
```
#IFDEF cpuamd64 
#IFDEF ohos 
-FlF:/Huawei/DevEcoStudio/sdk/default/openharmony/native/sysroot/usr/lib/x86_64-linux-ohos 
-Cg 
-k-LF:/Huawei/DevEcoStudio/sdk/default/openharmony/native/sysroot/usr/lib 
-k--sysroot=F:/Huawei/DevEcoStudio/sdk/default/openharmony/native/sysroot 
#ENDIF 
#ENDIF 
```

以上只包括了x86_64的配置，其他CPU参考以上内容添加。

### 3. 编译LCL(for OHOS)

进入 lazarus 目录执行：

```
lazbuild.exe -B --os=ohos --cpu=x86_64 --ws=qt5 --opt="-Sg -Sc -fPIC -Cg -Ur -dOHOS -dLCLQt5 -dQt5" ".\lcl\interfaces\lcl.lpk"
```

### 效果

重新编译 Lazarus IDE 后：

1. **项目选项 → 编译选项 → 目标和平台**：`目标操作系统(-T)` 下拉列表中会出现 **OHOS**

2. **工具 → 配置构建 Lazarus**：操作系统列表中会出现 **OHOS**

3. 选择 **OHOS** 后，Lazarus 会传递 `-Tohos` 给 FPC 编译器，配合已安装的 x86_64-ohos 交叉编译器即可进行交叉编译。

