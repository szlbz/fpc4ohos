# FPC NAPI 支持



## 版本说明

所有函数声明取自 OHOS SDK 的  `js_native_api.h`, `node_api.h`, `node_api_types.h` 。

> NAPI_VERSION = 8 在所有 SDK 版本中一致。
> 提示：链接时需加上 `-lace_napi.z`（编译器在 `FPC_NAPI_SUPPORT` 开启时会自动处理，无需手动 `-k`）。



## RTL 包含范围

**编译器在 `FPC_NAPI_SUPPORT` 开启时自动添加 libace_napi.z.so 链接**

**所有 NAPI 函数不在 RTL 中**。推荐用 **`napilib.pp`** 统一导入，或逐一声明。



## NAPI LIB 接口库

**`napilib.pp`** 是 OpenHarmony NAPI 的 Free Pascal 接口绑定库。它提供全部 NAPI 函数的 Pascal 声明，配合 RTL 的 `FPC_NAPI_SUPPORT` 编译开关使 FPC 能编译出符合 NAPI 规范的 `.so` 原生模块。




## 选择 API Level

`napilib.pp` 通过编译开关选择目标 OHOS API Level，高级别自动包含低级别。

### 可用等级

| 开关 | 目标 SDK | 包含的函数范围 |
|------|---------|---------------|
| `FPC_NAPI_SUPPORT_12`（默认） | OpenHarmony 5.0.x / API 14 | 全部标准 NAPI + OHOS 扩展（sendable, serialize, event_loop, ark_runtime 等） |
| `FPC_NAPI_SUPPORT_18` | OpenHarmony 5.1.x / API 18 | +`napi_wrap_enhance` |
| `FPC_NAPI_SUPPORT_20` | OpenHarmony 6.0.x / API 20 | +ark_context 系列：`napi_create_ark_context`, `napi_switch_ark_context`, `napi_destroy_ark_context` |
| `FPC_NAPI_SUPPORT_21` | DevEco 最新 | +critical_scope、strong_reference |
| `FPC_NAPI_SUPPORT_22` | DevEco 最新 | +external_string、sendable_reference |
| `FPC_NAPI_SUPPORT_24` | DevEco 最新 | + callsite_info IC 缓存 |

### 编译命令

```bash
# 默认 API 12（兼容所有 SDK）
fpc -dFPC_NAPI_SUPPORT -Tohos mymodule.pp

# API 18
fpc -dFPC_NAPI_SUPPORT -dFPC_NAPI_SUPPORT_18 -Tohos mymodule.pp

# API 20（完整标准 NAPI）
fpc -dFPC_NAPI_SUPPORT -dFPC_NAPI_SUPPORT_20 -Tohos mymodule.pp

# API 24（DevEco 最新）
fpc -dFPC_NAPI_SUPPORT -dFPC_NAPI_SUPPORT_24 -Tohos mymodule.pp
```

编译参数 `-dFPC_NAPI_SUPPORT` 必须有，要支持指定版本再加 `-dFPC_NAPI_SUPPORT_xx` 。



## 导出给 ArkTS 使用的函数

**步骤1：定义回调函数**

引入 `napilib` 获得全部函数声明。

```pascal
unit myminimal;

{ AddNumbers 回调 — 所有 napi_callback 都是这个签名 }
function AddNumbers(env: napi_env; info: napi_callback_info): napi_value; cdecl;
var
  argv: array[0..1] of napi_value;
  argc: SizeUInt;
  status: napi_status;
  a, b, result: LongInt;
  result_val: napi_value;
begin
  argc := 2;
  status := napi_get_cb_info(env, info, @argc, @argv[0], nil, nil);
  status := napi_get_value_int32(env, argv[0], @a);
  status := napi_get_value_int32(env, argv[1], @b);

  result := a + b;
  status := napi_create_int32(env, result, @result_val);

  Result := result_val;
end;

{ Hello 回调 — 所有 napi_callback 都是这个签名 }
function MyHello(env: napi_env; info: napi_callback_info): napi_value; cdecl;
var
  result: napi_value;
begin
  napi_create_string_utf8(env, 'Hello OHOS!', 12, @result);
  MyHello := result;
end;

```


**步骤2：注册方法**

```pascal
{ 在 initialization 段注册 }
initialization
  RegisterNAPIMethod('AddNumbers', @AddNumbers);
  RegisterNAPIMethod('hello', @MyHello);
end.  
```

也可以在Library工程的 begin ... end. 内集中注册。


**步骤3：Library工程代码**

