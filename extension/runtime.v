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

module godot

import time

__global (
	gdf = &GDExt(unsafe { nil })
)

pub struct GDExt {
	GDExtensionInterfaceFunctions
}

// Version of the interface dump schema this module was generated from.
pub const gdextension_interface_format_version = 1

// Oldest Godot 4.x minor version the bindings support.
pub const godot_base_minor = 5

// target_godot_minor is the Godot 4.x minor version the bindings were built
// for: the newest `-d godot_4_N` flag given, or 5 by default.
pub fn target_godot_minor() int {
	$if godot_4_7 ? {
		return 7
	}
	$if godot_4_6 ? {
		return 6
	}
	return godot_base_minor
}

// setup loads the GDExtension interface and keeps it for later calls.
pub fn setup(gpaddr fn (&i8) GDExtensionInterfaceFunctionPtr, clp GDExtensionClassLibraryPtr) &GDExt {
	C._vinit(0, unsafe { nil })

	mut interface_fns := &GDExtensionInterfaceFunctions{
		gpaddr: gpaddr
		clp:    clp
	}
	interface_fns.get_godot_version = unsafe { GDExtensionInterfaceGetGodotVersion(gpaddr(c'get_godot_version')) }
	interface_fns.get_godot_version2 = unsafe { GDExtensionInterfaceGetGodotVersion2(gpaddr(c'get_godot_version2')) }
	interface_fns.mem_alloc = unsafe { GDExtensionInterfaceMemAlloc(gpaddr(c'mem_alloc')) }
	interface_fns.mem_realloc = unsafe { GDExtensionInterfaceMemRealloc(gpaddr(c'mem_realloc')) }
	interface_fns.mem_free = unsafe { GDExtensionInterfaceMemFree(gpaddr(c'mem_free')) }
	interface_fns.print_error = unsafe { GDExtensionInterfacePrintError(gpaddr(c'print_error')) }
	interface_fns.print_error_with_message = unsafe { GDExtensionInterfacePrintErrorWithMessage(gpaddr(c'print_error_with_message')) }
	interface_fns.print_warning = unsafe { GDExtensionInterfacePrintWarning(gpaddr(c'print_warning')) }
	interface_fns.print_warning_with_message = unsafe { GDExtensionInterfacePrintWarningWithMessage(gpaddr(c'print_warning_with_message')) }
	interface_fns.print_script_error = unsafe { GDExtensionInterfacePrintScriptError(gpaddr(c'print_script_error')) }
	interface_fns.print_script_error_with_message = unsafe { GDExtensionInterfacePrintScriptErrorWithMessage(gpaddr(c'print_script_error_with_message')) }
	interface_fns.get_native_struct_size = unsafe { GDExtensionInterfaceGetNativeStructSize(gpaddr(c'get_native_struct_size')) }
	interface_fns.variant_new_copy = unsafe { GDExtensionInterfaceVariantNewCopy(gpaddr(c'variant_new_copy')) }
	interface_fns.variant_new_nil = unsafe { GDExtensionInterfaceVariantNewNil(gpaddr(c'variant_new_nil')) }
	interface_fns.variant_destroy = unsafe { GDExtensionInterfaceVariantDestroy(gpaddr(c'variant_destroy')) }
	interface_fns.variant_call = unsafe { GDExtensionInterfaceVariantCall(gpaddr(c'variant_call')) }
	interface_fns.variant_call_static = unsafe { GDExtensionInterfaceVariantCallStatic(gpaddr(c'variant_call_static')) }
	interface_fns.variant_evaluate = unsafe { GDExtensionInterfaceVariantEvaluate(gpaddr(c'variant_evaluate')) }
	interface_fns.variant_set = unsafe { GDExtensionInterfaceVariantSet(gpaddr(c'variant_set')) }
	interface_fns.variant_set_named = unsafe { GDExtensionInterfaceVariantSetNamed(gpaddr(c'variant_set_named')) }
	interface_fns.variant_set_keyed = unsafe { GDExtensionInterfaceVariantSetKeyed(gpaddr(c'variant_set_keyed')) }
	interface_fns.variant_set_indexed = unsafe { GDExtensionInterfaceVariantSetIndexed(gpaddr(c'variant_set_indexed')) }
	interface_fns.variant_get = unsafe { GDExtensionInterfaceVariantGet(gpaddr(c'variant_get')) }
	interface_fns.variant_get_named = unsafe { GDExtensionInterfaceVariantGetNamed(gpaddr(c'variant_get_named')) }
	interface_fns.variant_get_keyed = unsafe { GDExtensionInterfaceVariantGetKeyed(gpaddr(c'variant_get_keyed')) }
	interface_fns.variant_get_indexed = unsafe { GDExtensionInterfaceVariantGetIndexed(gpaddr(c'variant_get_indexed')) }
	interface_fns.variant_iter_init = unsafe { GDExtensionInterfaceVariantIterInit(gpaddr(c'variant_iter_init')) }
	interface_fns.variant_iter_next = unsafe { GDExtensionInterfaceVariantIterNext(gpaddr(c'variant_iter_next')) }
	interface_fns.variant_iter_get = unsafe { GDExtensionInterfaceVariantIterGet(gpaddr(c'variant_iter_get')) }
	interface_fns.variant_hash = unsafe { GDExtensionInterfaceVariantHash(gpaddr(c'variant_hash')) }
	interface_fns.variant_recursive_hash = unsafe { GDExtensionInterfaceVariantRecursiveHash(gpaddr(c'variant_recursive_hash')) }
	interface_fns.variant_hash_compare = unsafe { GDExtensionInterfaceVariantHashCompare(gpaddr(c'variant_hash_compare')) }
	interface_fns.variant_booleanize = unsafe { GDExtensionInterfaceVariantBooleanize(gpaddr(c'variant_booleanize')) }
	interface_fns.variant_duplicate = unsafe { GDExtensionInterfaceVariantDuplicate(gpaddr(c'variant_duplicate')) }
	interface_fns.variant_stringify = unsafe { GDExtensionInterfaceVariantStringify(gpaddr(c'variant_stringify')) }
	interface_fns.variant_get_type = unsafe { GDExtensionInterfaceVariantGetType(gpaddr(c'variant_get_type')) }
	interface_fns.variant_has_method = unsafe { GDExtensionInterfaceVariantHasMethod(gpaddr(c'variant_has_method')) }
	interface_fns.variant_has_member = unsafe { GDExtensionInterfaceVariantHasMember(gpaddr(c'variant_has_member')) }
	interface_fns.variant_has_key = unsafe { GDExtensionInterfaceVariantHasKey(gpaddr(c'variant_has_key')) }
	interface_fns.variant_get_object_instance_id = unsafe { GDExtensionInterfaceVariantGetObjectInstanceId(gpaddr(c'variant_get_object_instance_id')) }
	interface_fns.variant_get_type_name = unsafe { GDExtensionInterfaceVariantGetTypeName(gpaddr(c'variant_get_type_name')) }
	interface_fns.variant_can_convert = unsafe { GDExtensionInterfaceVariantCanConvert(gpaddr(c'variant_can_convert')) }
	interface_fns.variant_can_convert_strict = unsafe { GDExtensionInterfaceVariantCanConvertStrict(gpaddr(c'variant_can_convert_strict')) }
	interface_fns.get_variant_from_type_constructor = unsafe { GDExtensionInterfaceGetVariantFromTypeConstructor(gpaddr(c'get_variant_from_type_constructor')) }
	interface_fns.get_variant_to_type_constructor = unsafe { GDExtensionInterfaceGetVariantToTypeConstructor(gpaddr(c'get_variant_to_type_constructor')) }
	interface_fns.variant_get_ptr_internal_getter = unsafe { GDExtensionInterfaceVariantGetPtrInternalGetter(gpaddr(c'variant_get_ptr_internal_getter')) }
	interface_fns.variant_get_ptr_operator_evaluator = unsafe { GDExtensionInterfaceVariantGetPtrOperatorEvaluator(gpaddr(c'variant_get_ptr_operator_evaluator')) }
	interface_fns.variant_get_ptr_builtin_method = unsafe { GDExtensionInterfaceVariantGetPtrBuiltinMethod(gpaddr(c'variant_get_ptr_builtin_method')) }
	interface_fns.variant_get_ptr_constructor = unsafe { GDExtensionInterfaceVariantGetPtrConstructor(gpaddr(c'variant_get_ptr_constructor')) }
	interface_fns.variant_get_ptr_destructor = unsafe { GDExtensionInterfaceVariantGetPtrDestructor(gpaddr(c'variant_get_ptr_destructor')) }
	interface_fns.variant_construct = unsafe { GDExtensionInterfaceVariantConstruct(gpaddr(c'variant_construct')) }
	interface_fns.variant_get_ptr_setter = unsafe { GDExtensionInterfaceVariantGetPtrSetter(gpaddr(c'variant_get_ptr_setter')) }
	interface_fns.variant_get_ptr_getter = unsafe { GDExtensionInterfaceVariantGetPtrGetter(gpaddr(c'variant_get_ptr_getter')) }
	interface_fns.variant_get_ptr_indexed_setter = unsafe { GDExtensionInterfaceVariantGetPtrIndexedSetter(gpaddr(c'variant_get_ptr_indexed_setter')) }
	interface_fns.variant_get_ptr_indexed_getter = unsafe { GDExtensionInterfaceVariantGetPtrIndexedGetter(gpaddr(c'variant_get_ptr_indexed_getter')) }
	interface_fns.variant_get_ptr_keyed_setter = unsafe { GDExtensionInterfaceVariantGetPtrKeyedSetter(gpaddr(c'variant_get_ptr_keyed_setter')) }
	interface_fns.variant_get_ptr_keyed_getter = unsafe { GDExtensionInterfaceVariantGetPtrKeyedGetter(gpaddr(c'variant_get_ptr_keyed_getter')) }
	interface_fns.variant_get_ptr_keyed_checker = unsafe { GDExtensionInterfaceVariantGetPtrKeyedChecker(gpaddr(c'variant_get_ptr_keyed_checker')) }
	interface_fns.variant_get_constant_value = unsafe { GDExtensionInterfaceVariantGetConstantValue(gpaddr(c'variant_get_constant_value')) }
	interface_fns.variant_get_ptr_utility_function = unsafe { GDExtensionInterfaceVariantGetPtrUtilityFunction(gpaddr(c'variant_get_ptr_utility_function')) }
	interface_fns.string_new_with_latin1_chars = unsafe { GDExtensionInterfaceStringNewWithLatin1Chars(gpaddr(c'string_new_with_latin1_chars')) }
	interface_fns.string_new_with_utf8_chars = unsafe { GDExtensionInterfaceStringNewWithUtf8Chars(gpaddr(c'string_new_with_utf8_chars')) }
	interface_fns.string_new_with_utf16_chars = unsafe { GDExtensionInterfaceStringNewWithUtf16Chars(gpaddr(c'string_new_with_utf16_chars')) }
	interface_fns.string_new_with_utf32_chars = unsafe { GDExtensionInterfaceStringNewWithUtf32Chars(gpaddr(c'string_new_with_utf32_chars')) }
	interface_fns.string_new_with_wide_chars = unsafe { GDExtensionInterfaceStringNewWithWideChars(gpaddr(c'string_new_with_wide_chars')) }
	interface_fns.string_new_with_latin1_chars_and_len = unsafe { GDExtensionInterfaceStringNewWithLatin1CharsAndLen(gpaddr(c'string_new_with_latin1_chars_and_len')) }
	interface_fns.string_new_with_utf8_chars_and_len = unsafe { GDExtensionInterfaceStringNewWithUtf8CharsAndLen(gpaddr(c'string_new_with_utf8_chars_and_len')) }
	interface_fns.string_new_with_utf8_chars_and_len2 = unsafe { GDExtensionInterfaceStringNewWithUtf8CharsAndLen2(gpaddr(c'string_new_with_utf8_chars_and_len2')) }
	interface_fns.string_new_with_utf16_chars_and_len = unsafe { GDExtensionInterfaceStringNewWithUtf16CharsAndLen(gpaddr(c'string_new_with_utf16_chars_and_len')) }
	interface_fns.string_new_with_utf16_chars_and_len2 = unsafe { GDExtensionInterfaceStringNewWithUtf16CharsAndLen2(gpaddr(c'string_new_with_utf16_chars_and_len2')) }
	interface_fns.string_new_with_utf32_chars_and_len = unsafe { GDExtensionInterfaceStringNewWithUtf32CharsAndLen(gpaddr(c'string_new_with_utf32_chars_and_len')) }
	interface_fns.string_new_with_wide_chars_and_len = unsafe { GDExtensionInterfaceStringNewWithWideCharsAndLen(gpaddr(c'string_new_with_wide_chars_and_len')) }
	interface_fns.string_to_latin1_chars = unsafe { GDExtensionInterfaceStringToLatin1Chars(gpaddr(c'string_to_latin1_chars')) }
	interface_fns.string_to_utf8_chars = unsafe { GDExtensionInterfaceStringToUtf8Chars(gpaddr(c'string_to_utf8_chars')) }
	interface_fns.string_to_utf16_chars = unsafe { GDExtensionInterfaceStringToUtf16Chars(gpaddr(c'string_to_utf16_chars')) }
	interface_fns.string_to_utf32_chars = unsafe { GDExtensionInterfaceStringToUtf32Chars(gpaddr(c'string_to_utf32_chars')) }
	interface_fns.string_to_wide_chars = unsafe { GDExtensionInterfaceStringToWideChars(gpaddr(c'string_to_wide_chars')) }
	interface_fns.string_operator_index = unsafe { GDExtensionInterfaceStringOperatorIndex(gpaddr(c'string_operator_index')) }
	interface_fns.string_operator_index_const = unsafe { GDExtensionInterfaceStringOperatorIndexConst(gpaddr(c'string_operator_index_const')) }
	interface_fns.string_operator_plus_eq_string = unsafe { GDExtensionInterfaceStringOperatorPlusEqString(gpaddr(c'string_operator_plus_eq_string')) }
	interface_fns.string_operator_plus_eq_char = unsafe { GDExtensionInterfaceStringOperatorPlusEqChar(gpaddr(c'string_operator_plus_eq_char')) }
	interface_fns.string_operator_plus_eq_cstr = unsafe { GDExtensionInterfaceStringOperatorPlusEqCstr(gpaddr(c'string_operator_plus_eq_cstr')) }
	interface_fns.string_operator_plus_eq_wcstr = unsafe { GDExtensionInterfaceStringOperatorPlusEqWcstr(gpaddr(c'string_operator_plus_eq_wcstr')) }
	interface_fns.string_operator_plus_eq_c32str = unsafe { GDExtensionInterfaceStringOperatorPlusEqC32str(gpaddr(c'string_operator_plus_eq_c32str')) }
	interface_fns.string_resize = unsafe { GDExtensionInterfaceStringResize(gpaddr(c'string_resize')) }
	interface_fns.string_name_new_with_latin1_chars = unsafe { GDExtensionInterfaceStringNameNewWithLatin1Chars(gpaddr(c'string_name_new_with_latin1_chars')) }
	interface_fns.string_name_new_with_utf8_chars = unsafe { GDExtensionInterfaceStringNameNewWithUtf8Chars(gpaddr(c'string_name_new_with_utf8_chars')) }
	interface_fns.string_name_new_with_utf8_chars_and_len = unsafe { GDExtensionInterfaceStringNameNewWithUtf8CharsAndLen(gpaddr(c'string_name_new_with_utf8_chars_and_len')) }
	interface_fns.xml_parser_open_buffer = unsafe { GDExtensionInterfaceXmlParserOpenBuffer(gpaddr(c'xml_parser_open_buffer')) }
	interface_fns.file_access_store_buffer = unsafe { GDExtensionInterfaceFileAccessStoreBuffer(gpaddr(c'file_access_store_buffer')) }
	interface_fns.file_access_get_buffer = unsafe { GDExtensionInterfaceFileAccessGetBuffer(gpaddr(c'file_access_get_buffer')) }
	interface_fns.image_ptrw = unsafe { GDExtensionInterfaceImagePtrw(gpaddr(c'image_ptrw')) }
	interface_fns.image_ptr = unsafe { GDExtensionInterfaceImagePtr(gpaddr(c'image_ptr')) }
	interface_fns.worker_thread_pool_add_native_group_task = unsafe { GDExtensionInterfaceWorkerThreadPoolAddNativeGroupTask(gpaddr(c'worker_thread_pool_add_native_group_task')) }
	interface_fns.worker_thread_pool_add_native_task = unsafe { GDExtensionInterfaceWorkerThreadPoolAddNativeTask(gpaddr(c'worker_thread_pool_add_native_task')) }
	interface_fns.packed_byte_array_operator_index = unsafe { GDExtensionInterfacePackedByteArrayOperatorIndex(gpaddr(c'packed_byte_array_operator_index')) }
	interface_fns.packed_byte_array_operator_index_const = unsafe { GDExtensionInterfacePackedByteArrayOperatorIndexConst(gpaddr(c'packed_byte_array_operator_index_const')) }
	interface_fns.packed_float32_array_operator_index = unsafe { GDExtensionInterfacePackedFloat32ArrayOperatorIndex(gpaddr(c'packed_float32_array_operator_index')) }
	interface_fns.packed_float32_array_operator_index_const = unsafe { GDExtensionInterfacePackedFloat32ArrayOperatorIndexConst(gpaddr(c'packed_float32_array_operator_index_const')) }
	interface_fns.packed_float64_array_operator_index = unsafe { GDExtensionInterfacePackedFloat64ArrayOperatorIndex(gpaddr(c'packed_float64_array_operator_index')) }
	interface_fns.packed_float64_array_operator_index_const = unsafe { GDExtensionInterfacePackedFloat64ArrayOperatorIndexConst(gpaddr(c'packed_float64_array_operator_index_const')) }
	interface_fns.packed_int32_array_operator_index = unsafe { GDExtensionInterfacePackedInt32ArrayOperatorIndex(gpaddr(c'packed_int32_array_operator_index')) }
	interface_fns.packed_int32_array_operator_index_const = unsafe { GDExtensionInterfacePackedInt32ArrayOperatorIndexConst(gpaddr(c'packed_int32_array_operator_index_const')) }
	interface_fns.packed_int64_array_operator_index = unsafe { GDExtensionInterfacePackedInt64ArrayOperatorIndex(gpaddr(c'packed_int64_array_operator_index')) }
	interface_fns.packed_int64_array_operator_index_const = unsafe { GDExtensionInterfacePackedInt64ArrayOperatorIndexConst(gpaddr(c'packed_int64_array_operator_index_const')) }
	interface_fns.packed_string_array_operator_index = unsafe { GDExtensionInterfacePackedStringArrayOperatorIndex(gpaddr(c'packed_string_array_operator_index')) }
	interface_fns.packed_string_array_operator_index_const = unsafe { GDExtensionInterfacePackedStringArrayOperatorIndexConst(gpaddr(c'packed_string_array_operator_index_const')) }
	interface_fns.packed_vector2_array_operator_index = unsafe { GDExtensionInterfacePackedVector2ArrayOperatorIndex(gpaddr(c'packed_vector2_array_operator_index')) }
	interface_fns.packed_vector2_array_operator_index_const = unsafe { GDExtensionInterfacePackedVector2ArrayOperatorIndexConst(gpaddr(c'packed_vector2_array_operator_index_const')) }
	interface_fns.packed_vector3_array_operator_index = unsafe { GDExtensionInterfacePackedVector3ArrayOperatorIndex(gpaddr(c'packed_vector3_array_operator_index')) }
	interface_fns.packed_vector3_array_operator_index_const = unsafe { GDExtensionInterfacePackedVector3ArrayOperatorIndexConst(gpaddr(c'packed_vector3_array_operator_index_const')) }
	interface_fns.packed_vector4_array_operator_index = unsafe { GDExtensionInterfacePackedVector4ArrayOperatorIndex(gpaddr(c'packed_vector4_array_operator_index')) }
	interface_fns.packed_vector4_array_operator_index_const = unsafe { GDExtensionInterfacePackedVector4ArrayOperatorIndexConst(gpaddr(c'packed_vector4_array_operator_index_const')) }
	interface_fns.packed_color_array_operator_index = unsafe { GDExtensionInterfacePackedColorArrayOperatorIndex(gpaddr(c'packed_color_array_operator_index')) }
	interface_fns.packed_color_array_operator_index_const = unsafe { GDExtensionInterfacePackedColorArrayOperatorIndexConst(gpaddr(c'packed_color_array_operator_index_const')) }
	interface_fns.array_operator_index = unsafe { GDExtensionInterfaceArrayOperatorIndex(gpaddr(c'array_operator_index')) }
	interface_fns.array_operator_index_const = unsafe { GDExtensionInterfaceArrayOperatorIndexConst(gpaddr(c'array_operator_index_const')) }
	interface_fns.array_ref = unsafe { GDExtensionInterfaceArrayRef(gpaddr(c'array_ref')) }
	interface_fns.array_set_typed = unsafe { GDExtensionInterfaceArraySetTyped(gpaddr(c'array_set_typed')) }
	interface_fns.dictionary_operator_index = unsafe { GDExtensionInterfaceDictionaryOperatorIndex(gpaddr(c'dictionary_operator_index')) }
	interface_fns.dictionary_operator_index_const = unsafe { GDExtensionInterfaceDictionaryOperatorIndexConst(gpaddr(c'dictionary_operator_index_const')) }
	interface_fns.dictionary_set_typed = unsafe { GDExtensionInterfaceDictionarySetTyped(gpaddr(c'dictionary_set_typed')) }
	interface_fns.object_method_bind_call = unsafe { GDExtensionInterfaceObjectMethodBindCall(gpaddr(c'object_method_bind_call')) }
	interface_fns.object_method_bind_ptrcall = unsafe { GDExtensionInterfaceObjectMethodBindPtrcall(gpaddr(c'object_method_bind_ptrcall')) }
	interface_fns.object_destroy = unsafe { GDExtensionInterfaceObjectDestroy(gpaddr(c'object_destroy')) }
	interface_fns.global_get_singleton = unsafe { GDExtensionInterfaceGlobalGetSingleton(gpaddr(c'global_get_singleton')) }
	interface_fns.object_get_instance_binding = unsafe { GDExtensionInterfaceObjectGetInstanceBinding(gpaddr(c'object_get_instance_binding')) }
	interface_fns.object_set_instance_binding = unsafe { GDExtensionInterfaceObjectSetInstanceBinding(gpaddr(c'object_set_instance_binding')) }
	interface_fns.object_free_instance_binding = unsafe { GDExtensionInterfaceObjectFreeInstanceBinding(gpaddr(c'object_free_instance_binding')) }
	interface_fns.object_set_instance = unsafe { GDExtensionInterfaceObjectSetInstance(gpaddr(c'object_set_instance')) }
	interface_fns.object_get_class_name = unsafe { GDExtensionInterfaceObjectGetClassName(gpaddr(c'object_get_class_name')) }
	interface_fns.object_cast_to = unsafe { GDExtensionInterfaceObjectCastTo(gpaddr(c'object_cast_to')) }
	interface_fns.object_get_instance_from_id = unsafe { GDExtensionInterfaceObjectGetInstanceFromId(gpaddr(c'object_get_instance_from_id')) }
	interface_fns.object_get_instance_id = unsafe { GDExtensionInterfaceObjectGetInstanceId(gpaddr(c'object_get_instance_id')) }
	interface_fns.object_has_script_method = unsafe { GDExtensionInterfaceObjectHasScriptMethod(gpaddr(c'object_has_script_method')) }
	interface_fns.object_call_script_method = unsafe { GDExtensionInterfaceObjectCallScriptMethod(gpaddr(c'object_call_script_method')) }
	interface_fns.ref_get_object = unsafe { GDExtensionInterfaceRefGetObject(gpaddr(c'ref_get_object')) }
	interface_fns.ref_set_object = unsafe { GDExtensionInterfaceRefSetObject(gpaddr(c'ref_set_object')) }
	interface_fns.script_instance_create = unsafe { GDExtensionInterfaceScriptInstanceCreate(gpaddr(c'script_instance_create')) }
	interface_fns.script_instance_create2 = unsafe { GDExtensionInterfaceScriptInstanceCreate2(gpaddr(c'script_instance_create2')) }
	interface_fns.script_instance_create3 = unsafe { GDExtensionInterfaceScriptInstanceCreate3(gpaddr(c'script_instance_create3')) }
	interface_fns.placeholder_script_instance_create = unsafe { GDExtensionInterfacePlaceholderScriptInstanceCreate(gpaddr(c'placeholder_script_instance_create')) }
	interface_fns.placeholder_script_instance_update = unsafe { GDExtensionInterfacePlaceholderScriptInstanceUpdate(gpaddr(c'placeholder_script_instance_update')) }
	interface_fns.object_get_script_instance = unsafe { GDExtensionInterfaceObjectGetScriptInstance(gpaddr(c'object_get_script_instance')) }
	interface_fns.object_set_script_instance = unsafe { GDExtensionInterfaceObjectSetScriptInstance(gpaddr(c'object_set_script_instance')) }
	interface_fns.callable_custom_create = unsafe { GDExtensionInterfaceCallableCustomCreate(gpaddr(c'callable_custom_create')) }
	interface_fns.callable_custom_create2 = unsafe { GDExtensionInterfaceCallableCustomCreate2(gpaddr(c'callable_custom_create2')) }
	interface_fns.callable_custom_get_userdata = unsafe { GDExtensionInterfaceCallableCustomGetUserdata(gpaddr(c'callable_custom_get_userdata')) }
	interface_fns.classdb_construct_object = unsafe { GDExtensionInterfaceClassdbConstructObject(gpaddr(c'classdb_construct_object')) }
	interface_fns.classdb_construct_object2 = unsafe { GDExtensionInterfaceClassdbConstructObject2(gpaddr(c'classdb_construct_object2')) }
	interface_fns.classdb_get_method_bind = unsafe { GDExtensionInterfaceClassdbGetMethodBind(gpaddr(c'classdb_get_method_bind')) }
	interface_fns.classdb_get_class_tag = unsafe { GDExtensionInterfaceClassdbGetClassTag(gpaddr(c'classdb_get_class_tag')) }
	interface_fns.classdb_register_extension_class = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass(gpaddr(c'classdb_register_extension_class')) }
	interface_fns.classdb_register_extension_class2 = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass2(gpaddr(c'classdb_register_extension_class2')) }
	interface_fns.classdb_register_extension_class3 = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass3(gpaddr(c'classdb_register_extension_class3')) }
	interface_fns.classdb_register_extension_class4 = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass4(gpaddr(c'classdb_register_extension_class4')) }
	interface_fns.classdb_register_extension_class5 = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass5(gpaddr(c'classdb_register_extension_class5')) }
	interface_fns.classdb_register_extension_class_method = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassMethod(gpaddr(c'classdb_register_extension_class_method')) }
	interface_fns.classdb_register_extension_class_virtual_method = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassVirtualMethod(gpaddr(c'classdb_register_extension_class_virtual_method')) }
	interface_fns.classdb_register_extension_class_integer_constant = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassIntegerConstant(gpaddr(c'classdb_register_extension_class_integer_constant')) }
	interface_fns.classdb_register_extension_class_property = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassProperty(gpaddr(c'classdb_register_extension_class_property')) }
	interface_fns.classdb_register_extension_class_property_indexed = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassPropertyIndexed(gpaddr(c'classdb_register_extension_class_property_indexed')) }
	interface_fns.classdb_register_extension_class_property_group = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassPropertyGroup(gpaddr(c'classdb_register_extension_class_property_group')) }
	interface_fns.classdb_register_extension_class_property_subgroup = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassPropertySubgroup(gpaddr(c'classdb_register_extension_class_property_subgroup')) }
	interface_fns.classdb_register_extension_class_signal = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClassSignal(gpaddr(c'classdb_register_extension_class_signal')) }
	interface_fns.classdb_unregister_extension_class = unsafe { GDExtensionInterfaceClassdbUnregisterExtensionClass(gpaddr(c'classdb_unregister_extension_class')) }
	interface_fns.get_library_path = unsafe { GDExtensionInterfaceGetLibraryPath(gpaddr(c'get_library_path')) }
	interface_fns.editor_add_plugin = unsafe { GDExtensionInterfaceEditorAddPlugin(gpaddr(c'editor_add_plugin')) }
	interface_fns.editor_remove_plugin = unsafe { GDExtensionInterfaceEditorRemovePlugin(gpaddr(c'editor_remove_plugin')) }
	interface_fns.editor_help_load_xml_from_utf8_chars = unsafe { GDExtensionInterfaceEditorHelpLoadXmlFromUtf8Chars(gpaddr(c'editor_help_load_xml_from_utf8_chars')) }
	interface_fns.editor_help_load_xml_from_utf8_chars_and_len = unsafe { GDExtensionInterfaceEditorHelpLoadXmlFromUtf8CharsAndLen(gpaddr(c'editor_help_load_xml_from_utf8_chars_and_len')) }
	interface_fns.editor_register_get_classes_used_callback = unsafe { GDExtensionInterfaceEditorRegisterGetClassesUsedCallback(gpaddr(c'editor_register_get_classes_used_callback')) }
	interface_fns.register_main_loop_callbacks = unsafe { GDExtensionInterfaceRegisterMainLoopCallbacks(gpaddr(c'register_main_loop_callbacks')) }
	$if godot_4_6 ?|| godot_4_7 ? {
		interface_fns.mem_alloc2 = unsafe { GDExtensionInterfaceMemAlloc2(gpaddr(c'mem_alloc2')) }
		interface_fns.mem_realloc2 = unsafe { GDExtensionInterfaceMemRealloc2(gpaddr(c'mem_realloc2')) }
		interface_fns.mem_free2 = unsafe { GDExtensionInterfaceMemFree2(gpaddr(c'mem_free2')) }
	}
	$if godot_4_7 ? {
		interface_fns.variant_get_type_by_name = unsafe { GDExtensionInterfaceVariantGetTypeByName(gpaddr(c'variant_get_type_by_name')) }
		interface_fns.classdb_construct_object3 = unsafe { GDExtensionInterfaceClassdbConstructObject3(gpaddr(c'classdb_construct_object3')) }
		interface_fns.classdb_register_extension_class6 = unsafe { GDExtensionInterfaceClassdbRegisterExtensionClass6(gpaddr(c'classdb_register_extension_class6')) }
	}

	gdf = &GDExt{
		GDExtensionInterfaceFunctions: interface_fns
	}
	check_interface(interface_fns)
	prepare_binds()

	return gdf
}

