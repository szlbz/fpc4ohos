unit napilib;
{ NAPI 函数绑定库 — OpenHarmony NAPI 的 Pascal 接口封装。
  System 单元已提供核心类型（napi_env, napi_value, napi_callback, napi_finalize 等），
  本单元补充所有其他 NAPI 类型及全部 external 函数声明。使用时在项目 uses 中加入 napilib 即可。

  版本隔离：通过 FPC_NAPI_SUPPORT_12 / _18 / _20 / _21 / _22 / _23 / _24
  其中 _13 / _14 / _15 三个等级在 NAPI 函数层面与 _12 相同（SDK API 14 是最早实装版本，13/14/15 未新增 NAPI 函数）
  选择目标 API Level，高级别自动包含低级别。

  API 12 = 基础 NAPI 子集（OpenHarmony 5.0.x / SDK API 14）
  API 18 = 增加 Promise/TSF/Date/BigInt 等（OpenHarmony 5.1.x / SDK API 18）
  API 20 = 完整 NAPI（OpenHarmony 6.0.x / SDK API 20）
  API 21+ = DevEco Studio 最新 SDK 特有扩展

  默认：FPC_NAPI_SUPPORT_12（兼容所有 SDK 版本）
}

interface
{*****************************************************************************
  NAPI API Level versioning:
  Define FPC_NAPI_SUPPORT_12 / 18 / 20 / 21 / 22 / 23 / 24 to select the API level.
  Higher levels cascade down, e.g. -dFPC_NAPI_SUPPORT_20 enables 12 + 18 + 20.
  Default = FPC_NAPI_SUPPORT_12 (safe for all SDKs).
*****************************************************************************}
{$ifdef FPC_NAPI_SUPPORT_24}
  {$define FPC_NAPI_SUPPORT_23}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_23}
  {$define FPC_NAPI_SUPPORT_22}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_22}
  {$define FPC_NAPI_SUPPORT_21}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_21}
  {$define FPC_NAPI_SUPPORT_20}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_20}
  {$define FPC_NAPI_SUPPORT_18}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_18}
  {$define FPC_NAPI_SUPPORT_15}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_15}
  {$define FPC_NAPI_SUPPORT_14}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_14}
  {$define FPC_NAPI_SUPPORT_13}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_13}
  {$define FPC_NAPI_SUPPORT_12}
{$endif}
{$ifdef FPC_NAPI_SUPPORT_12}
  {$define FPC_NAPI_SUPPORT}
{$endif}

type
  napi_env = Pointer;
  napi_value = Pointer;
  napi_status = LongInt;
  napi_callback_info = Pointer;
  napi_ref = Pointer;
  napi_handle_scope = Pointer;
  napi_escapable_handle_scope = Pointer;
  napi_deferred = Pointer;

  Pnapi_env = ^napi_env;
  Pnapi_value = ^napi_value;
  Pnapi_status = ^napi_status;
  Pnapi_ref = ^napi_ref;
  Pnapi_handle_scope = ^napi_handle_scope;
  Pnapi_escapable_handle_scope = ^napi_escapable_handle_scope;
  Pnapi_deferred = ^napi_deferred;


  napi_callback_scope = Pointer;
  napi_async_context = Pointer;
  napi_async_work = Pointer;
  napi_threadsafe_function = Pointer;
  napi_async_cleanup_hook_handle = Pointer;

  Pnapi_callback_scope = ^napi_callback_scope;
  Pnapi_async_work = ^napi_async_work;
  Pnapi_async_context = ^napi_async_context;
  Pnapi_threadsafe_function = ^napi_threadsafe_function;
  Pnapi_async_cleanup_hook_handle = ^napi_async_cleanup_hook_handle;
  
{$ifdef FPC_NAPI_SUPPORT_21}
  napi_critical_scope = Pointer;
  napi_strong_ref = Pointer;
  Pnapi_critical_scope = ^napi_critical_scope;
  Pnapi_strong_ref = ^napi_strong_ref;
{$endif FPC_NAPI_SUPPORT_21}

{$ifdef FPC_NAPI_SUPPORT_24}
  napi_callsite_info = Pointer;
  Pnapi_callsite_info = ^napi_callsite_info;
{$endif FPC_NAPI_SUPPORT_24}

{*****************************************************************************
                          NAPI Enums
*****************************************************************************}
const
  { napi_status values }
  napi_ok = 0;
  napi_invalid_arg = 1;
  napi_object_expected = 2;
  napi_string_expected = 3;
  napi_name_expected = 4;
  napi_function_expected = 5;
  napi_number_expected = 6;
  napi_boolean_expected = 7;
  napi_array_expected = 8;
  napi_generic_failure = 9;
  napi_pending_exception = 10;
  napi_cancelled = 11;
  napi_escape_called_twice = 12;
  napi_handle_scope_mismatch = 13;
  napi_callback_scope_mismatch = 14;
  napi_queue_full = 15;
  napi_closing = 16;
  napi_bigint_expected = 17;
  napi_date_expected = 18;
  napi_arraybuffer_expected = 19;
  napi_detachable_arraybuffer_expected = 20;
  napi_would_deadlock = 21;

  NAPI_AUTO_LENGTH = SizeUInt(-1);
  