```pascal
library projectnapi1;

{$mode objfpc}{$H+}
{$define FPC_NAPI_SUPPORT_12}

uses napilib, myminimal;

var
  module: napi_module;
begin
  FillChar(module, SizeOf(module), 0);
  module.nm_version := 1;
  module.nm_register_func := CodePointer(@napi_register_module_v1); // 已在 napilib.pp 中定义
  module.nm_modname := 'projectnapi1';  // 更新为你的项目名称(和.so文件名（去lib和.so）一致)
  napi_module_register(@module);  // 将上述 RegisterNAPIMethod 模块注册到系统中
end.                                                    
```


---



## 完整示例

```pascal
library my_napi_module;

uses
  SysUtils, napilib;

function Sub(env: napi_env; info: napi_callback_info): napi_value; cdecl;
var
  argc: SizeUInt;
  argv: array[0..1] of napi_value;
  a, b: LongInt;
  result_val: napi_value;
begin
  argc := 2;
  napi_get_cb_info(env, info, @argc, @argv, nil, nil);
  if argc >= 2 then
    begin
      napi_get_value_int32(env, argv[0], @a);
      napi_get_value_int32(env, argv[1], @b);
      napi_create_int32(env, a - b, @result_val);
    end
  else
    napi_get_undefined(env, @result_val);
  Result := result_val;
end;

function CreatePerson(env: napi_env; info: napi_callback_info): napi_value; cdecl;
var
  name_val, age_val, obj: napi_value;
begin
  napi_create_object(env, @obj);
  napi_create_string_utf8(env, 'Alice', NAPI_AUTO_LENGTH, @name_val);
  napi_create_int32(env, 30, @age_val);
  napi_set_named_property(env, obj, 'name', name_val);
  napi_set_named_property(env, obj, 'age', age_val);
  Result := obj;
end;

var
  module: napi_module;
begin
  RegisterNAPIMethod('sub', @Sub);
  RegisterNAPIMethod('createPerson', @CreatePerson);

  FillChar(module, SizeOf(module), 0);
  module.nm_version := 1;
  module.nm_register_func := CodePointer(@napi_register_module_v1);
  module.nm_modname := 'my_napi_module';
  napi_module_register(@module);
end.
```

编译(注意 `-o` 输出的 `.so` 文件名**不要含 `.z` 等带.后缀**）：
```sh
fpc -dFPC_NAPI_SUPPORT -Tohos -Px86_64 -Cg -Fu. -k-lace_napi.z -FlF:\Huawei\DevEcoStudio\sdk\default\openharmony\native\sysroot\usr\lib\x86_64-linux-ohos -olibmy_napi_module.so my_napi_module.lpr 
```

## 在ArkTS侧引用三方so库

NAPI 模块项目结构：

```
mymodule/
├── 
└── entry/
    ├── libs/
    │    ├── x86_64/
    │         └── libmy_napi_module.so # pascal 编译产物
    └── src/
        ├── main/
             ├── cpp/
             │   ├── types/
             │   │    └── libmy_napi_module/
             │   │         ├── Index.d.ts		 # 提供JS侧的接口方法
             │   │         └── oh-package.json5  # 将index.d.ts与.so文件关联起来
             ├── ets/
             │   ├── entryability/
             │   └── pages/
             │        └── Index.ets   # ArkTS 调用代码
             ├── build-profile.json5  # 定义CPU架构
             └── oh-package.json5     # 声明.so库根目录路径
```

**1. 复制 libmy_napi_module.so 到 entry/libs/x86_64 目录下。**

**2. 在 entry/src/main/cpp 目录下创建 types/libmy_napi_module 目录。**

// entry/src/main/cpp/types/libmy_napi_module/Index.d.ts
```typescript
export const sub: (a: number, b: number) => number;
export const createPerson: () => Person;

interface Person {
  name: string;
  age: number;
}
```

// entry/src/main/cpp/types/libmy_napi_module/oh-package.json5
```json
{ "name": "libmy_napi_module.so", "types": "./Index.d.ts", "version": "1.0.0" }
```

**3. 声明.so库根目录路径**

// entry/src/main/oh-package.json5
````json
{
  // 其他属性...
  
  "dependencies": {
    "libmy_napi_module.so": "file:./src/main/cpp/types/libmy_napi_module",
    "libentry.so": "file:./src/main/cpp/types/libentry"
  }
}
````

**4. ArkTS 调用**

// entry/src/main/ets/pages/Index.ets
```typescript

import mymod from 'libmy_napi_module.so'

let sum = mymod.sub(13, 4)       // sum = 9
let person = mymod.createPerson() // person = {name: 'Alice', age: 30}

```