// check_interface verifies the running Godot against the bindings: its version
// must be at least the build target and every required entry point must exist.
fn check_interface(fns &GDExtensionInterfaceFunctions) {
	if fns.gpaddr == unsafe { nil } {
		panic('GDExtension interface: get_proc_address is null')
	}
	if fns.clp == unsafe { nil } {
		panic('GDExtension interface: class library pointer is null')
	}
	check_target_version(fns)
	if fns.get_godot_version2 == unsafe { nil } {
		panic('GDExtension interface: missing entry point get_godot_version2 (ABI mismatch with running Godot)')
	}
	if fns.print_error == unsafe { nil } {
		panic('GDExtension interface: missing entry point print_error (ABI mismatch with running Godot)')
	}
	if fns.print_error_with_message == unsafe { nil } {
		panic('GDExtension interface: missing entry point print_error_with_message (ABI mismatch with running Godot)')
	}
	if fns.print_warning == unsafe { nil } {
		panic('GDExtension interface: missing entry point print_warning (ABI mismatch with running Godot)')
	}
	if fns.print_warning_with_message == unsafe { nil } {
		panic('GDExtension interface: missing entry point print_warning_with_message (ABI mismatch with running Godot)')
	}
	if fns.print_script_error == unsafe { nil } {
		panic('GDExtension interface: missing entry point print_script_error (ABI mismatch with running Godot)')
	}
	if fns.print_script_error_with_message == unsafe { nil } {
		panic('GDExtension interface: missing entry point print_script_error_with_message (ABI mismatch with running Godot)')
	}
	if fns.get_native_struct_size == unsafe { nil } {
		panic('GDExtension interface: missing entry point get_native_struct_size (ABI mismatch with running Godot)')
	}
	if fns.variant_new_copy == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_new_copy (ABI mismatch with running Godot)')
	}
	if fns.variant_new_nil == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_new_nil (ABI mismatch with running Godot)')
	}
	if fns.variant_destroy == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_destroy (ABI mismatch with running Godot)')
	}
	if fns.variant_call == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_call (ABI mismatch with running Godot)')
	}
	if fns.variant_call_static == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_call_static (ABI mismatch with running Godot)')
	}
	if fns.variant_evaluate == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_evaluate (ABI mismatch with running Godot)')
	}
	if fns.variant_set == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_set (ABI mismatch with running Godot)')
	}
	if fns.variant_set_named == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_set_named (ABI mismatch with running Godot)')
	}
	if fns.variant_set_keyed == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_set_keyed (ABI mismatch with running Godot)')
	}
	if fns.variant_set_indexed == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_set_indexed (ABI mismatch with running Godot)')
	}
	if fns.variant_get == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get (ABI mismatch with running Godot)')
	}
	if fns.variant_get_named == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_named (ABI mismatch with running Godot)')
	}
	if fns.variant_get_keyed == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_keyed (ABI mismatch with running Godot)')
	}
	if fns.variant_get_indexed == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_indexed (ABI mismatch with running Godot)')
	}
	if fns.variant_iter_init == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_iter_init (ABI mismatch with running Godot)')
	}
	if fns.variant_iter_next == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_iter_next (ABI mismatch with running Godot)')
	}
	if fns.variant_iter_get == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_iter_get (ABI mismatch with running Godot)')
	}
	if fns.variant_hash == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_hash (ABI mismatch with running Godot)')
	}
	if fns.variant_recursive_hash == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_recursive_hash (ABI mismatch with running Godot)')
	}
	if fns.variant_hash_compare == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_hash_compare (ABI mismatch with running Godot)')
	}
	if fns.variant_booleanize == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_booleanize (ABI mismatch with running Godot)')
	}
	if fns.variant_duplicate == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_duplicate (ABI mismatch with running Godot)')
	}
	if fns.variant_stringify == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_stringify (ABI mismatch with running Godot)')
	}
	if fns.variant_get_type == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_type (ABI mismatch with running Godot)')
	}
	if fns.variant_has_method == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_has_method (ABI mismatch with running Godot)')
	}
	if fns.variant_has_member == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_has_member (ABI mismatch with running Godot)')
	}
	if fns.variant_has_key == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_has_key (ABI mismatch with running Godot)')
	}
	if fns.variant_get_object_instance_id == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_object_instance_id (ABI mismatch with running Godot)')
	}
	if fns.variant_get_type_name == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_type_name (ABI mismatch with running Godot)')
	}
	if fns.variant_can_convert == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_can_convert (ABI mismatch with running Godot)')
	}
	if fns.variant_can_convert_strict == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_can_convert_strict (ABI mismatch with running Godot)')
	}
	if fns.get_variant_from_type_constructor == unsafe { nil } {
		panic('GDExtension interface: missing entry point get_variant_from_type_constructor (ABI mismatch with running Godot)')
	}
	if fns.get_variant_to_type_constructor == unsafe { nil } {
		panic('GDExtension interface: missing entry point get_variant_to_type_constructor (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_internal_getter == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_internal_getter (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_operator_evaluator == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_operator_evaluator (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_builtin_method == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_builtin_method (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_constructor == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_constructor (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_destructor == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_destructor (ABI mismatch with running Godot)')
	}
	if fns.variant_construct == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_construct (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_setter == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_setter (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_getter == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_getter (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_indexed_setter == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_indexed_setter (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_indexed_getter == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_indexed_getter (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_keyed_setter == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_keyed_setter (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_keyed_getter == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_keyed_getter (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_keyed_checker == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_keyed_checker (ABI mismatch with running Godot)')
	}
	if fns.variant_get_constant_value == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_constant_value (ABI mismatch with running Godot)')
	}
	if fns.variant_get_ptr_utility_function == unsafe { nil } {
		panic('GDExtension interface: missing entry point variant_get_ptr_utility_function (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_latin1_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_latin1_chars (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_utf8_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_utf8_chars (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_utf16_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_utf16_chars (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_utf32_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_utf32_chars (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_wide_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_wide_chars (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_latin1_chars_and_len == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_latin1_chars_and_len (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_utf8_chars_and_len2 == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_utf8_chars_and_len2 (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_utf16_chars_and_len2 == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_utf16_chars_and_len2 (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_utf32_chars_and_len == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_utf32_chars_and_len (ABI mismatch with running Godot)')
	}
	if fns.string_new_with_wide_chars_and_len == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_new_with_wide_chars_and_len (ABI mismatch with running Godot)')
	}
	if fns.string_to_latin1_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_to_latin1_chars (ABI mismatch with running Godot)')
	}
	if fns.string_to_utf8_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_to_utf8_chars (ABI mismatch with running Godot)')
	}
	if fns.string_to_utf16_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_to_utf16_chars (ABI mismatch with running Godot)')
	}
	if fns.string_to_utf32_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_to_utf32_chars (ABI mismatch with running Godot)')
	}
	if fns.string_to_wide_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_to_wide_chars (ABI mismatch with running Godot)')
	}
	if fns.string_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_operator_index (ABI mismatch with running Godot)')
	}
	if fns.string_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.string_operator_plus_eq_string == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_operator_plus_eq_string (ABI mismatch with running Godot)')
	}
	if fns.string_operator_plus_eq_char == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_operator_plus_eq_char (ABI mismatch with running Godot)')
	}
	if fns.string_operator_plus_eq_cstr == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_operator_plus_eq_cstr (ABI mismatch with running Godot)')
	}
	if fns.string_operator_plus_eq_wcstr == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_operator_plus_eq_wcstr (ABI mismatch with running Godot)')
	}
	if fns.string_operator_plus_eq_c32str == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_operator_plus_eq_c32str (ABI mismatch with running Godot)')
	}
	if fns.string_resize == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_resize (ABI mismatch with running Godot)')
	}
	if fns.string_name_new_with_latin1_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_name_new_with_latin1_chars (ABI mismatch with running Godot)')
	}
	if fns.string_name_new_with_utf8_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_name_new_with_utf8_chars (ABI mismatch with running Godot)')
	}
	if fns.string_name_new_with_utf8_chars_and_len == unsafe { nil } {
		panic('GDExtension interface: missing entry point string_name_new_with_utf8_chars_and_len (ABI mismatch with running Godot)')
	}
	if fns.xml_parser_open_buffer == unsafe { nil } {
		panic('GDExtension interface: missing entry point xml_parser_open_buffer (ABI mismatch with running Godot)')
	}
	if fns.file_access_store_buffer == unsafe { nil } {
		panic('GDExtension interface: missing entry point file_access_store_buffer (ABI mismatch with running Godot)')
	}
	if fns.file_access_get_buffer == unsafe { nil } {
		panic('GDExtension interface: missing entry point file_access_get_buffer (ABI mismatch with running Godot)')
	}
	if fns.image_ptrw == unsafe { nil } {
		panic('GDExtension interface: missing entry point image_ptrw (ABI mismatch with running Godot)')
	}
	if fns.image_ptr == unsafe { nil } {
		panic('GDExtension interface: missing entry point image_ptr (ABI mismatch with running Godot)')
	}
	if fns.worker_thread_pool_add_native_group_task == unsafe { nil } {
		panic('GDExtension interface: missing entry point worker_thread_pool_add_native_group_task (ABI mismatch with running Godot)')
	}
	if fns.worker_thread_pool_add_native_task == unsafe { nil } {
		panic('GDExtension interface: missing entry point worker_thread_pool_add_native_task (ABI mismatch with running Godot)')
	}
	if fns.packed_byte_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_byte_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_byte_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_byte_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_float32_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_float32_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_float32_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_float32_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_float64_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_float64_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_float64_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_float64_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_int32_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_int32_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_int32_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_int32_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_int64_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_int64_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_int64_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_int64_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_string_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_string_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_string_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_string_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_vector2_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_vector2_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_vector2_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_vector2_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_vector3_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_vector3_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_vector3_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_vector3_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_vector4_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_vector4_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_vector4_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_vector4_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.packed_color_array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_color_array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.packed_color_array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point packed_color_array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.array_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point array_operator_index (ABI mismatch with running Godot)')
	}
	if fns.array_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point array_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.array_set_typed == unsafe { nil } {
		panic('GDExtension interface: missing entry point array_set_typed (ABI mismatch with running Godot)')
	}
	if fns.dictionary_operator_index == unsafe { nil } {
		panic('GDExtension interface: missing entry point dictionary_operator_index (ABI mismatch with running Godot)')
	}
	if fns.dictionary_operator_index_const == unsafe { nil } {
		panic('GDExtension interface: missing entry point dictionary_operator_index_const (ABI mismatch with running Godot)')
	}
	if fns.dictionary_set_typed == unsafe { nil } {
		panic('GDExtension interface: missing entry point dictionary_set_typed (ABI mismatch with running Godot)')
	}
	if fns.object_method_bind_call == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_method_bind_call (ABI mismatch with running Godot)')
	}
	if fns.object_method_bind_ptrcall == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_method_bind_ptrcall (ABI mismatch with running Godot)')
	}
	if fns.object_destroy == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_destroy (ABI mismatch with running Godot)')
	}
	if fns.global_get_singleton == unsafe { nil } {
		panic('GDExtension interface: missing entry point global_get_singleton (ABI mismatch with running Godot)')
	}
	if fns.object_get_instance_binding == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_get_instance_binding (ABI mismatch with running Godot)')
	}
	if fns.object_set_instance_binding == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_set_instance_binding (ABI mismatch with running Godot)')
	}
	if fns.object_free_instance_binding == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_free_instance_binding (ABI mismatch with running Godot)')
	}
	if fns.object_set_instance == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_set_instance (ABI mismatch with running Godot)')
	}
	if fns.object_get_class_name == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_get_class_name (ABI mismatch with running Godot)')
	}
	if fns.object_get_instance_from_id == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_get_instance_from_id (ABI mismatch with running Godot)')
	}
	if fns.object_get_instance_id == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_get_instance_id (ABI mismatch with running Godot)')
	}
	if fns.object_has_script_method == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_has_script_method (ABI mismatch with running Godot)')
	}
	if fns.object_call_script_method == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_call_script_method (ABI mismatch with running Godot)')
	}
	if fns.ref_get_object == unsafe { nil } {
		panic('GDExtension interface: missing entry point ref_get_object (ABI mismatch with running Godot)')
	}
	if fns.ref_set_object == unsafe { nil } {
		panic('GDExtension interface: missing entry point ref_set_object (ABI mismatch with running Godot)')
	}
	if fns.script_instance_create3 == unsafe { nil } {
		panic('GDExtension interface: missing entry point script_instance_create3 (ABI mismatch with running Godot)')
	}
	if fns.placeholder_script_instance_create == unsafe { nil } {
		panic('GDExtension interface: missing entry point placeholder_script_instance_create (ABI mismatch with running Godot)')
	}
	if fns.placeholder_script_instance_update == unsafe { nil } {
		panic('GDExtension interface: missing entry point placeholder_script_instance_update (ABI mismatch with running Godot)')
	}
	if fns.object_get_script_instance == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_get_script_instance (ABI mismatch with running Godot)')
	}
	if fns.object_set_script_instance == unsafe { nil } {
		panic('GDExtension interface: missing entry point object_set_script_instance (ABI mismatch with running Godot)')
	}
	if fns.callable_custom_create2 == unsafe { nil } {
		panic('GDExtension interface: missing entry point callable_custom_create2 (ABI mismatch with running Godot)')
	}
	if fns.callable_custom_get_userdata == unsafe { nil } {
		panic('GDExtension interface: missing entry point callable_custom_get_userdata (ABI mismatch with running Godot)')
	}
	if fns.classdb_get_method_bind == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_get_method_bind (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_method == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_method (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_virtual_method == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_virtual_method (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_integer_constant == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_integer_constant (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_property == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_property (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_property_indexed == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_property_indexed (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_property_group == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_property_group (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_property_subgroup == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_property_subgroup (ABI mismatch with running Godot)')
	}
	if fns.classdb_register_extension_class_signal == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_register_extension_class_signal (ABI mismatch with running Godot)')
	}
	if fns.classdb_unregister_extension_class == unsafe { nil } {
		panic('GDExtension interface: missing entry point classdb_unregister_extension_class (ABI mismatch with running Godot)')
	}
	if fns.get_library_path == unsafe { nil } {
		panic('GDExtension interface: missing entry point get_library_path (ABI mismatch with running Godot)')
	}
	if fns.editor_add_plugin == unsafe { nil } {
		panic('GDExtension interface: missing entry point editor_add_plugin (ABI mismatch with running Godot)')
	}
	if fns.editor_remove_plugin == unsafe { nil } {
		panic('GDExtension interface: missing entry point editor_remove_plugin (ABI mismatch with running Godot)')
	}
	if fns.editor_help_load_xml_from_utf8_chars == unsafe { nil } {
		panic('GDExtension interface: missing entry point editor_help_load_xml_from_utf8_chars (ABI mismatch with running Godot)')
	}
	if fns.editor_help_load_xml_from_utf8_chars_and_len == unsafe { nil } {
		panic('GDExtension interface: missing entry point editor_help_load_xml_from_utf8_chars_and_len (ABI mismatch with running Godot)')
	}
	if fns.editor_register_get_classes_used_callback == unsafe { nil } {
		panic('GDExtension interface: missing entry point editor_register_get_classes_used_callback (ABI mismatch with running Godot)')
	}
	if fns.register_main_loop_callbacks == unsafe { nil } {
		panic('GDExtension interface: missing entry point register_main_loop_callbacks (ABI mismatch with running Godot)')
	}
	$if godot_4_6 ?|| godot_4_7 ? {
		if fns.mem_alloc2 == unsafe { nil } {
			panic('GDExtension interface: missing entry point mem_alloc2 (ABI mismatch with running Godot)')
		}
		if fns.mem_realloc2 == unsafe { nil } {
			panic('GDExtension interface: missing entry point mem_realloc2 (ABI mismatch with running Godot)')
		}
		if fns.mem_free2 == unsafe { nil } {
			panic('GDExtension interface: missing entry point mem_free2 (ABI mismatch with running Godot)')
		}
	}
	$if godot_4_7 ? {
		if fns.variant_get_type_by_name == unsafe { nil } {
			panic('GDExtension interface: missing entry point variant_get_type_by_name (ABI mismatch with running Godot)')
		}
		if fns.classdb_construct_object3 == unsafe { nil } {
			panic('GDExtension interface: missing entry point classdb_construct_object3 (ABI mismatch with running Godot)')
		}
		if fns.classdb_register_extension_class6 == unsafe { nil } {
			panic('GDExtension interface: missing entry point classdb_register_extension_class6 (ABI mismatch with running Godot)')
		}
	}
}

fn check_target_version(fns &GDExtensionInterfaceFunctions) {
	mut version := GDExtensionGodotVersion2{}
	fns.get_godot_version2(&version)
	target := target_godot_minor()
	if version.major == 4 && int(version.minor) < target {
		panic('GDExtension interface: built for Godot 4.${target}+ but Godot 4.${version.minor} is running, rebuild without -d godot_4_${target}')
	}
	if version.major == 4 && int(version.minor) < godot_base_minor {
		panic('GDExtension interface: Godot 4.${version.minor} is older than the supported 4.${godot_base_minor}')
	}
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

// prepare_binds allocates the method-bind pointer tables.
pub fn prepare_binds() {
	if class_bind_ptrs.len != class_bind_count {
		class_bind_ptrs = []voidptr{len: class_bind_count, init: unsafe { nil }}
	}
	if builtin_bind_ptrs.len != builtin_bind_count {
		builtin_bind_ptrs = []voidptr{len: builtin_bind_count, init: unsafe { nil }}
	}
	if utility_bind_ptrs.len != utility_bind_count {
		utility_bind_ptrs = []voidptr{len: utility_bind_count, init: unsafe { nil }}
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
	ptr := gdf.variant_get_ptr_builtin_method(typ, &fnname, hash)
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
	ptr := gdf.variant_get_ptr_utility_function(&fnname, hash)
	utility_bind_ptrs[index] = voidptr(ptr)
	return ptr
}