type
  napi_property_attributes = (
    napi_default = 0,
    napi_writable = 1,
    napi_enumerable = 2,
    napi_configurable = 4,
    napi_default_method = 6,
    napi_default_jsproperty = 7,
    napi_static = 1024
  );

  napi_valuetype = (
    napi_undefined = 0,
    napi_null = 1,
    napi_boolean = 2,
    napi_number = 3,
    napi_string = 4,
    napi_symbol = 5,
    napi_object = 6,
    napi_function = 7,
    napi_external = 8,
    napi_bigint = 9
  );

  napi_typedarray_type = (
    napi_int8_array = 0,
    napi_uint8_array = 1,
    napi_uint8_clamped_array = 2,
    napi_int16_array = 3,
    napi_uint16_array = 4,
    napi_int32_array = 5,
    napi_uint32_array = 6,
    napi_float32_array = 7,
    napi_float64_array = 8,
    napi_bigint64_array = 9,
    napi_biguint64_array = 10
  );

  napi_key_collection_mode = (
    napi_key_include_prototypes = 0,
    napi_key_own_only = 1
  );

  napi_key_filter = (
    napi_key_all_properties = 0,
    napi_key_writable = 1,
    napi_key_enumerable = 2,
    napi_key_configurable = 4,
    napi_key_skip_strings = 8,
    napi_key_skip_symbols = 16
  );

  napi_key_conversion = (
    napi_key_keep_numbers = 0,
    napi_key_numbers_to_strings = 1
  );

  napi_threadsafe_function_release_mode = (
    napi_tsfn_release = 0,
    napi_tsfn_abort = 1
  );

  napi_threadsafe_function_call_mode = (
    napi_tsfn_nonblocking = 0,
    napi_tsfn_blocking = 1
  );

  { OHOS 特有枚举（common.h）}
  napi_qos_t = (
    napi_qos_background = 0,
    napi_qos_utility = 1,
    napi_qos_default = 2,
    napi_qos_user_initiated = 3
  );

  napi_event_mode = (
    napi_event_mode_default = 0,
    napi_event_mode_nowait = 1
  );

  napi_task_priority = (
    napi_priority_immediate = 0,
    napi_priority_high = 1,
    napi_priority_low = 2,
    napi_priority_idle = 3
  );

  Pnapi_typedarray_type = ^napi_typedarray_type;
  Pnapi_valuetype = ^napi_valuetype;
  
{*****************************************************************************
                          NAPI Record Types
*****************************************************************************}
  napi_type_tag = record
    lower: QWord;
    upper: QWord;
  end;
  Pnapi_type_tag = ^napi_type_tag;

  napi_property_descriptor = record
    utf8name: PAnsiChar;
    name: napi_value;
    method: CodePointer;    { napi_callback; 在 C 中是单一函数指针(8字节)，不能 用 napi_callback(TMethod=16字节) }
    getter: CodePointer;    { napi_callback; 在 C 中是单一函数指针(8字节)，不能 用 napi_callback(TMethod=16字节) }
    setter: CodePointer;    { napi_callback; 在 C 中是单一函数指针(8字节)，不能 用 napi_callback(TMethod=16字节) }
    value: napi_value;
    attributes: napi_property_attributes;
    data: Pointer;
  end;
  Pnapi_property_descriptor = ^napi_property_descriptor;

  napi_extended_error_info = record
    error_message: PAnsiChar;
    engine_reserved: Pointer;
    engine_error_code: DWord;
    error_code: napi_status;
  end;

  napi_node_version = record
    major: DWord;
    minor: DWord;
    patch: DWord;
    release: PAnsiChar;
  end;
  Pnapi_node_version = ^napi_node_version;
  PPnapi_node_version = ^Pnapi_node_version;

{*****************************************************************************
                          NAPI Callback Types
*****************************************************************************}
  napi_callback = function(env: napi_env; info: napi_callback_info): napi_value; cdecl;
  napi_finalize = procedure(env: napi_env; finalize_data: Pointer; finalize_hint: Pointer); cdecl;
{$ifdef FPC_NAPI_SUPPORT_22}
  napi_finalize_callback = procedure(finalize_data: Pointer; finalize_hint: Pointer); cdecl;
{$endif FPC_NAPI_SUPPORT_22}
  napi_async_execute_callback = procedure(env: napi_env; data: Pointer); cdecl;
  napi_async_complete_callback = procedure(env: napi_env; status: napi_status; data: Pointer); cdecl;
  napi_async_cleanup_hook = procedure(handle: napi_async_cleanup_hook_handle; data: Pointer); cdecl;
  napi_threadsafe_function_call_js = procedure(env: napi_env; js_callback: napi_value;
    context: Pointer; data: Pointer); cdecl;
  napi_addon_register_func = function(env: napi_env; js_exports: napi_value): napi_value; cdecl;

