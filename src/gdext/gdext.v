// Copyright 2026 Timofey Brukhanchik
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module gdext

import time

__global (
	gdf = &GDExt(unsafe { nil })
)

pub struct GDExt {
	GDExtensionInterfaceFunctions
}

pub fn setup(gpaddr fn (&i8) GDExtensionInterfaceFunctionPtr, clp GDExtensionClassLibraryPtr) &GDExt {
	C._vinit(0, unsafe { nil })

	interface_fns := &GDExtensionInterfaceFunctions{
		gpaddr:                                             gpaddr
		clp:                                                clp
		get_godot_version:                                  unsafe { GDExtensionInterfaceGetGodotVersion(gpaddr(c'get_godot_version')) }
		get_godot_version2:                                 unsafe { GDExtensionInterfaceGetGodotVersion2(gpaddr(c'get_godot_version2')) }
		mem_alloc:                                          unsafe { GDExtensionInterfaceMemAlloc(gpaddr(c'mem_alloc')) }
		mem_realloc:                                        unsafe { GDExtensionInterfaceMemRealloc(gpaddr(c'mem_realloc')) }
		mem_free:                                           unsafe { GDExtensionInterfaceMemFree(gpaddr(c'mem_free')) }
		print_error:                                        unsafe { GDExtensionInterfacePrintError(gpaddr(c'print_error')) }
		print_error_with_message:                           unsafe { GDExtensionInterfacePrintErrorWithMessage(gpaddr(c'print_error_with_message')) }
		print_warning:                                      unsafe { GDExtensionInterfacePrintWarning(gpaddr(c'print_warning')) }
		print_warning_with_message:                         unsafe { GDExtensionInterfacePrintWarningWithMessage(gpaddr(c'print_warning_with_message')) }
		print_script_error:                                 unsafe { GDExtensionInterfacePrintScriptError(gpaddr(c'print_script_error')) }
		print_script_error_with_message:                    unsafe { GDExtensionInterfacePrintScriptErrorWithMessage(gpaddr(c'print_script_error_with_message')) }
		get_native_struct_size:                             unsafe { GDExtensionInterfaceGetNativeStructSize(gpaddr(c'get_native_struct_size')) }
		variant_new_copy:                                   unsafe { GDExtensionInterfaceVariantNewCopy(gpaddr(c'variant_new_copy')) }
		variant_new_nil:                                    unsafe { GDExtensionInterfaceVariantNewNil(gpaddr(c'variant_new_nil')) }
		variant_destroy:                                    unsafe { GDExtensionInterfaceVariantDestroy(gpaddr(c'variant_destroy')) }
		variant_call:                                       unsafe { GDExtensionInterfaceVariantCall(gpaddr(c'variant_call')) }
		variant_call_static:                                unsafe { GDExtensionInterfaceVariantCallStatic(gpaddr(c'variant_call_static')) }
		variant_evaluate:                                   unsafe { GDExtensionInterfaceVariantEvaluate(gpaddr(c'variant_evaluate')) }
		variant_set:                                        unsafe { GDExtensionInterfaceVariantSet(gpaddr(c'variant_set')) }
		variant_set_named:                                  unsafe { GDExtensionInterfaceVariantSetNamed(gpaddr(c'variant_set_named')) }
		variant_set_keyed:                                  unsafe { GDExtensionInterfaceVariantSetKeyed(gpaddr(c'variant_set_keyed')) }
		variant_set_indexed:                                unsafe { GDExtensionInterfaceVariantSetIndexed(gpaddr(c'variant_set_indexed')) }
		variant_get:                                        unsafe { GDExtensionInterfaceVariantGet(gpaddr(c'variant_get')) }
		variant_get_named:                                  unsafe { GDExtensionInterfaceVariantGetNamed(gpaddr(c'variant_get_named')) }
		variant_get_keyed:                                  unsafe { GDExtensionInterfaceVariantGetKeyed(gpaddr(c'variant_get_keyed')) }
		variant_get_indexed:                                unsafe { GDExtensionInterfaceVariantGetIndexed(gpaddr(c'variant_get_indexed')) }
		variant_iter_init:                                  unsafe { GDExtensionInterfaceVariantIterInit(gpaddr(c'variant_iter_init')) }
		variant_iter_next:                                  unsafe { GDExtensionInterfaceVariantIterNext(gpaddr(c'variant_iter_next')) }
		variant_iter_get:                                   unsafe { GDExtensionInterfaceVariantIterGet(gpaddr(c'variant_iter_get')) }
		variant_hash:                                       unsafe { GDExtensionInterfaceVariantHash(gpaddr(c'variant_hash')) }
		variant_recursive_hash:                             unsafe { GDExtensionInterfaceVariantRecursiveHash(gpaddr(c'variant_recursive_hash')) }
		variant_hash_compare:                               unsafe { GDExtensionInterfaceVariantHashCompare(gpaddr(c'variant_hash_compare')) }
		variant_booleanize:                                 unsafe { GDExtensionInterfaceVariantBooleanize(gpaddr(c'variant_booleanize')) }
		variant_duplicate:                                  unsafe { GDExtensionInterfaceVariantDuplicate(gpaddr(c'variant_duplicate')) }
		variant_stringify:                                  unsafe { GDExtensionInterfaceVariantStringify(gpaddr(c'variant_stringify')) }
		variant_get_type:                                   unsafe { GDExtensionInterfaceVariantGetType(gpaddr(c'variant_get_type')) }
		variant_has_method:                                 unsafe { GDExtensionInterfaceVariantHasMethod(gpaddr(c'variant_has_method')) }
		variant_has_member:                                 unsafe { GDExtensionInterfaceVariantHasMember(gpaddr(c'variant_has_member')) }
		variant_has_key:                                    unsafe { GDExtensionInterfaceVariantHasKey(gpaddr(c'variant_has_key')) }
		variant_get_type_name:                              unsafe { GDExtensionInterfaceVariantGetTypeName(gpaddr(c'variant_get_type_name')) }
		variant_can_convert:                                unsafe { GDExtensionInterfaceVariantCanConvert(gpaddr(c'variant_can_convert')) }
		variant_can_convert_strict:                         unsafe { GDExtensionInterfaceVariantCanConvertStrict(gpaddr(c'variant_can_convert_strict')) }
		get_variant_from_type_constructor:                  unsafe { GDExtensionInterfaceGetVariantFromTypeConstructor(gpaddr(c'get_variant_from_type_constructor')) }
		get_variant_to_type_constructor:                    unsafe { GDExtensionInterfaceGetVariantToTypeConstructor(gpaddr(c'get_variant_to_type_constructor')) }
		variant_get_ptr_operator_evaluator:                 unsafe { GDExtensionInterfaceVariantGetPtrOperatorEvaluator(gpaddr(c'variant_get_ptr_operator_evaluator')) }
		variant_get_ptr_builtin_method:                     unsafe { GDExtensionInterfaceVariantGetPtrBuiltinMethod(gpaddr(c'variant_get_ptr_builtin_method')) }
		variant_get_ptr_constructor:                        unsafe { GDExtensionInterfaceVariantGetPtrConstructor(gpaddr(c'variant_get_ptr_constructor')) }
		variant_get_ptr_destructor:                         unsafe { GDExtensionInterfaceVariantGetPtrDestructor(gpaddr(c'variant_get_ptr_destructor')) }
		variant_construct:                                  unsafe { GDExtensionInterfaceVariantConstruct(gpaddr(c'variant_construct')) }
		variant_get_ptr_setter:                             unsafe { GDExtensionInterfaceVariantGetPtrSetter(gpaddr(c'variant_get_ptr_setter')) }
		variant_get_ptr_getter:                             unsafe { GDExtensionInterfaceVariantGetPtrGetter(gpaddr(c'variant_get_ptr_getter')) }
		variant_get_ptr_indexed_setter:                     unsafe { GDExtensionInterfaceVariantGetPtrIndexedSetter(gpaddr(c'variant_get_ptr_indexed_setter')) }
		variant_get_ptr_indexed_getter:                     unsafe { GDExtensionInterfaceVariantGetPtrIndexedGetter(gpaddr(c'variant_get_ptr_indexed_getter')) }
		variant_get_ptr_keyed_setter:                       unsafe { GDExtensionInterfaceVariantGetPtrKeyedSetter(gpaddr(c'variant_get_ptr_keyed_setter')) }
		variant_get_ptr_keyed_getter:                       unsafe { GDExtensionInterfaceVariantGetPtrKeyedGetter(gpaddr(c'variant_get_ptr_keyed_getter')) }
		variant_get_ptr_keyed_checker:                      unsafe { GDExtensionInterfaceVariantGetPtrKeyedChecker(gpaddr(c'variant_get_ptr_keyed_checker')) }
		variant_get_constant_value:                         unsafe { GDExtensionInterfaceVariantGetConstantValue(gpaddr(c'variant_get_constant_value')) }
		variant_get_ptr_utility_function:                   unsafe { GDExtensionInterfaceVariantGetPtrUtilityFunction(gpaddr(c'variant_get_ptr_utility_function')) }
		string_new_with_latin1_chars:                       unsafe { GDExtensionInterfaceStringNewWithLatin1Chars(gpaddr(c'string_new_with_latin1_chars')) }
		string_new_with_utf8_chars:                         unsafe { GDExtensionInterfaceStringNewWithUtf8Chars(gpaddr(c'string_new_with_utf8_chars')) }
		string_new_with_utf16_chars:                        unsafe { GDExtensionInterfaceStringNewWithUtf16Chars(gpaddr(c'string_new_with_utf16_chars')) }
		string_new_with_utf32_chars:                        unsafe { GDExtensionInterfaceStringNewWithUtf32Chars(gpaddr(c'string_new_with_utf32_chars')) }
		string_new_with_wide_chars:                         unsafe { GDExtensionInterfaceStringNewWithWideChars(gpaddr(c'string_new_with_wide_chars')) }
		string_new_with_latin1_chars_and_len:               unsafe { GDExtensionInterfaceStringNewWithLatin1CharsAndLen(gpaddr(c'string_new_with_latin1_chars_and_len')) }
		string_new_with_utf8_chars_and_len:                 unsafe { GDExtensionInterfaceStringNewWithUtf8CharsAndLen(gpaddr(c'string_new_with_utf8_chars_and_len')) }
		string_new_with_utf8_chars_and_len2:                unsafe { GDExtensionInterfaceStringNewWithUtf8CharsAndLen2(gpaddr(c'string_new_with_utf8_chars_and_len2')) }
		string_new_with_utf16_chars_and_len:                unsafe { GDExtensionInterfaceStringNewWithUtf16CharsAndLen(gpaddr(c'string_new_with_utf16_chars_and_len')) }
		string_new_with_utf16_chars_and_len2:               unsafe { GDExtensionInterfaceStringNewWithUtf16CharsAndLen2(gpaddr(c'string_new_with_utf16_chars_and_len2')) }
		string_new_with_utf32_chars_and_len:                unsafe { GDExtensionInterfaceStringNewWithUtf32CharsAndLen(gpaddr(c'string_new_with_utf32_chars_and_len')) }
		string_new_with_wide_chars_and_len:                 unsafe { GDExtensionInterfaceStringNewWithWideCharsAndLen(gpaddr(c'string_new_with_wide_chars_and_len')) }
		string_to_latin1_chars:                             unsafe { GDExtensionInterfaceStringToLatin1Chars(gpaddr(c'string_to_latin1_chars')) }
		string_to_utf8_chars:                               unsafe { GDExtensionInterfaceStringToUtf8Chars(gpaddr(c'string_to_utf8_chars')) }
		string_to_utf16_chars:                              unsafe { GDExtensionInterfaceStringToUtf16Chars(gpaddr(c'string_to_utf16_chars')) }
		string_to_utf32_chars:                              unsafe { GDExtensionInterfaceStringToUtf32Chars(gpaddr(c'string_to_utf32_chars')) }
		string_to_wide_chars:                               unsafe { GDExtensionInterfaceStringToWideChars(gpaddr(c'string_to_wide_chars')) }
		string_operator_index:                              unsafe { GDExtensionInterfaceStringOperatorIndex(gpaddr(c'string_operator_index')) }
		string_operator_index_const:                        unsafe { GDExtensionInterfaceStringOperatorIndexConst(gpaddr(c'string_operator_index_const')) }
		string_operator_plus_eq_string:                     unsafe { GDExtensionInterfaceStringOperatorPlusEqString(gpaddr(c'string_operator_plus_eq_string')) }
		string_operator_plus_eq_char:                       unsafe { GDExtensionInterfaceStringOperatorPlusEqChar(gpaddr(c'string_operator_plus_eq_char')) }
		string_operator_plus_eq_cstr:                       unsafe { GDExtensionInterfaceStringOperatorPlusEqCstr(gpaddr(c'string_operator_plus_eq_cstr')) }
		string_operator_plus_eq_wcstr:                      unsafe { GDExtensionInterfaceStringOperatorPlusEqWcstr(gpaddr(c'string_operator_plus_eq_wcstr')) }
		string_operator_plus_eq_c32str:                     unsafe { GDExtensionInterfaceStringOperatorPlusEqC32str(gpaddr(c'string_operator_plus_eq_c32str')) }
		xml_parser_open_buffer:                             unsafe { GDExtensionInterfaceXmlParserOpenBuffer(gpaddr(c'xml_parser_open_buffer')) }
		file_access_store_buffer:                           unsafe { GDExtensionInterfaceFileAccessStoreBuffer(gpaddr(c'file_access_store_buffer')) }
		file_access_get_buffer:                             unsafe { GDExtensionInterfaceFileAccessGetBuffer(gpaddr(c'file_access_get_buffer')) }
		packed_byte_array_operator_index_const:             unsafe { GDExtensionInterfacePackedByteArrayOperatorIndexConst(gpaddr(c'packed_byte_array_operator_index_const')) }
		packed_color_array_operator_index:                  unsafe { GDExtensionInterfacePackedColorArrayOperatorIndex(gpaddr(c'packed_color_array_operator_index')) }
		packed_color_array_operator_index_const:            unsafe { GDExtensionInterfacePackedColorArrayOperatorIndexConst(gpaddr(c'packed_color_array_operator_index_const')) }
		packed_float32_array_operator_index:                unsafe { GDExtensionInterfacePackedFloat32ArrayOperatorIndex(gpaddr(c'packed_float32_array_operator_index')) }
		packed_float32_array_operator_index_const:          unsafe { GDExtensionInterfacePackedFloat32ArrayOperatorIndexConst(gpaddr(c'packed_float32_array_operator_index_const')) }
		packed_float64_array_operator_index:                unsafe { GDExtensionInterfacePackedFloat64ArrayOperatorIndex(gpaddr(c'packed_float64_array_operator_index')) }
		packed_float64_array_operator_index_const:          unsafe { GDExtensionInterfacePackedFloat64ArrayOperatorIndexConst(gpaddr(c'packed_float64_array_operator_index_const')) }
		packed_int32_array_operator_index:                  unsafe { GDExtensionInterfacePackedInt32ArrayOperatorIndex(gpaddr(c'packed_int32_array_operator_index')) }
		packed_int32_array_operator_index_const:            unsafe { GDExtensionInterfacePackedInt32ArrayOperatorIndexConst(gpaddr(c'packed_int32_array_operator_index_const')) }
		packed_int64_array_operator_index:                  unsafe { GDExtensionInterfacePackedInt64ArrayOperatorIndex(gpaddr(c'packed_int64_array_operator_index')) }
		packed_int64_array_operator_index_const:            unsafe { GDExtensionInterfacePackedInt64ArrayOperatorIndexConst(gpaddr(c'packed_int64_array_operator_index_const')) }
		packed_string_array_operator_index:                 unsafe { GDExtensionInterfacePackedStringArrayOperatorIndex(gpaddr(c'packed_string_array_operator_index')) }
		packed_string_array_operator_index_const:           unsafe { GDExtensionInterfacePackedStringArrayOperatorIndexConst(gpaddr(c'packed_string_array_operator_index_const')) }
		packed_vector2_array_operator_index:                unsafe { GDExtensionInterfacePackedVector2ArrayOperatorIndex(gpaddr(c'packed_vector2_array_operator_index')) }
		packed_vector2_array_operator_index_const:          unsafe { GDExtensionInterfacePackedVector2ArrayOperatorIndexConst(gpaddr(c'packed_vector2_array_operator_index_const')) }
		packed_vector3_array_operator_index:                unsafe { GDExtensionInterfacePackedVector3ArrayOperatorIndex(gpaddr(c'packed_vector3_array_operator_index')) }
		packed_vector3_array_operator_index_const:          unsafe { GDExtensionInterfacePackedVector3ArrayOperatorIndexConst(gpaddr(c'packed_vector3_array_operator_index_const')) }
		array_operator_index:                               unsafe { GDExtensionInterfaceArrayOperatorIndex(gpaddr(c'array_operator_index')) }
		array_operator_index_const:                         unsafe { GDExtensionInterfaceArrayOperatorIndexConst(gpaddr(c'array_operator_index_const')) }
		array_ref:                                          unsafe { GDExtensionInterfaceArrayRef(gpaddr(c'array_ref')) }
		array_set_typed:                                    unsafe { GDExtensionInterfaceArraySetTyped(gpaddr(c'array_set_typed')) }
		dictionary_operator_index:                          unsafe { GDExtensionInterfaceDictionaryOperatorIndex(gpaddr(c'dictionary_operator_index')) }
		dictionary_operator_index_const:                    unsafe { GDExtensionInterfaceDictionaryOperatorIndexConst(gpaddr(c'dictionary_operator_index_const')) }
		object_method_bind_call:                            unsafe { GDExtensionInterfaceObjectMethodBindCall(gpaddr(c'object_method_bind_call')) }
		object_method_bind_ptrcall:                         unsafe { GDExtensionInterfaceObjectMethodBindPtrcall(gpaddr(c'object_method_bind_ptrcall')) }
		object_destroy:                                     unsafe { GDExtensionInterfaceObjectDestroy(gpaddr(c'object_destroy')) }
		global_get_singleton:                               unsafe { GDExtensionInterfaceGlobalGetSingleton(gpaddr(c'global_get_singleton')) }
		object_get_instance_binding:                        unsafe { GDExtensionInterfaceObjectGetInstanceBinding(gpaddr(c'object_get_instance_binding')) }
		object_set_instance_binding:                        unsafe { GDExtensionInterfaceObjectSetInstanceBinding(gpaddr(c'object_set_instance_binding')) }
		object_set_instance:                                unsafe { GDExtensionInterfaceObjectSetInstance(gpaddr(c'object_set_instance')) }
		object_get_class_name:                              unsafe { GDExtensionInterfaceObjectGetClassName(gpaddr(c'object_get_class_name')) }
		object_cast_to:                                     unsafe { GDExtensionInterfaceObjectCastTo(gpaddr(c'object_cast_to')) }
		object_get_instance_from_id:                        unsafe { GDExtensionInterfaceObjectGetInstanceFromId(gpaddr(c'object_get_instance_from_id')) }
		object_get_instance_id:                             unsafe { GDExtensionInterfaceObjectGetInstanceId(gpaddr(c'object_get_instance_id')) }
		ref_get_object:                                     unsafe { GDExtensionInterfaceRefGetObject(gpaddr(c'ref_get_object')) }
		ref_set_object:                                     unsafe { GDExtensionInterfaceRefSetObject(gpaddr(c'ref_set_object')) }
		script_instance_create:                             unsafe { GDExtensionInterfaceScriptInstanceCreate(gpaddr(c'script_instance_create')) }
		script_instance_create3:                            unsafe { GDExtensionInterfaceScriptInstanceCreate3(gpaddr(c'script_instance_create3')) }
		callable_custom_create2:                            unsafe { GDExtensionInterfaceCallableCustomCreate2(gpaddr(c'callable_custom_create2')) }
		classdb_construct_object:                           unsafe { GDExtensionInterfaceClassdbConstructObject(gpaddr(c'classdb_construct_object')) }
		classdb_construct_object2:                          unsafe { GDExtensionInterfaceClassdbConstructObject2(gpaddr(c'classdb_construct_object2')) }
		classdb_get_method_bind:                            unsafe { GDExtensionInterfaceClassdbGetMethodBind(gpaddr(c'classdb_get_method_bind')) }
		classdb_get_class_tag:                              unsafe { GDExtensionInterfaceClassdbGetClassTag(gpaddr(c'classdb_get_class_tag')) }
		classdb_register_extension_class:                   unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass(gpaddr(c'classdb_register_extension_class')) }
		classdb_register_extension_class2:                  unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass2(gpaddr(c'classdb_register_extension_class2')) }
		classdb_register_extension_class3:                  unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass3(gpaddr(c'classdb_register_extension_class3')) }
		classdb_register_extension_class4:                  unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass4(gpaddr(c'classdb_register_extension_class4')) }
		classdb_register_extension_class_method:            unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassMethod(gpaddr(c'classdb_register_extension_class_method')) }
		classdb_register_extension_class_integer_constant:  unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassIntegerConstant(gpaddr(c'classdb_register_extension_class_integer_constant')) }
		classdb_register_extension_class_property:          unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassProperty(gpaddr(c'classdb_register_extension_class_property')) }
		classdb_register_extension_class_property_group:    unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassPropertyGroup(gpaddr(c'classdb_register_extension_class_property_group')) }
		classdb_register_extension_class_property_subgroup: unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassPropertySubgroup(gpaddr(c'classdb_register_extension_class_property_subgroup')) }
		classdb_register_extension_class_signal:            unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassSignal(gpaddr(c'classdb_register_extension_class_signal')) }
		classdb_unregister_extension_class:                 unsafe { GDExtensionInterfaceClassdbUnregisterExtensionClass(gpaddr(c'classdb_unregister_extension_class')) }
		get_library_path:                                   unsafe { GDExtensionInterfaceGetLibraryPath(gpaddr(c'get_library_path')) }
		editor_add_plugin:                                  unsafe { GDExtensionInterfaceEditorAddPlugin(gpaddr(c'editor_add_plugin')) }
		editor_remove_plugin:                               unsafe { GDExtensionInterfaceEditorRemovePlugin(gpaddr(c'editor_remove_plugin')) }
	}

	gdf = &GDExt{
		GDExtensionInterfaceFunctions: interface_fns
	}
	prepare_binds()

	return gdf
}

