# FPC for HarmonyOS 

FPC 成熟的交叉编译机制为自行移植提供了清晰的路径。实现 arm-harmonyos 或 aarch64-harmonyos、x86_64-harmonyos 新目标，本质上是创建一个新的编译器后端，其核心工作是适配 FPC 的运行时库（RTL）以兼容 HarmonyOS 的系统接口。

技术路径 ：
FPC 对 Android/linux (t_android.pas/t_linux.pas) 的成熟支持是 HarmonyOS 适配的最佳参考模板。
    系统调用与 C 库依赖 ：参考linux、android的处理。
    链接器与程序初始化 ：为 HarmonyOS 定义正确的动态链接器路径（如 /system/bin/linker64），并集成 HarmonyOS NDK 中的链接器 (aarch64-linux-ohos-ld)。
    此外，程序的入口点（sysinit）、异常处理（Signal Handling）和线程局部存储（TLS）等机制也需根据 HarmonyOS 规范进行重新实现。

---

## 第一部分：FPC 编译器修改

### 1.1 链接器脚本 — `compiler/systems/t_harmonyos.pas`

#### 1.1.1 添加 `INSERT AFTER .data`（解决 TEXTREL）

将数据段放在 `.data` 之后（可写段），避免 `R_X86_64_64` 重定位在只读段中产生 TEXTREL：

**修改位置**：`WriteResponseFile` 方法中的 SECTIONS 块

```pascal
// 修改前
add('SECTIONS');
add('{');
add('  . = ALIGN(8);');
add('  fpc_n_version_start = .;');
add('  KEEP (*(.fpc.n_version))');
...
add('}');

// 修改后
add('SECTIONS');
add('{');
add('  .fpcdata           :');
add('  {');
add('    KEEP (*(.fpc .fpc.n_version .fpc.n_links .fpc.n_resources))');
add('    *(.rodata.n_FPC_*)');
add('  }');
add('  .threadvar : { *(.threadvar .threadvar.* .gnu.linkonce.tv.*) }');
add('}');
add('INSERT AFTER .data;');
```

#### 1.1.2 添加 PROVIDE 符号

```pascal
// 在 INSERT AFTER .data; 之后添加
add('PROVIDE (FPC_LIB_MAIN_HARMONYOS = PASCALMAIN);');
```

#### 1.1.3 修复 `opts` 变量类型截断

`opts` 变量在 `DoLink` 方法中声明为 `string`，在 FPC 编译器源码中是 `ShortString`（最大 255 字符）。当 `-k` 参数过多时被截断，导致链接器找不到 Qt 库。

```pascal
// 修改前
var
  i: longint;
  binstr, cmdstr: TCmdStr;
  s, opts, outname: string;     // string = ShortString (max 255)

// 修改后
var
  i: longint;
  binstr, cmdstr: TCmdStr;
  s, opts, outname: TCmdStr;    // TCmdStr = AnsiString (unlimited)
```

### 1.2 段类型变更（消除 R_X86_64_64 重定位）

将以下文件中的 `sec_rodata` → `sec_data`，使带重定位的数据区从只读段移到可读写段：

#### 1.2.1 `compiler/aasmdef.pas`

间接符号 `$indirect` 的数据段：

```pascal
// 修改前
sec_rodata,
lower(symind.name),

// 修改后
sec_data,
lower(symind.name),
```

#### 1.2.2 `compiler/ngenutil.pas`

`FPC_RESOURCESTRINGTABLES` 和 `FPC_RESLOCATION` 段：

```pascal
// 修改前
tabledef,sec_rodata,'FPC_RESOURCESTRINGTABLES',...
sec_rodata,'FPC_RESLOCATION',

// 修改后
tabledef,sec_data,'FPC_RESOURCESTRINGTABLES',...
sec_data,'FPC_RESLOCATION',
```

单元名数据段：

```pascal
// 修改前
sec_rodata,'',unitnametcb,unitnamelbl);

// 修改后
sec_data,'',unitnametcb,unitnamelbl);
```

#### 1.2.3 `compiler/ncgrtti.pas`（9 处）

全部 RTTI 类型信息数据段：

```pascal
// 所有 sec_rodata → sec_data
// 例如：
tcb.start_internal_data_builder(..., sec_data, '', ...);
tbltcb.get_final_asmlist(tbllab, tbldef, sec_data, ...);
argtcb.get_final_asmlist(arglab, argdef, sec_data, ...);
rttilab, tabledef, sec_data, ...;
tcb.get_final_asmlist(rttilab, rttidef, sec_data, ...);
```

#### 1.2.4 `compiler/ncgvmt.pas`（13 处）

全部 VMT 虚方法表数据段（使用 replaceAll `sec_rodata` → `sec_data`）