{*****************************************************************************
                          napi_module Registration
*****************************************************************************}
type
  napi_module = record
    nm_version: LongInt;
    nm_flags: DWord;
    nm_filename: PAnsiChar;
    nm_register_func: CodePointer;   { napi_addon_register_func; C 中是单函数指针，不能用 napi_addon_register_func(TMethod) }
    nm_modname: PAnsiChar;
    nm_priv: Pointer;
    reserved: array[0..3] of Pointer;
  end;
  Pnapi_module = ^napi_module;

{ === Standard NAPI functions (NAPI_VERSION 8) === }

{*****************************************************************************
                    NAPI 函数声明（按功能分组）
*****************************************************************************}

{*****************************************************************************
  ⚠ 版本说明（基于 OpenHarmony-SDK API 14/18/20 头文件分析）：
  
  FPC_NAPI_SUPPORT_12 = API 14 SDK 功能子集（主要为 OHOS 扩展：
    sendable、serialize、event_loop、callback_scope、async_context、
    env_cleanup、instance_data、napi_create_buffer、type_tag 等）
  
  _12 = 全部标准 NAPI + OHOS 扩展（最低基准）
  _18 = napi_wrap_enhance（@since 18）
  _20 = ark_context 系列（@since 20）
*****************************************************************************}
{$ifdef FPC_NAPI_SUPPORT}
{=============================================================================
                    全部标准 NAPI 函数 + OHOS 扩展（API 12+）
=============================================================================}

{ 模块注册 }
function napi_module_register(amod: Pnapi_module): napi_status; cdecl; external;

{ 错误处理 }
function napi_get_last_error_info(env: napi_env; result: PPointer): napi_status; cdecl; external;
function napi_throw(env: napi_env; error: napi_value): napi_status; cdecl; external;
function napi_throw_error(env: napi_env; code: PAnsiChar; msg: PAnsiChar): napi_status; cdecl; external;
function napi_throw_type_error(env: napi_env; code: PAnsiChar; msg: PAnsiChar): napi_status; cdecl; external;
function napi_throw_range_error(env: napi_env; code: PAnsiChar; msg: PAnsiChar): napi_status; cdecl; external;
function napi_is_error(env: napi_env; value: napi_value; result: PByte): napi_status; cdecl; external;
function napi_is_exception_pending(env: napi_env; result: PByte): napi_status; cdecl; external;
function napi_get_and_clear_last_exception(env: napi_env; result: Pnapi_value): napi_status; cdecl; external;
procedure napi_fatal_error(location: PAnsiChar; location_len: SizeUInt;
  message: PAnsiChar; message_len: SizeUInt); cdecl; external;