pub struct InfoVersion {
	name        string
	description string
	major       int
	minor       int
	patch       int
	full        string
	time        time.Time
	status      string
	build       string
}

pub struct Info {
	version InfoVersion
	godot   InfoVersion
}

__global (
	class_bind_ptrs   []voidptr
	builtin_bind_ptrs []voidptr
	utility_bind_ptrs []voidptr
)

pub fn prepare_binds() {
	if class_bind_ptrs.len != class_bind_count {
		class_bind_ptrs = []voidptr{len: class_bind_count}
	}
	if builtin_bind_ptrs.len != builtin_bind_count {
		builtin_bind_ptrs = []voidptr{len: builtin_bind_count}
	}
	if utility_bind_ptrs.len != utility_bind_count {
		utility_bind_ptrs = []voidptr{len: utility_bind_count}
	}
}

fn class_method_bind(index int, class_name string, method string, hash i64) voidptr {
	prepare_binds()
	cached := class_bind_ptrs[index]
	if cached != unsafe { nil } {
		return cached
	}
	classname := StringName.new(class_name)
	fnname := StringName.new(method)
	defer {
		classname.deinit()
		fnname.deinit()
	}
	ptr := gdf.classdb_get_method_bind(&classname, &fnname, hash)
	class_bind_ptrs[index] = ptr
	return ptr
}

fn builtin_method_bind(index int, typ GDExtensionVariantType, method string, hash i64) GDExtensionPtrBuiltInMethod {
	prepare_binds()
	cached := builtin_bind_ptrs[index]
	if cached != unsafe { nil } {
		return GDExtensionPtrBuiltInMethod(cached)
	}
	fnname := StringName.new(method)
	defer {
		fnname.deinit()
	}
	ptr := gdf.variant_get_ptr_builtin_method(typ, voidptr(&fnname), hash)
	builtin_bind_ptrs[index] = voidptr(ptr)
	return ptr
}

fn utility_function(index int, method string, hash i64) GDExtensionPtrUtilityFunction {
	prepare_binds()
	cached := utility_bind_ptrs[index]
	if cached != unsafe { nil } {
		return GDExtensionPtrUtilityFunction(cached)
	}
	fnname := StringName.new(method)
	defer {
		fnname.deinit()
	}
	ptr := gdf.variant_get_ptr_utility_function(voidptr(&fnname), hash)
	utility_bind_ptrs[index] = voidptr(ptr)
	return ptr
}