#### 1.2.5 `compiler/aasmcnst.pas`

间接符号 `$indirect` 创建的段落（`finalize_asmlist_add_indirect_sym`）：

```pascal
// 修改前
if section=sec_rodata then
  indsecname:=secname
else
  indsecname:=lower(symind.name);
...
sec_rodata,

// 修改后
indsecname:=lower(symind.name);
...
sec_data,
```

#### 1.2.6 `compiler/ngtcon.pas`（2 处）

类型常量段选择：

```pascal
// 修改前（2 处）
if (fsym.varspez=vs_const) and not (vo_force_finalize in fsym.varoptions) then
  sec:=sec_rodata
else
  sec:=sec_data;

// 修改后
sec:=sec_data;
```

---

## 第二部分：RTL 修改

### 2.1 `rtl/unix/cthreads.pp`

#### 2.1.1 `pthread_cancel` 不支持（OHOS musl 不导出）

```pascal
// 修改前
function CKillThread(threadHandle: TThreadID): dword;
begin
  pthread_detach(pthread_t(threadHandle));
  {$ifndef android}
  CKillThread := pthread_cancel(pthread_t(threadHandle));
  {$else}
  CKillThread := dword(-1);
  {$endif}
end;

// 修改后
function CKillThread(threadHandle: TThreadID): dword;
begin
  pthread_detach(pthread_t(threadHandle));
  {$if defined(android) or defined(ohos)}
  CKillThread := dword(-1);
  {$else}
  CKillThread := pthread_cancel(pthread_t(threadHandle));
  {$endif}
end;
```

#### 2.1.2 提前初始化 TLS 键（防止线程变量递归）

```pascal
// modification 段末尾添加
initialization
  if ThreadingAlreadyUsed then
    begin
      writeln('Threading has been used before cthreads was initialized.');
      writeln('Make cthreads one of the first units in your uses clause.');
      runerror(211);
    end;
  SetCThreadManager;
  { Initialize TLS early to avoid recursion in CRelocateThreadvar
    during unit initialization }
  if not TLSInitialized then
    InitCTLS;
finalization
```

### 2.3 `rtl/linux/pthread.inc`（4 处）

所有 `{$ifndef ANDROID}` 改为 `{$if not defined(ANDROID) and not defined(ohos)}`：

1. 静态外部函数声明（约第 167 行）
2. 动态加载函数指针变量（约第 250 行）
3. `dlsym` 加载调用（约第 346 行）
4. `pthread_atfork` 相关（约第 356 行）

---

## 第三部分：包（Packages）修改

### 3.1 `fpcsrc/packages/fcl-image/src/fpcolorspace.pas`

移除初始化段的 `FPGammaSet()` 调用（数组越界问题），改为懒初始化：

```pascal
// 修改前
initialization
   FPGammaSet();
   PrepareReferenceWhiteArray;
   FPReferenceWhite :=FPReferenceWhite2D50;

// 修改后
initialization
   { Gamma table is initialized lazily on first use.
     Do NOT call FPGammaSet() here as it may cause FPU issues
     during library startup on some platforms (e.g. HarmonyOS). }
   PrepareReferenceWhiteArray;
   FPReferenceWhite :=FPReferenceWhite2D50;
```

添加懒初始化保护：

```pascal
function FPGammaGet: single;
begin
  if FPGammaExpFactor = 0 then
    FPGammaSet;
  result := FPGammaExpFactor;
end;
```

---



## 附录：修改文件清单

| 文件                                      | 修改内容                                                     |
| ----------------------------------------- | ------------------------------------------------------------ |
| `compiler/systems/t_harmonyos.pas`        | SECTIONS INSERT AFTER .data, PROVIDE, opts:TCmdStr, 移除 -z notext |
| `compiler/aasmdef.pas`                    | sec_rodata→sec_data (间接符号)                               |
| `compiler/ngenutil.pas`                   | sec_rodata→sec_data (3处)                                    |
| `compiler/ncgrtti.pas`                    | sec_rodata→sec_data (9处)                                    |
| `compiler/ncgvmt.pas`                     | sec_rodata→sec_data (13处)                                   |
| `compiler/aasmcnst.pas`                   | sec_rodata→sec_data (间接符号)                               |
| `compiler/ngtcon.pas`                     | sec_rodata→sec_data (2处)                                    |
| `rtl/unix/cthreads.pp`                    | pthread_cancel OHOS 处理 + InitCTLS 提前初始化               |
| `rtl/linux/pthread.inc`                   | pthread_cancel 类型判断加入 ohos (4处)                       |
| `packages/fcl-image/src/fpcolorspace.pas` | 移除 initialization 中 FPGammaSet 调用                       |