function napi_create_error(env: napi_env; code: napi_value; msg: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_type_error(env: napi_env; code: napi_value; msg: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_range_error(env: napi_env; code: napi_value; msg: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;

{ 基本值获取 }
function napi_get_undefined(env: napi_env; result: Pnapi_value): napi_status; cdecl; external;
function napi_get_null(env: napi_env; result: Pnapi_value): napi_status; cdecl; external;
function napi_get_global(env: napi_env; result: Pnapi_value): napi_status; cdecl; external;
function napi_get_boolean(env: napi_env; value: LongBool; result: Pnapi_value): napi_status; cdecl; external;

{ 值创建 }
function napi_create_object(env: napi_env; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_array(env: napi_env; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_array_with_length(env: napi_env; length: SizeUInt;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_double(env: napi_env; value: Double; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_int32(env: napi_env; value: LongInt; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_uint32(env: napi_env; value: DWord; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_int64(env: napi_env; value: Int64; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_string_latin1(env: napi_env; str: PAnsiChar; length: SizeUInt;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_string_utf8(env: napi_env; str: PAnsiChar; length: SizeUInt;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_string_utf16(env: napi_env; str: PWord; length: SizeUInt;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_symbol(env: napi_env; description: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_function(env: napi_env; utf8name: PAnsiChar; length: SizeUInt;
  cb: Pointer{napi_callback}; data: Pointer; result: Pnapi_value): napi_status; cdecl; external;

{ 类型检查与值转换 }
function napi_typeof(env: napi_env; value: napi_value;
  result: Pnapi_valuetype): napi_status; cdecl; external;
function napi_get_value_double(env: napi_env; value: napi_value;
  result: PDouble): napi_status; cdecl; external;
function napi_get_value_int32(env: napi_env; value: napi_value;
  result: PLongInt): napi_status; cdecl; external;
function napi_get_value_uint32(env: napi_env; value: napi_value;
  result: PDWord): napi_status; cdecl; external;
function napi_get_value_int64(env: napi_env; value: napi_value;
  result: PInt64): napi_status; cdecl; external;
function napi_get_value_bool(env: napi_env; value: napi_value;
  result: PByteBool): napi_status; cdecl; external;
function napi_get_value_string_latin1(env: napi_env; value: napi_value;
  buf: PAnsiChar; bufsize: SizeUInt; result: PSizeUInt): napi_status; cdecl; external;
function napi_get_value_string_utf8(env: napi_env; value: napi_value;
  buf: PAnsiChar; bufsize: SizeUInt; result: PSizeUInt): napi_status; cdecl; external;
function napi_get_value_string_utf16(env: napi_env; value: napi_value;
  buf: PWord; bufsize: SizeUInt; result: PSizeUInt): napi_status; cdecl; external;
function napi_coerce_to_bool(env: napi_env; value: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_coerce_to_number(env: napi_env; value: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_coerce_to_object(env: napi_env; value: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_coerce_to_string(env: napi_env; value: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_get_value_external(env: napi_env; value: napi_value;
  result: PPointer): napi_status; cdecl; external;

{ 对象属性操作 }
function napi_get_prototype(env: napi_env; aobject: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_get_property_names(env: napi_env; aobject: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_set_property(env: napi_env; aobject: napi_value;
  key: napi_value; value: napi_value): napi_status; cdecl; external;
function napi_get_property(env: napi_env; aobject: napi_value;
  key: napi_value; result: Pnapi_value): napi_status; cdecl; external;
function napi_has_property(env: napi_env; aobject: napi_value;
  key: napi_value; result: PByte): napi_status; cdecl; external;
function napi_delete_property(env: napi_env; aobject: napi_value;
  key: napi_value; result: PByte): napi_status; cdecl; external;
function napi_has_own_property(env: napi_env; aobject: napi_value;
  key: napi_value; result: PByte): napi_status; cdecl; external;
function napi_set_named_property(env: napi_env; aobject: napi_value;
  utf8name: PAnsiChar; value: napi_value): napi_status; cdecl; external;
function napi_get_named_property(env: napi_env; aobject: napi_value;
  utf8name: PAnsiChar; result: Pnapi_value): napi_status; cdecl; external;
function napi_has_named_property(env: napi_env; aobject: napi_value;
  utf8name: PAnsiChar; result: PByte): napi_status; cdecl; external;
function napi_define_properties(env: napi_env; aobject: napi_value;
  property_count: SizeUInt; properties: Pnapi_property_descriptor): napi_status; cdecl; external;

{ 数组操作 }
function napi_set_element(env: napi_env; aobject: napi_value; index: DWord;
  value: napi_value): napi_status; cdecl; external;
function napi_get_element(env: napi_env; aobject: napi_value; index: DWord;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_has_element(env: napi_env; aobject: napi_value; index: DWord;
  result: PByte): napi_status; cdecl; external;
function napi_delete_element(env: napi_env; aobject: napi_value; index: DWord;
  result: PByte): napi_status; cdecl; external;
function napi_is_array(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_get_array_length(env: napi_env; value: napi_value;
  result: PDWord): napi_status; cdecl; external;
function napi_strict_equals(env: napi_env; lhs: napi_value; rhs: napi_value;
  result: PByte): napi_status; cdecl; external;

{ 函数调用 / 回调 / 类 }
function napi_call_function(env: napi_env; recv: napi_value; func: napi_value;
  argc: SizeUInt; argv: Pnapi_value; result: Pnapi_value): napi_status; cdecl; external;
function napi_new_instance(env: napi_env; constructor_: napi_value;
  argc: SizeUInt; argv: Pnapi_value; result: Pnapi_value): napi_status; cdecl; external;
function napi_instanceof(env: napi_env; aobject: napi_value;
  constructor_: napi_value; result: PByte): napi_status; cdecl; external;
function napi_get_cb_info(env: napi_env; cbinfo: napi_callback_info;
  argc: PSizeUInt; argv: Pnapi_value; this_arg: Pnapi_value;
  data: PPointer): napi_status; cdecl; external;
function napi_get_new_target(env: napi_env; cbinfo: napi_callback_info;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_define_class(env: napi_env; utf8name: PAnsiChar; length: SizeUInt;
  constructor_: Pointer{napi_callback}; data: Pointer; property_count: SizeUInt;
  properties: Pnapi_property_descriptor; result: Pnapi_value): napi_status; cdecl; external;

{ 原生对象包装 }
function napi_wrap(env: napi_env; js_object: napi_value; native_object: Pointer;
  finalize_cb: Pointer{napi_finalize}; finalize_hint: Pointer;
  result: Pnapi_ref): napi_status; cdecl; external;
function napi_unwrap(env: napi_env; js_object: napi_value;
  result: PPointer): napi_status; cdecl; external;
function napi_remove_wrap(env: napi_env; js_object: napi_value;
  result: PPointer): napi_status; cdecl; external;
function napi_create_external(env: napi_env; data: Pointer;
  finalize_cb: Pointer{napi_finalize}; finalize_hint: Pointer;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_add_finalizer(env: napi_env; js_object: napi_value;
  native_object: Pointer; finalize_cb: Pointer{napi_finalize}; finalize_hint: Pointer;
  result: Pnapi_ref): napi_status; cdecl; external;

{ 引用管理 }
function napi_create_reference(env: napi_env; value: napi_value;
  initial_refcount: DWord; result: Pnapi_ref): napi_status; cdecl; external;
function napi_delete_reference(env: napi_env; ref: napi_ref): napi_status; cdecl; external;
function napi_reference_ref(env: napi_env; ref: napi_ref;
  result: PDWord): napi_status; cdecl; external;
function napi_reference_unref(env: napi_env; ref: napi_ref;
  result: PDWord): napi_status; cdecl; external;
function napi_get_reference_value(env: napi_env; ref: napi_ref;
  result: Pnapi_value): napi_status; cdecl; external;

{ 作用域 }
function napi_open_handle_scope(env: napi_env;
  result: Pnapi_handle_scope): napi_status; cdecl; external;
function napi_close_handle_scope(env: napi_env;
  scope: napi_handle_scope): napi_status; cdecl; external;
function napi_open_escapable_handle_scope(env: napi_env;
  result: Pnapi_escapable_handle_scope): napi_status; cdecl; external;
function napi_close_escapable_handle_scope(env: napi_env;
  scope: napi_escapable_handle_scope): napi_status; cdecl; external;
function napi_escape_handle(env: napi_env; scope: napi_escapable_handle_scope;
  escapee: napi_value; result: Pnapi_value): napi_status; cdecl; external;

{ 回调作用域 / 异步上下文 }
function napi_open_callback_scope(env: napi_env; resource_object: napi_value;
  context: napi_async_context; result: Pnapi_callback_scope): napi_status; cdecl; external;
function napi_close_callback_scope(env: napi_env;
  scope: napi_callback_scope): napi_status; cdecl; external;
function napi_async_init(env: napi_env; async_resource: napi_value;
  async_resource_name: napi_value; result: Pnapi_async_context): napi_status; cdecl; external;
function napi_async_destroy(env: napi_env;
  async_context: napi_async_context): napi_status; cdecl; external;
function napi_make_callback(env: napi_env; async_context: napi_async_context;
  recv: napi_value; func: napi_value; argc: SizeUInt; argv: Pnapi_value;
  result: Pnapi_value): napi_status; cdecl; external;

{ 异步工作 }
function napi_create_async_work(env: napi_env; async_resource: napi_value;
  async_resource_name: napi_value; execute: Pointer{napi_async_execute_callback};
  complete: Pointer{napi_async_complete_callback}; data: Pointer;
  result: Pnapi_async_work): napi_status; cdecl; external;
function napi_delete_async_work(env: napi_env;
  work: napi_async_work): napi_status; cdecl; external;
function napi_queue_async_work(env: napi_env;
  work: napi_async_work): napi_status; cdecl; external;
function napi_cancel_async_work(env: napi_env;
  work: napi_async_work): napi_status; cdecl; external;

{ Buffer / ArrayBuffer / TypedArray / DataView }
function napi_create_buffer(env: napi_env; length: SizeUInt;
  data: PPointer; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_buffer_copy(env: napi_env; length: SizeUInt;
  data: Pointer; result_data: PPointer; result: Pnapi_value): napi_status; cdecl; external;
function napi_is_buffer(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_get_buffer_info(env: napi_env; value: napi_value;
  data: PPointer; length: PSizeUInt): napi_status; cdecl; external;
function napi_create_external_buffer(env: napi_env; length: SizeUInt;
  data: Pointer; finalize_cb: Pointer{napi_finalize}; finalize_hint: Pointer;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_is_arraybuffer(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_create_arraybuffer(env: napi_env; byte_length: SizeUInt;
  data: PPointer; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_external_arraybuffer(env: napi_env; external_data: Pointer;
  byte_length: SizeUInt; finalize_cb: Pointer{napi_finalize}; finalize_hint: Pointer;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_get_arraybuffer_info(env: napi_env; arraybuffer: napi_value;
  data: PPointer; byte_length: PSizeUInt): napi_status; cdecl; external;
function napi_detach_arraybuffer(env: napi_env;
  arraybuffer: napi_value): napi_status; cdecl; external;
function napi_is_detached_arraybuffer(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_is_typedarray(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_create_typedarray(env: napi_env; typ: napi_typedarray_type;
  length: SizeUInt; arraybuffer: napi_value; byte_offset: SizeUInt;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_get_typedarray_info(env: napi_env; typedarray: napi_value;
  typ: Pnapi_typedarray_type; length: PSizeUInt; data: PPointer;
  arraybuffer: Pnapi_value; byte_offset: PSizeUInt): napi_status; cdecl; external;
function napi_create_dataview(env: napi_env; length: SizeUInt;
  arraybuffer: napi_value; byte_offset: SizeUInt;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_is_dataview(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_get_dataview_info(env: napi_env; dataview: napi_value;
  bytelength: PSizeUInt; data: PPointer; arraybuffer: Pnapi_value;
  byte_offset: PSizeUInt): napi_status; cdecl; external;

{ Promise }
function napi_create_promise(env: napi_env; deferred: Pnapi_deferred;
  promise: Pnapi_value): napi_status; cdecl; external;
function napi_resolve_deferred(env: napi_env; deferred: napi_deferred;
  resolution: napi_value): napi_status; cdecl; external;
function napi_reject_deferred(env: napi_env; deferred: napi_deferred;
  rejection: napi_value): napi_status; cdecl; external;
function napi_is_promise(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;

{ Date / BigInt }
function napi_create_date(env: napi_env; time: Double;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_is_date(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_get_date_value(env: napi_env; value: napi_value;
  result: PDouble): napi_status; cdecl; external;
function napi_create_bigint_int64(env: napi_env; value: Int64;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_bigint_uint64(env: napi_env; value: QWord;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_bigint_words(env: napi_env; sign_bit: LongInt;
  word_count: SizeUInt; words: PQWord; result: Pnapi_value): napi_status; cdecl; external;
function napi_get_value_bigint_int64(env: napi_env; value: napi_value;
  result: PInt64; lossless: PByte): napi_status; cdecl; external;
function napi_get_value_bigint_uint64(env: napi_env; value: napi_value;
  result: PQWord; lossless: PByte): napi_status; cdecl; external;
function napi_get_value_bigint_words(env: napi_env; value: napi_value;
  sign_bit: PLongInt; word_count: PSizeUInt; words: PQWord): napi_status; cdecl; external;

{ 线程安全函数 }
function napi_create_threadsafe_function(env: napi_env; func: napi_value;
  async_resource: napi_value; async_resource_name: napi_value;
  max_queue_size: SizeUInt; initial_thread_count: SizeUInt;
  thread_finalize_data: Pointer; thread_finalize_cb: Pointer{napi_finalize};
  context: Pointer; call_js_cb: Pointer{napi_threadsafe_function_call_js};
  result: Pnapi_threadsafe_function): napi_status; cdecl; external;
function napi_get_threadsafe_function_context(func: napi_threadsafe_function;
  result: PPointer): napi_status; cdecl; external;
function napi_call_threadsafe_function(func: napi_threadsafe_function;
  data: Pointer; call_mode: napi_threadsafe_function_call_mode): napi_status; cdecl; external;
function napi_acquire_threadsafe_function(
  func: napi_threadsafe_function): napi_status; cdecl; external;
function napi_release_threadsafe_function(func: napi_threadsafe_function;
  mode: napi_threadsafe_function_release_mode): napi_status; cdecl; external;
function napi_ref_threadsafe_function(env: napi_env;
  func: napi_threadsafe_function): napi_status; cdecl; external;
function napi_unref_threadsafe_function(env: napi_env;
  func: napi_threadsafe_function): napi_status; cdecl; external;

{ 环境清理 }
function napi_add_env_cleanup_hook(env: napi_env; fun: Pointer;
  arg: Pointer): napi_status; cdecl; external;
function napi_remove_env_cleanup_hook(env: napi_env; fun: Pointer;
  arg: Pointer): napi_status; cdecl; external;
function napi_add_async_cleanup_hook(env: napi_env;
  hook: Pointer{napi_async_cleanup_hook}; arg: Pointer;
  remove_handle: Pointer{Pnapi_async_cleanup_hook_handle}): napi_status; cdecl; external;
function napi_remove_async_cleanup_hook(
  remove_handle: Pointer{napi_async_cleanup_hook_handle}): napi_status; cdecl; external;

{ 实例数据与版本 }
function napi_set_instance_data(env: napi_env; data: Pointer;
  finalize_cb: Pointer{napi_finalize}; finalize_hint: Pointer): napi_status; cdecl; external;
function napi_get_instance_data(env: napi_env;
  data: PPointer): napi_status; cdecl; external;
function napi_adjust_external_memory(env: napi_env; change_in_bytes: Int64;
  adjusted_value: PInt64): napi_status; cdecl; external;
function napi_get_version(env: napi_env; result: PDWord): napi_status; cdecl; external;
function napi_get_node_version(env: napi_env;
  result: PPnapi_node_version): napi_status; cdecl; external;
function napi_get_uv_event_loop(env: napi_env;
  result: PPointer): napi_status; cdecl; external;

{ 属性枚举 / 冻结 / 类型标签 }
function napi_get_all_property_names(env: napi_env; aobject: napi_value;
  key_mode: napi_key_collection_mode; key_filter: napi_key_filter;
  key_conversion: napi_key_conversion; result: Pnapi_value): napi_status; cdecl; external;
function napi_object_freeze(env: napi_env;
  aobject: napi_value): napi_status; cdecl; external;
function napi_object_seal(env: napi_env;
  aobject: napi_value): napi_status; cdecl; external;
function napi_type_tag_object(env: napi_env; value: napi_value;
  type_tag: Pnapi_type_tag): napi_status; cdecl; external;
function napi_check_object_type_tag(env: napi_env; value: napi_value;
  type_tag: Pnapi_type_tag; result: PByte): napi_status; cdecl; external;
function napi_run_script(env: napi_env; script: napi_value;
  result: Pnapi_value): napi_status; cdecl; external;

{ OHOS 特有扩展 }
function napi_load_module(env: napi_env; path: PAnsiChar;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_load_module_with_info(env: napi_env; path: PAnsiChar;
  module_info: PAnsiChar; result: Pnapi_value): napi_status; cdecl; external;
function napi_run_script_path(env: napi_env; path: PAnsiChar;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_queue_async_work_with_qos(env: napi_env;
  work: napi_async_work; qos: napi_qos_t): napi_status; cdecl; external;
function napi_create_object_with_properties(env: napi_env;
  result: Pnapi_value; property_count: SizeUInt;
  properties: Pnapi_property_descriptor): napi_status; cdecl; external;
function napi_create_object_with_named_properties(env: napi_env;
  result: Pnapi_value; property_count: SizeUInt; keys: PPAnsiChar;
  values: Pnapi_value): napi_status; cdecl; external;
function napi_coerce_to_native_binding_object(env: napi_env;
  js_object: napi_value; detach_cb: Pointer; attach_cb: Pointer;
  native_object: Pointer; hint: Pointer): napi_status; cdecl; external;
function napi_define_sendable_class(env: napi_env; utf8name: PAnsiChar;
  length: SizeUInt; constructor_: Pointer{napi_callback}; data: Pointer;
  property_count: SizeUInt; properties: Pnapi_property_descriptor;
  parent: napi_value; result: Pnapi_value): napi_status; cdecl; external;
function napi_is_sendable(env: napi_env; value: napi_value;
  result: PByte): napi_status; cdecl; external;
function napi_create_sendable_object_with_properties(env: napi_env;
  property_count: SizeUInt; properties: Pnapi_property_descriptor;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_wrap_sendable(env: napi_env; js_object: napi_value;
  native_object: Pointer; finalize_cb: Pointer{napi_finalize};
  finalize_hint: Pointer): napi_status; cdecl; external;
function napi_unwrap_sendable(env: napi_env; js_object: napi_value;
  result: PPointer): napi_status; cdecl; external;
function napi_remove_wrap_sendable(env: napi_env; js_object: napi_value;
  result: PPointer): napi_status; cdecl; external;
function napi_create_sendable_array(env: napi_env;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_sendable_array_with_length(env: napi_env;
  length: SizeUInt; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_sendable_arraybuffer(env: napi_env;
  byte_length: SizeUInt; data: PPointer;
  result: Pnapi_value): napi_status; cdecl; external;
function napi_create_sendable_typedarray(env: napi_env;
  typ: napi_typedarray_type; length: SizeUInt; arraybuffer: napi_value;
  byte_offset: SizeUInt; result: Pnapi_value): napi_status; cdecl; external;
function napi_run_event_loop(env: napi_env;
  mode: napi_event_mode): napi_status; cdecl; external;
function napi_stop_event_loop(env: napi_env): napi_status; cdecl; external;
function napi_serialize(env: napi_env; aobject: napi_value;
  transfer_list: napi_value; clone_list: napi_value;
  result: PPointer): napi_status; cdecl; external;
function napi_deserialize(env: napi_env; buffer: Pointer;
  aobject: Pnapi_value): napi_status; cdecl; external;
function napi_delete_serialization_data(env: napi_env;
  buffer: Pointer): napi_status; cdecl; external;
function napi_fatal_exception(env: napi_env;
  err: napi_value): napi_status; cdecl; external;
function napi_call_threadsafe_function_with_priority(
  func: napi_threadsafe_function; data: Pointer;
  priority: napi_task_priority; isTail: LongBool): napi_status; cdecl; external;
function napi_wrap_sendable_with_size(env: napi_env; js_object: napi_value;
  native_object: Pointer; finalize_cb: Pointer{napi_finalize}; finalize_hint: Pointer;
  native_binding_size: SizeUInt): napi_status; cdecl; external;
function napi_create_ark_runtime(env: Pnapi_env): napi_status; cdecl; external;
function napi_destroy_ark_runtime(env: napi_env): napi_status; cdecl; external;

{=============================================================================
                    版本特有扩展
=============================================================================}
{$ifdef FPC_NAPI_SUPPORT_18}
function napi_wrap_enhance(env: napi_env; js_object: napi_value;
  native_object: Pointer; finalize_cb: Pointer{napi_finalize};
  async_finalizer: LongBool; finalize_hint: Pointer;
  native_binding_size: SizeUInt; result: Pnapi_ref): napi_status; cdecl; external;
{$endif FPC_NAPI_SUPPORT_18}

{$ifdef FPC_NAPI_SUPPORT_20}
function napi_create_ark_context(env: napi_env;
  newEnv: Pnapi_env): napi_status; cdecl; external;
function napi_switch_ark_context(env: napi_env): napi_status; cdecl; external;
function napi_destroy_ark_context(env: napi_env): napi_status; cdecl; external;
{$endif FPC_NAPI_SUPPORT_20}

{$ifdef FPC_NAPI_SUPPORT_21}
{ Critical scope (@since 21) }
function napi_open_critical_scope(env: napi_env;
  scope: Pnapi_critical_scope): napi_status; cdecl; external;
function napi_close_critical_scope(env: napi_env;
  scope: napi_critical_scope): napi_status; cdecl; external;
function napi_get_buffer_string_utf16_in_critical_scope(env: napi_env;
  value: napi_value; buffer: PPointer; length: PSizeUInt): napi_status; cdecl; external;

{ Strong references (@since 21) }
function napi_create_strong_reference(env: napi_env; value: napi_value;
  result: Pnapi_strong_ref): napi_status; cdecl; external;
function napi_delete_strong_reference(env: napi_env;
  ref: napi_strong_ref): napi_status; cdecl; external;
function napi_get_strong_reference_value(env: napi_env; ref: napi_strong_ref;
  result: Pnapi_value): napi_status; cdecl; external;
{$endif FPC_NAPI_SUPPORT_21}

{$ifdef FPC_NAPI_SUPPORT_22}
{ External strings (@since 22) }
function napi_create_external_string_utf16(env: napi_env; str: PWord;
  length: SizeUInt; finalize_callback: Pointer{napi_finalize_callback};
  finalize_hint: Pointer; result: Pnapi_value): napi_status; cdecl; external;
function napi_create_external_string_ascii(env: napi_env; str: PAnsiChar;
  length: SizeUInt; finalize_callback: Pointer{napi_finalize_callback};
  finalize_hint: Pointer; result: Pnapi_value): napi_status; cdecl; external;

{ Sendable references (@since 22) }
function napi_create_strong_sendable_reference(env: napi_env; value: napi_value;
  result: Pnapi_sendable_ref): napi_status; cdecl; external;
function napi_delete_strong_sendable_reference(env: napi_env;
  ref: napi_sendable_ref): napi_status; cdecl; external;
function napi_get_strong_sendable_reference_value(env: napi_env;
  ref: napi_sendable_ref; result: Pnapi_value): napi_status; cdecl; external;
{$endif FPC_NAPI_SUPPORT_22}

{$ifdef FPC_NAPI_SUPPORT_23}
{ Business error (@since 23) }
function napi_throw_business_error(env: napi_env; errorCode: cint32;
  msg: PAnsiChar): napi_status; cdecl; external;
{$endif FPC_NAPI_SUPPORT_23}

{$ifdef FPC_NAPI_SUPPORT_24}
{ Callsite info IC caching (@since 24) }
function napi_create_callsite_info(env: napi_env;
  result: Pnapi_callsite_info): napi_status; cdecl; external;
function napi_delete_callsite_info(env: napi_env;
  info: napi_callsite_info): napi_status; cdecl; external;
function napi_get_property_with_callsite_info(env: napi_env;
  aobject: napi_value; key: napi_value; info: napi_callsite_info;
  result: Pnapi_value; hit: PByte): napi_status; cdecl; external;
function napi_set_property_with_callsite_info(env: napi_env;
  aobject: napi_value; key: napi_value; value: napi_value;
  info: napi_callsite_info; hit: PByte): napi_status; cdecl; external;
{$endif FPC_NAPI_SUPPORT_24}

{$endif FPC_NAPI_SUPPORT}

{ 模块注册入口 }
type
  TNAPIMethod = record
    Name: PAnsiChar;
    Callback: CodePointer;
  end;
  TNAPIMethodArray = array of TNAPIMethod;

var
  FPC_NAPI_Methods: TNAPIMethodArray;
  FPC_NAPI_MethodCount: Integer;

procedure RegisterNAPIMethod(const Name: PAnsiChar; Callback: napi_callback);

function napi_register_module_v1(env: napi_env; mod_exports: napi_value): napi_value; cdecl; public name 'napi_register_module_v1';

implementation

procedure RegisterNAPIMethod(const Name: PAnsiChar; Callback: napi_callback);
var
  m: record case Byte of
    0: (c: napi_callback);
    1: (code: CodePointer; data: Pointer);
    end;
begin
  m.c := Callback;
  Inc(FPC_NAPI_MethodCount);
  SetLength(FPC_NAPI_Methods, FPC_NAPI_MethodCount);
  FPC_NAPI_Methods[FPC_NAPI_MethodCount-1].Name := Name;
  FPC_NAPI_Methods[FPC_NAPI_MethodCount-1].Callback := m.code;
end;

function napi_register_module_v1(env: napi_env; mod_exports: napi_value): napi_value; cdecl;
var
  i: Integer;
  total: Integer;
  desc: array of napi_property_descriptor;
begin
{$ifdef FPC_NAPI_SUPPORT}
  total := FPC_NAPI_MethodCount;

  if total = 0 then
    Exit(mod_exports);

  SetLength(desc, total);

  for i := 0 to total - 1 do
  begin
    // 从FPC_NAPI_Methods中获取当前项
    with FPC_NAPI_Methods[i] do
    begin
      // 填充napi_property_descriptor记录
      desc[i].utf8name := Name;       // 属性名
      desc[i].name := nil;            // 使用utf8name，所以这里为nil
      desc[i].method := Callback;     // C++回调函数指针
      desc[i].getter := nil;          // 非getter
      desc[i].setter := nil;          // 非setter
      desc[i].value := nil;           // 非属性值
      desc[i].attributes := napi_default; // 默认属性
      desc[i].data := nil;            // 无额外数据
    end;
  end;

  napi_define_properties(env, mod_exports, total, @desc[0]);
  
  SetLength(desc, 0);
  Exit(mod_exports);                                           
{$endif FPC_NAPI_SUPPORT}    
end;

end.
