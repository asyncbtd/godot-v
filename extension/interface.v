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

// Generated from gdextension_interface.json — do not edit.

// GDWideChar is the C `wchar_t`: 16 bits on Windows, 32 bits elsewhere.
$if windows {
	pub type GDWideChar = u16
} $else {
	pub type GDWideChar = u32
}

// GDSize is the C `size_t`: pointer-sized.
$if x64 {
	pub type GDSize = u64
} $else {
	pub type GDSize = u32
}

pub enum GDExtensionVariantType {
	type_nil                = 0
	type_bool               = 1
	type_int                = 2
	type_float              = 3
	type_string             = 4
	type_vector2            = 5
	type_vector2i           = 6
	type_rect2              = 7
	type_rect2i             = 8
	type_vector3            = 9
	type_vector3i           = 10
	type_transform2d        = 11
	type_vector4            = 12
	type_vector4i           = 13
	type_plane              = 14
	type_quaternion         = 15
	type_aabb               = 16
	type_basis              = 17
	type_transform3d        = 18
	type_projection         = 19
	type_color              = 20
	type_stringname         = 21
	type_nodepath           = 22
	type_rid                = 23
	type_object             = 24
	type_callable           = 25
	type_signal             = 26
	type_dictionary         = 27
	type_array              = 28
	type_packedbytearray    = 29
	type_packedint32array   = 30
	type_packedint64array   = 31
	type_packedfloat32array = 32
	type_packedfloat64array = 33
	type_packedstringarray  = 34
	type_packedvector2array = 35
	type_packedvector3array = 36
	type_packedcolorarray   = 37
	type_packedvector4array = 38
	type_variantmax         = 39
}

pub enum GDExtensionVariantOperator {
	op_equal         = 0
	op_not_equal     = 1
	op_less          = 2
	op_less_equal    = 3
	op_greater       = 4
	op_greater_equal = 5
	op_add           = 6
	op_subtract      = 7
	op_multiply      = 8
	op_divide        = 9
	op_negate        = 10
	op_positive      = 11
	op_module        = 12
	op_power         = 13
	op_shift_left    = 14
	op_shift_right   = 15
	op_bit_and       = 16
	op_bit_or        = 17
	op_bit_xor       = 18
	op_bit_negate    = 19
	op_and           = 20
	op_or            = 21
	op_xor           = 22
	op_not           = 23
	op_in            = 24
	op_max           = 25
}

pub type GDExtensionUninitializedVariantPtr = voidptr

pub type GDExtensionUninitializedStringNamePtr = voidptr

pub type GDExtensionUninitializedStringPtr = voidptr

pub type GDExtensionObjectPtr = voidptr

pub type GDExtensionConstObjectPtr = voidptr

pub type GDExtensionUninitializedObjectPtr = voidptr

pub type GDExtensionTypePtr = voidptr

pub type GDExtensionConstTypePtr = voidptr

pub type GDExtensionUninitializedTypePtr = voidptr

pub type GDExtensionMethodBindPtr = voidptr

pub type GDExtensionInt = i64

pub type GDExtensionBool = u8

pub type GDObjectInstanceID = u64

pub type GDExtensionRefPtr = voidptr

pub type GDExtensionConstRefPtr = voidptr

pub enum GDExtensionCallErrorType {
	gdextension_call_ok                       = 0
	gdextension_call_error_invalid_method     = 1
	gdextension_call_error_invalid_argument   = 2
	gdextension_call_error_too_many_arguments = 3
	gdextension_call_error_too_few_arguments  = 4
	gdextension_call_error_instance_is_null   = 5
	gdextension_call_error_method_not_const   = 6
}

pub struct GDExtensionCallError {
pub mut:
	error    GDExtensionCallErrorType
	argument int
	expected int
}

pub type GDExtensionVariantFromTypeConstructorFunc = fn (GDExtensionUninitializedVariantPtr, GDExtensionTypePtr)

pub type GDExtensionTypeFromVariantConstructorFunc = fn (GDExtensionUninitializedTypePtr, &Variant)

pub type GDExtensionVariantGetInternalPtrFunc = fn (&Variant) voidptr

pub type GDExtensionPtrOperatorEvaluator = fn (p_left GDExtensionConstTypePtr, p_right GDExtensionConstTypePtr, r_result GDExtensionTypePtr)

pub type GDExtensionPtrBuiltInMethod = fn (p_base GDExtensionTypePtr, p_args &GDExtensionConstTypePtr, r_return GDExtensionTypePtr, p_argument_count int)

pub type GDExtensionPtrConstructor = fn (p_base GDExtensionUninitializedTypePtr, p_args &GDExtensionConstTypePtr)

pub type GDExtensionPtrDestructor = fn (p_base GDExtensionTypePtr)

pub type GDExtensionPtrSetter = fn (p_base GDExtensionTypePtr, p_value GDExtensionConstTypePtr)

pub type GDExtensionPtrGetter = fn (p_base GDExtensionConstTypePtr, r_value GDExtensionTypePtr)

pub type GDExtensionPtrIndexedSetter = fn (p_base GDExtensionTypePtr, p_index GDExtensionInt, p_value GDExtensionConstTypePtr)

pub type GDExtensionPtrIndexedGetter = fn (p_base GDExtensionConstTypePtr, p_index GDExtensionInt, r_value GDExtensionTypePtr)

pub type GDExtensionPtrKeyedSetter = fn (p_base GDExtensionTypePtr, p_key GDExtensionConstTypePtr, p_value GDExtensionConstTypePtr)

pub type GDExtensionPtrKeyedGetter = fn (p_base GDExtensionConstTypePtr, p_key GDExtensionConstTypePtr, r_value GDExtensionTypePtr)

pub type GDExtensionPtrKeyedChecker = fn (p_base &Variant, p_key &Variant) u32

pub type GDExtensionPtrUtilityFunction = fn (r_return GDExtensionTypePtr, p_args &GDExtensionConstTypePtr, p_argument_count int)

pub type GDExtensionClassConstructor = fn () GDExtensionObjectPtr

pub type GDExtensionInstanceBindingCreateCallback = fn (p_token voidptr, p_instance voidptr) voidptr

pub type GDExtensionInstanceBindingFreeCallback = fn (p_token voidptr, p_instance voidptr, p_binding voidptr)

pub type GDExtensionInstanceBindingReferenceCallback = fn (p_token voidptr, p_binding voidptr, p_reference GDExtensionBool) GDExtensionBool

pub struct GDExtensionInstanceBindingCallbacks {
pub mut:
	create_callback    GDExtensionInstanceBindingCreateCallback    = unsafe { nil }
	free_callback      GDExtensionInstanceBindingFreeCallback      = unsafe { nil }
	reference_callback GDExtensionInstanceBindingReferenceCallback = unsafe { nil }
}

pub type GDExtensionClassInstancePtr = voidptr

pub type GDExtensionClassSet = fn (p_instance GDExtensionClassInstancePtr, p_name &StringName, p_value &Variant) GDExtensionBool

pub type GDExtensionClassGet = fn (p_instance GDExtensionClassInstancePtr, p_name &StringName, r_ret &Variant) GDExtensionBool

pub type GDExtensionClassGetRID = fn (p_instance GDExtensionClassInstancePtr) u64

pub struct GDExtensionPropertyInfo {
pub mut:
	type_       GDExtensionVariantType
	name        &StringName = unsafe { nil }
	class_name  &StringName = unsafe { nil }
	hint        u32
	hint_string &String = unsafe { nil }
	usage       u32
}

pub struct GDExtensionMethodInfo {
pub mut:
	name                   &StringName = unsafe { nil }
	return_value           GDExtensionPropertyInfo
	flags                  u32
	id                     int
	argument_count         u32
	arguments              &GDExtensionPropertyInfo = unsafe { nil }
	default_argument_count u32
	default_arguments      &&Variant = unsafe { nil }
}

pub type GDExtensionClassGetPropertyList = fn (p_instance GDExtensionClassInstancePtr, r_count &u32) &GDExtensionPropertyInfo

// Deprecated since 4.3, use GDExtensionClassFreePropertyList2
pub type GDExtensionClassFreePropertyList = fn (p_instance GDExtensionClassInstancePtr, p_list &GDExtensionPropertyInfo)

pub type GDExtensionClassFreePropertyList2 = fn (p_instance GDExtensionClassInstancePtr, p_list &GDExtensionPropertyInfo, p_count u32)

pub type GDExtensionClassPropertyCanRevert = fn (p_instance GDExtensionClassInstancePtr, p_name &StringName) GDExtensionBool

pub type GDExtensionClassPropertyGetRevert = fn (p_instance GDExtensionClassInstancePtr, p_name &StringName, r_ret &Variant) GDExtensionBool

pub type GDExtensionClassValidateProperty = fn (p_instance GDExtensionClassInstancePtr, p_property &GDExtensionPropertyInfo) GDExtensionBool

// Deprecated since 4.2, use GDExtensionClassNotification2
pub type GDExtensionClassNotification = fn (p_instance GDExtensionClassInstancePtr, p_what int)

pub type GDExtensionClassNotification2 = fn (p_instance GDExtensionClassInstancePtr, p_what int, p_reversed GDExtensionBool)

pub type GDExtensionClassToString = fn (p_instance GDExtensionClassInstancePtr, r_is_valid &GDExtensionBool, p_out &String)

pub type GDExtensionClassReference = fn (p_instance GDExtensionClassInstancePtr)

pub type GDExtensionClassUnreference = fn (p_instance GDExtensionClassInstancePtr)

pub type GDExtensionClassCallVirtual = fn (p_instance GDExtensionClassInstancePtr, p_args &GDExtensionConstTypePtr, r_ret GDExtensionTypePtr)

// Deprecated since 4.4, use GDExtensionClassCreateInstance3
pub type GDExtensionClassCreateInstance = fn (p_class_userdata voidptr) GDExtensionObjectPtr

// Deprecated since 4.7, use GDExtensionClassCreateInstance3
pub type GDExtensionClassCreateInstance2 = fn (p_class_userdata voidptr, p_notify_postinitialize GDExtensionBool) GDExtensionObjectPtr

pub type GDExtensionClassCreateInstance3 = fn (p_class_userdata voidptr, p_notify_postinitialize GDExtensionBool) GDExtensionObjectPtr

pub type GDExtensionClassFreeInstance = fn (p_class_userdata voidptr, p_instance GDExtensionClassInstancePtr)

pub type GDExtensionClassRecreateInstance = fn (p_class_userdata voidptr, p_object GDExtensionObjectPtr) GDExtensionClassInstancePtr

// Deprecated since 4.4, use GDExtensionClassGetVirtual2
pub type GDExtensionClassGetVirtual = fn (p_class_userdata voidptr, p_name &StringName) GDExtensionClassCallVirtual

pub type GDExtensionClassGetVirtual2 = fn (p_class_userdata voidptr, p_name &StringName, p_hash u32) GDExtensionClassCallVirtual

// Deprecated since 4.4, use GDExtensionClassGetVirtualCallData2
pub type GDExtensionClassGetVirtualCallData = fn (p_class_userdata voidptr, p_name &StringName) voidptr

pub type GDExtensionClassGetVirtualCallData2 = fn (p_class_userdata voidptr, p_name &StringName, p_hash u32) voidptr

pub type GDExtensionClassCallVirtualWithData = fn (p_instance GDExtensionClassInstancePtr, p_name &StringName, p_virtual_call_userdata voidptr, p_args &GDExtensionConstTypePtr, r_ret GDExtensionTypePtr)

// Deprecated since 4.2, use GDExtensionClassCreationInfo6
pub struct GDExtensionClassCreationInfo {
pub mut:
	is_virtual               GDExtensionBool
	is_abstract              GDExtensionBool
	set_func                 GDExtensionClassSet               = unsafe { nil }
	get_func                 GDExtensionClassGet               = unsafe { nil }
	get_property_list_func   GDExtensionClassGetPropertyList   = unsafe { nil }
	free_property_list_func  GDExtensionClassFreePropertyList  = unsafe { nil }
	property_can_revert_func GDExtensionClassPropertyCanRevert = unsafe { nil }
	property_get_revert_func GDExtensionClassPropertyGetRevert = unsafe { nil }
	notification_func        GDExtensionClassNotification      = unsafe { nil }
	to_string_func           GDExtensionClassToString          = unsafe { nil }
	reference_func           GDExtensionClassReference         = unsafe { nil }
	unreference_func         GDExtensionClassUnreference       = unsafe { nil }
	create_instance_func     GDExtensionClassCreateInstance    = unsafe { nil }
	free_instance_func       GDExtensionClassFreeInstance      = unsafe { nil }
	get_virtual_func         GDExtensionClassGetVirtual        = unsafe { nil }
	get_rid_func             GDExtensionClassGetRID            = unsafe { nil }
	class_userdata           voidptr
}

// Deprecated since 4.3, use GDExtensionClassCreationInfo6
pub struct GDExtensionClassCreationInfo2 {
pub mut:
	is_virtual                  GDExtensionBool
	is_abstract                 GDExtensionBool
	is_exposed                  GDExtensionBool
	set_func                    GDExtensionClassSet                 = unsafe { nil }
	get_func                    GDExtensionClassGet                 = unsafe { nil }
	get_property_list_func      GDExtensionClassGetPropertyList     = unsafe { nil }
	free_property_list_func     GDExtensionClassFreePropertyList    = unsafe { nil }
	property_can_revert_func    GDExtensionClassPropertyCanRevert   = unsafe { nil }
	property_get_revert_func    GDExtensionClassPropertyGetRevert   = unsafe { nil }
	validate_property_func      GDExtensionClassValidateProperty    = unsafe { nil }
	notification_func           GDExtensionClassNotification2       = unsafe { nil }
	to_string_func              GDExtensionClassToString            = unsafe { nil }
	reference_func              GDExtensionClassReference           = unsafe { nil }
	unreference_func            GDExtensionClassUnreference         = unsafe { nil }
	create_instance_func        GDExtensionClassCreateInstance      = unsafe { nil }
	free_instance_func          GDExtensionClassFreeInstance        = unsafe { nil }
	recreate_instance_func      GDExtensionClassRecreateInstance    = unsafe { nil }
	get_virtual_func            GDExtensionClassGetVirtual          = unsafe { nil }
	get_virtual_call_data_func  GDExtensionClassGetVirtualCallData  = unsafe { nil }
	call_virtual_with_data_func GDExtensionClassCallVirtualWithData = unsafe { nil }
	get_rid_func                GDExtensionClassGetRID              = unsafe { nil }
	class_userdata              voidptr
}

// Deprecated since 4.4, use GDExtensionClassCreationInfo6
pub struct GDExtensionClassCreationInfo3 {
pub mut:
	is_virtual                  GDExtensionBool
	is_abstract                 GDExtensionBool
	is_exposed                  GDExtensionBool
	is_runtime                  GDExtensionBool
	set_func                    GDExtensionClassSet                 = unsafe { nil }
	get_func                    GDExtensionClassGet                 = unsafe { nil }
	get_property_list_func      GDExtensionClassGetPropertyList     = unsafe { nil }
	free_property_list_func     GDExtensionClassFreePropertyList2   = unsafe { nil }
	property_can_revert_func    GDExtensionClassPropertyCanRevert   = unsafe { nil }
	property_get_revert_func    GDExtensionClassPropertyGetRevert   = unsafe { nil }
	validate_property_func      GDExtensionClassValidateProperty    = unsafe { nil }
	notification_func           GDExtensionClassNotification2       = unsafe { nil }
	to_string_func              GDExtensionClassToString            = unsafe { nil }
	reference_func              GDExtensionClassReference           = unsafe { nil }
	unreference_func            GDExtensionClassUnreference         = unsafe { nil }
	create_instance_func        GDExtensionClassCreateInstance      = unsafe { nil }
	free_instance_func          GDExtensionClassFreeInstance        = unsafe { nil }
	recreate_instance_func      GDExtensionClassRecreateInstance    = unsafe { nil }
	get_virtual_func            GDExtensionClassGetVirtual          = unsafe { nil }
	get_virtual_call_data_func  GDExtensionClassGetVirtualCallData  = unsafe { nil }
	call_virtual_with_data_func GDExtensionClassCallVirtualWithData = unsafe { nil }
	get_rid_func                GDExtensionClassGetRID              = unsafe { nil }
	class_userdata              voidptr
}

// Deprecated since 4.5, use GDExtensionClassCreationInfo6
pub struct GDExtensionClassCreationInfo4 {
pub mut:
	is_virtual                  GDExtensionBool
	is_abstract                 GDExtensionBool
	is_exposed                  GDExtensionBool
	is_runtime                  GDExtensionBool
	icon_path                   &String                             = unsafe { nil }
	set_func                    GDExtensionClassSet                 = unsafe { nil }
	get_func                    GDExtensionClassGet                 = unsafe { nil }
	get_property_list_func      GDExtensionClassGetPropertyList     = unsafe { nil }
	free_property_list_func     GDExtensionClassFreePropertyList2   = unsafe { nil }
	property_can_revert_func    GDExtensionClassPropertyCanRevert   = unsafe { nil }
	property_get_revert_func    GDExtensionClassPropertyGetRevert   = unsafe { nil }
	validate_property_func      GDExtensionClassValidateProperty    = unsafe { nil }
	notification_func           GDExtensionClassNotification2       = unsafe { nil }
	to_string_func              GDExtensionClassToString            = unsafe { nil }
	reference_func              GDExtensionClassReference           = unsafe { nil }
	unreference_func            GDExtensionClassUnreference         = unsafe { nil }
	create_instance_func        GDExtensionClassCreateInstance2     = unsafe { nil }
	free_instance_func          GDExtensionClassFreeInstance        = unsafe { nil }
	recreate_instance_func      GDExtensionClassRecreateInstance    = unsafe { nil }
	get_virtual_func            GDExtensionClassGetVirtual2         = unsafe { nil }
	get_virtual_call_data_func  GDExtensionClassGetVirtualCallData2 = unsafe { nil }
	call_virtual_with_data_func GDExtensionClassCallVirtualWithData = unsafe { nil }
	class_userdata              voidptr
}

// Deprecated since 4.7, use GDExtensionClassCreationInfo6
pub type GDExtensionClassCreationInfo5 = GDExtensionClassCreationInfo4

pub struct GDExtensionClassCreationInfo6 {
pub mut:
	is_virtual                  GDExtensionBool
	is_abstract                 GDExtensionBool
	is_exposed                  GDExtensionBool
	is_runtime                  GDExtensionBool
	icon_path                   &String                             = unsafe { nil }
	set_func                    GDExtensionClassSet                 = unsafe { nil }
	get_func                    GDExtensionClassGet                 = unsafe { nil }
	get_property_list_func      GDExtensionClassGetPropertyList     = unsafe { nil }
	free_property_list_func     GDExtensionClassFreePropertyList2   = unsafe { nil }
	property_can_revert_func    GDExtensionClassPropertyCanRevert   = unsafe { nil }
	property_get_revert_func    GDExtensionClassPropertyGetRevert   = unsafe { nil }
	validate_property_func      GDExtensionClassValidateProperty    = unsafe { nil }
	notification_func           GDExtensionClassNotification2       = unsafe { nil }
	to_string_func              GDExtensionClassToString            = unsafe { nil }
	reference_func              GDExtensionClassReference           = unsafe { nil }
	unreference_func            GDExtensionClassUnreference         = unsafe { nil }
	create_instance_func        GDExtensionClassCreateInstance3     = unsafe { nil }
	free_instance_func          GDExtensionClassFreeInstance        = unsafe { nil }
	recreate_instance_func      GDExtensionClassRecreateInstance    = unsafe { nil }
	get_virtual_func            GDExtensionClassGetVirtual2         = unsafe { nil }
	get_virtual_call_data_func  GDExtensionClassGetVirtualCallData2 = unsafe { nil }
	call_virtual_with_data_func GDExtensionClassCallVirtualWithData = unsafe { nil }
	class_userdata              voidptr
}

pub type GDExtensionClassLibraryPtr = voidptr

pub type GDExtensionEditorGetClassesUsedCallback = fn (p_packed_string_array GDExtensionTypePtr)

@[_allow_multiple_values]
pub enum GDExtensionClassMethodFlags {
	gdextension_method_flag_normal           = 1
	gdextension_method_flag_editor           = 2
	gdextension_method_flag_const            = 4
	gdextension_method_flag_virtual          = 8
	gdextension_method_flag_vararg           = 16
	gdextension_method_flag_static           = 32
	gdextension_method_flag_virtual_required = 128
	gdextension_method_flags_default         = 1
}

pub enum GDExtensionClassMethodArgumentMetadata {
	gdextension_method_argument_metadata_none               = 0
	gdextension_method_argument_metadata_int_is_int8        = 1
	gdextension_method_argument_metadata_int_is_int16       = 2
	gdextension_method_argument_metadata_int_is_int32       = 3
	gdextension_method_argument_metadata_int_is_int64       = 4
	gdextension_method_argument_metadata_int_is_uint8       = 5
	gdextension_method_argument_metadata_int_is_uint16      = 6
	gdextension_method_argument_metadata_int_is_uint32      = 7
	gdextension_method_argument_metadata_int_is_uint64      = 8
	gdextension_method_argument_metadata_real_is_float      = 9
	gdextension_method_argument_metadata_real_is_double     = 10
	gdextension_method_argument_metadata_int_is_char16      = 11
	gdextension_method_argument_metadata_int_is_char32      = 12
	gdextension_method_argument_metadata_object_is_required = 13
}

pub type GDExtensionClassMethodCall = fn (method_userdata voidptr, p_instance GDExtensionClassInstancePtr, p_args &&Variant, p_argument_count GDExtensionInt, r_return &Variant, r_error &GDExtensionCallError)

pub type GDExtensionClassMethodValidatedCall = fn (method_userdata voidptr, p_instance GDExtensionClassInstancePtr, p_args &&Variant, r_return &Variant)

pub type GDExtensionClassMethodPtrCall = fn (method_userdata voidptr, p_instance GDExtensionClassInstancePtr, p_args &GDExtensionConstTypePtr, r_ret GDExtensionTypePtr)

pub struct GDExtensionClassMethodInfo {
pub mut:
	name                   &StringName = unsafe { nil }
	method_userdata        voidptr
	call_func              GDExtensionClassMethodCall    = unsafe { nil }
	ptrcall_func           GDExtensionClassMethodPtrCall = unsafe { nil }
	method_flags           u32
	has_return_value       GDExtensionBool
	return_value_info      &GDExtensionPropertyInfo = unsafe { nil }
	return_value_metadata  GDExtensionClassMethodArgumentMetadata
	argument_count         u32
	arguments_info         &GDExtensionPropertyInfo                = unsafe { nil }
	arguments_metadata     &GDExtensionClassMethodArgumentMetadata = unsafe { nil }
	default_argument_count u32
	default_arguments      &&Variant = unsafe { nil }
}

pub struct GDExtensionClassVirtualMethodInfo {
pub mut:
	name                  &StringName = unsafe { nil }
	method_flags          u32
	return_value          GDExtensionPropertyInfo
	return_value_metadata GDExtensionClassMethodArgumentMetadata
	argument_count        u32
	arguments             &GDExtensionPropertyInfo                = unsafe { nil }
	arguments_metadata    &GDExtensionClassMethodArgumentMetadata = unsafe { nil }
}

pub type GDExtensionCallableCustomCall = fn (callable_userdata voidptr, p_args &&Variant, p_argument_count GDExtensionInt, r_return &Variant, r_error &GDExtensionCallError)

pub type GDExtensionCallableCustomIsValid = fn (callable_userdata voidptr) GDExtensionBool

pub type GDExtensionCallableCustomFree = fn (callable_userdata voidptr)

pub type GDExtensionCallableCustomHash = fn (callable_userdata voidptr) u32

pub type GDExtensionCallableCustomEqual = fn (callable_userdata_a voidptr, callable_userdata_b voidptr) GDExtensionBool

pub type GDExtensionCallableCustomLessThan = fn (callable_userdata_a voidptr, callable_userdata_b voidptr) GDExtensionBool

pub type GDExtensionCallableCustomToString = fn (callable_userdata voidptr, r_is_valid &GDExtensionBool, r_out &String)

pub type GDExtensionCallableCustomGetArgumentCount = fn (callable_userdata voidptr, r_is_valid &GDExtensionBool) GDExtensionInt

// Deprecated since 4.3, use GDExtensionCallableCustomInfo2
pub struct GDExtensionCallableCustomInfo {
pub mut:
	callable_userdata voidptr
	token             voidptr
	object_id         GDObjectInstanceID
	call_func         GDExtensionCallableCustomCall     = unsafe { nil }
	is_valid_func     GDExtensionCallableCustomIsValid  = unsafe { nil }
	free_func         GDExtensionCallableCustomFree     = unsafe { nil }
	hash_func         GDExtensionCallableCustomHash     = unsafe { nil }
	equal_func        GDExtensionCallableCustomEqual    = unsafe { nil }
	less_than_func    GDExtensionCallableCustomLessThan = unsafe { nil }
	to_string_func    GDExtensionCallableCustomToString = unsafe { nil }
}

pub struct GDExtensionCallableCustomInfo2 {
pub mut:
	callable_userdata       voidptr
	token                   voidptr
	object_id               GDObjectInstanceID
	call_func               GDExtensionCallableCustomCall             = unsafe { nil }
	is_valid_func           GDExtensionCallableCustomIsValid          = unsafe { nil }
	free_func               GDExtensionCallableCustomFree             = unsafe { nil }
	hash_func               GDExtensionCallableCustomHash             = unsafe { nil }
	equal_func              GDExtensionCallableCustomEqual            = unsafe { nil }
	less_than_func          GDExtensionCallableCustomLessThan         = unsafe { nil }
	to_string_func          GDExtensionCallableCustomToString         = unsafe { nil }
	get_argument_count_func GDExtensionCallableCustomGetArgumentCount = unsafe { nil }
}

pub type GDExtensionScriptInstanceDataPtr = voidptr

pub type GDExtensionScriptInstanceSet = fn (p_instance GDExtensionScriptInstanceDataPtr, p_name &StringName, p_value &Variant) GDExtensionBool

pub type GDExtensionScriptInstanceGet = fn (p_instance GDExtensionScriptInstanceDataPtr, p_name &StringName, r_ret &Variant) GDExtensionBool

pub type GDExtensionScriptInstanceGetPropertyList = fn (p_instance GDExtensionScriptInstanceDataPtr, r_count &u32) &GDExtensionPropertyInfo

// Deprecated since 4.3, use GDExtensionScriptInstanceFreePropertyList2
pub type GDExtensionScriptInstanceFreePropertyList = fn (p_instance GDExtensionScriptInstanceDataPtr, p_list &GDExtensionPropertyInfo)

pub type GDExtensionScriptInstanceFreePropertyList2 = fn (p_instance GDExtensionScriptInstanceDataPtr, p_list &GDExtensionPropertyInfo, p_count u32)

pub type GDExtensionScriptInstanceGetClassCategory = fn (p_instance GDExtensionScriptInstanceDataPtr, p_class_category &GDExtensionPropertyInfo) GDExtensionBool

pub type GDExtensionScriptInstanceGetPropertyType = fn (p_instance GDExtensionScriptInstanceDataPtr, p_name &StringName, r_is_valid &GDExtensionBool) GDExtensionVariantType

pub type GDExtensionScriptInstanceValidateProperty = fn (p_instance GDExtensionScriptInstanceDataPtr, p_property &GDExtensionPropertyInfo) GDExtensionBool

pub type GDExtensionScriptInstancePropertyCanRevert = fn (p_instance GDExtensionScriptInstanceDataPtr, p_name &StringName) GDExtensionBool

pub type GDExtensionScriptInstancePropertyGetRevert = fn (p_instance GDExtensionScriptInstanceDataPtr, p_name &StringName, r_ret &Variant) GDExtensionBool

pub type GDExtensionScriptInstanceGetOwner = fn (p_instance GDExtensionScriptInstanceDataPtr) GDExtensionObjectPtr

pub type GDExtensionScriptInstancePropertyStateAdd = fn (p_name &StringName, p_value &Variant, p_userdata voidptr)

pub type GDExtensionScriptInstanceGetPropertyState = fn (p_instance GDExtensionScriptInstanceDataPtr, p_add_func GDExtensionScriptInstancePropertyStateAdd, p_userdata voidptr)

pub type GDExtensionScriptInstanceGetMethodList = fn (p_instance GDExtensionScriptInstanceDataPtr, r_count &u32) &GDExtensionMethodInfo

// Deprecated since 4.3, use GDExtensionScriptInstanceFreeMethodList2
pub type GDExtensionScriptInstanceFreeMethodList = fn (p_instance GDExtensionScriptInstanceDataPtr, p_list &GDExtensionMethodInfo)

pub type GDExtensionScriptInstanceFreeMethodList2 = fn (p_instance GDExtensionScriptInstanceDataPtr, p_list &GDExtensionMethodInfo, p_count u32)

pub type GDExtensionScriptInstanceHasMethod = fn (p_instance GDExtensionScriptInstanceDataPtr, p_name &StringName) GDExtensionBool

pub type GDExtensionScriptInstanceGetMethodArgumentCount = fn (p_instance GDExtensionScriptInstanceDataPtr, p_name &StringName, r_is_valid &GDExtensionBool) GDExtensionInt

pub type GDExtensionScriptInstanceCall = fn (p_self GDExtensionScriptInstanceDataPtr, p_method &StringName, p_args &&Variant, p_argument_count GDExtensionInt, r_return &Variant, r_error &GDExtensionCallError)

// Deprecated since 4.2, use GDExtensionScriptInstanceNotification2
pub type GDExtensionScriptInstanceNotification = fn (p_instance GDExtensionScriptInstanceDataPtr, p_what int)

pub type GDExtensionScriptInstanceNotification2 = fn (p_instance GDExtensionScriptInstanceDataPtr, p_what int, p_reversed GDExtensionBool)

pub type GDExtensionScriptInstanceToString = fn (p_instance GDExtensionScriptInstanceDataPtr, r_is_valid &GDExtensionBool, r_out &String)

pub type GDExtensionScriptInstanceRefCountIncremented = fn (p_instance GDExtensionScriptInstanceDataPtr)

pub type GDExtensionScriptInstanceRefCountDecremented = fn (p_instance GDExtensionScriptInstanceDataPtr) GDExtensionBool

pub type GDExtensionScriptInstanceGetScript = fn (p_instance GDExtensionScriptInstanceDataPtr) GDExtensionObjectPtr

pub type GDExtensionScriptInstanceIsPlaceholder = fn (p_instance GDExtensionScriptInstanceDataPtr) GDExtensionBool

pub type GDExtensionScriptLanguagePtr = voidptr

pub type GDExtensionScriptInstanceGetLanguage = fn (p_instance GDExtensionScriptInstanceDataPtr) GDExtensionScriptLanguagePtr

pub type GDExtensionScriptInstanceFree = fn (p_instance GDExtensionScriptInstanceDataPtr)

pub type GDExtensionScriptInstancePtr = voidptr

// Deprecated since 4.2, use GDExtensionScriptInstanceInfo3
pub struct GDExtensionScriptInstanceInfo {
pub mut:
	set_func                  GDExtensionScriptInstanceSet                 = unsafe { nil }
	get_func                  GDExtensionScriptInstanceGet                 = unsafe { nil }
	get_property_list_func    GDExtensionScriptInstanceGetPropertyList     = unsafe { nil }
	free_property_list_func   GDExtensionScriptInstanceFreePropertyList    = unsafe { nil }
	property_can_revert_func  GDExtensionScriptInstancePropertyCanRevert   = unsafe { nil }
	property_get_revert_func  GDExtensionScriptInstancePropertyGetRevert   = unsafe { nil }
	get_owner_func            GDExtensionScriptInstanceGetOwner            = unsafe { nil }
	get_property_state_func   GDExtensionScriptInstanceGetPropertyState    = unsafe { nil }
	get_method_list_func      GDExtensionScriptInstanceGetMethodList       = unsafe { nil }
	free_method_list_func     GDExtensionScriptInstanceFreeMethodList      = unsafe { nil }
	get_property_type_func    GDExtensionScriptInstanceGetPropertyType     = unsafe { nil }
	has_method_func           GDExtensionScriptInstanceHasMethod           = unsafe { nil }
	call_func                 GDExtensionScriptInstanceCall                = unsafe { nil }
	notification_func         GDExtensionScriptInstanceNotification        = unsafe { nil }
	to_string_func            GDExtensionScriptInstanceToString            = unsafe { nil }
	refcount_incremented_func GDExtensionScriptInstanceRefCountIncremented = unsafe { nil }
	refcount_decremented_func GDExtensionScriptInstanceRefCountDecremented = unsafe { nil }
	get_script_func           GDExtensionScriptInstanceGetScript           = unsafe { nil }
	is_placeholder_func       GDExtensionScriptInstanceIsPlaceholder       = unsafe { nil }
	set_fallback_func         GDExtensionScriptInstanceSet                 = unsafe { nil }
	get_fallback_func         GDExtensionScriptInstanceGet                 = unsafe { nil }
	get_language_func         GDExtensionScriptInstanceGetLanguage         = unsafe { nil }
	free_func                 GDExtensionScriptInstanceFree                = unsafe { nil }
}

// Deprecated since 4.3, use GDExtensionScriptInstanceInfo3
pub struct GDExtensionScriptInstanceInfo2 {
pub mut:
	set_func                  GDExtensionScriptInstanceSet                 = unsafe { nil }
	get_func                  GDExtensionScriptInstanceGet                 = unsafe { nil }
	get_property_list_func    GDExtensionScriptInstanceGetPropertyList     = unsafe { nil }
	free_property_list_func   GDExtensionScriptInstanceFreePropertyList    = unsafe { nil }
	get_class_category_func   GDExtensionScriptInstanceGetClassCategory    = unsafe { nil }
	property_can_revert_func  GDExtensionScriptInstancePropertyCanRevert   = unsafe { nil }
	property_get_revert_func  GDExtensionScriptInstancePropertyGetRevert   = unsafe { nil }
	get_owner_func            GDExtensionScriptInstanceGetOwner            = unsafe { nil }
	get_property_state_func   GDExtensionScriptInstanceGetPropertyState    = unsafe { nil }
	get_method_list_func      GDExtensionScriptInstanceGetMethodList       = unsafe { nil }
	free_method_list_func     GDExtensionScriptInstanceFreeMethodList      = unsafe { nil }
	get_property_type_func    GDExtensionScriptInstanceGetPropertyType     = unsafe { nil }
	validate_property_func    GDExtensionScriptInstanceValidateProperty    = unsafe { nil }
	has_method_func           GDExtensionScriptInstanceHasMethod           = unsafe { nil }
	call_func                 GDExtensionScriptInstanceCall                = unsafe { nil }
	notification_func         GDExtensionScriptInstanceNotification2       = unsafe { nil }
	to_string_func            GDExtensionScriptInstanceToString            = unsafe { nil }
	refcount_incremented_func GDExtensionScriptInstanceRefCountIncremented = unsafe { nil }
	refcount_decremented_func GDExtensionScriptInstanceRefCountDecremented = unsafe { nil }
	get_script_func           GDExtensionScriptInstanceGetScript           = unsafe { nil }
	is_placeholder_func       GDExtensionScriptInstanceIsPlaceholder       = unsafe { nil }
	set_fallback_func         GDExtensionScriptInstanceSet                 = unsafe { nil }
	get_fallback_func         GDExtensionScriptInstanceGet                 = unsafe { nil }
	get_language_func         GDExtensionScriptInstanceGetLanguage         = unsafe { nil }
	free_func                 GDExtensionScriptInstanceFree                = unsafe { nil }
}

pub struct GDExtensionScriptInstanceInfo3 {
pub mut:
	set_func                       GDExtensionScriptInstanceSet                    = unsafe { nil }
	get_func                       GDExtensionScriptInstanceGet                    = unsafe { nil }
	get_property_list_func         GDExtensionScriptInstanceGetPropertyList        = unsafe { nil }
	free_property_list_func        GDExtensionScriptInstanceFreePropertyList2      = unsafe { nil }
	get_class_category_func        GDExtensionScriptInstanceGetClassCategory       = unsafe { nil }
	property_can_revert_func       GDExtensionScriptInstancePropertyCanRevert      = unsafe { nil }
	property_get_revert_func       GDExtensionScriptInstancePropertyGetRevert      = unsafe { nil }
	get_owner_func                 GDExtensionScriptInstanceGetOwner               = unsafe { nil }
	get_property_state_func        GDExtensionScriptInstanceGetPropertyState       = unsafe { nil }
	get_method_list_func           GDExtensionScriptInstanceGetMethodList          = unsafe { nil }
	free_method_list_func          GDExtensionScriptInstanceFreeMethodList2        = unsafe { nil }
	get_property_type_func         GDExtensionScriptInstanceGetPropertyType        = unsafe { nil }
	validate_property_func         GDExtensionScriptInstanceValidateProperty       = unsafe { nil }
	has_method_func                GDExtensionScriptInstanceHasMethod              = unsafe { nil }
	get_method_argument_count_func GDExtensionScriptInstanceGetMethodArgumentCount = unsafe { nil }
	call_func                      GDExtensionScriptInstanceCall                   = unsafe { nil }
	notification_func              GDExtensionScriptInstanceNotification2          = unsafe { nil }
	to_string_func                 GDExtensionScriptInstanceToString               = unsafe { nil }
	refcount_incremented_func      GDExtensionScriptInstanceRefCountIncremented    = unsafe { nil }
	refcount_decremented_func      GDExtensionScriptInstanceRefCountDecremented    = unsafe { nil }
	get_script_func                GDExtensionScriptInstanceGetScript              = unsafe { nil }
	is_placeholder_func            GDExtensionScriptInstanceIsPlaceholder          = unsafe { nil }
	set_fallback_func              GDExtensionScriptInstanceSet                    = unsafe { nil }
	get_fallback_func              GDExtensionScriptInstanceGet                    = unsafe { nil }
	get_language_func              GDExtensionScriptInstanceGetLanguage            = unsafe { nil }
	free_func                      GDExtensionScriptInstanceFree                   = unsafe { nil }
}

pub type GDExtensionWorkerThreadPoolGroupTask = fn (voidptr, u32)

pub type GDExtensionWorkerThreadPoolTask = fn (voidptr)

pub enum GDExtensionInitializationLevel {
	gdextension_initialization_core      = 0
	gdextension_initialization_servers   = 1
	gdextension_initialization_scene     = 2
	gdextension_initialization_editor    = 3
	gdextension_max_initialization_level = 4
}

pub type GDExtensionInitializeCallback = fn (p_userdata voidptr, p_level GDExtensionInitializationLevel)

pub type GDExtensionDeinitializeCallback = fn (p_userdata voidptr, p_level GDExtensionInitializationLevel)

pub struct GDExtensionInitialization {
pub mut:
	minimum_initialization_level GDExtensionInitializationLevel
	userdata                     voidptr
	initialize                   GDExtensionInitializeCallback   = unsafe { nil }
	deinitialize                 GDExtensionDeinitializeCallback = unsafe { nil }
}

pub type GDExtensionInterfaceFunctionPtr = fn ()

pub type GDExtensionInterfaceGetProcAddress = fn (p_function_name &i8) GDExtensionInterfaceFunctionPtr

pub type GDExtensionInitializationFunction = fn (p_get_proc_address GDExtensionInterfaceGetProcAddress, p_library GDExtensionClassLibraryPtr, r_initialization &GDExtensionInitialization) GDExtensionBool

// Deprecated since 4.5, use GDExtensionGodotVersion2
pub struct GDExtensionGodotVersion {
pub mut:
	major   u32
	minor   u32
	patch   u32
	string_ &i8 = unsafe { nil }
}

pub struct GDExtensionGodotVersion2 {
pub mut:
	major     u32
	minor     u32
	patch     u32
	hex       u32
	status    &i8 = unsafe { nil }
	build     &i8 = unsafe { nil }
	hash      &i8 = unsafe { nil }
	timestamp u64
	string_   &i8 = unsafe { nil }
}

pub type GDExtensionMainLoopStartupCallback = fn ()

pub type GDExtensionMainLoopShutdownCallback = fn ()

pub type GDExtensionMainLoopFrameCallback = fn ()

pub struct GDExtensionMainLoopCallbacks {
pub mut:
	startup_func  GDExtensionMainLoopStartupCallback  = unsafe { nil }
	shutdown_func GDExtensionMainLoopShutdownCallback = unsafe { nil }
	frame_func    GDExtensionMainLoopFrameCallback    = unsafe { nil }
}

// Deprecated since 4.5, use get_godot_version2
pub type GDExtensionInterfaceGetGodotVersion = fn (r_godot_version &GDExtensionGodotVersion)

pub type GDExtensionInterfaceGetGodotVersion2 = fn (r_godot_version &GDExtensionGodotVersion2)

// Deprecated since 4.6, use mem_alloc2. Does not allow explicitly requesting padding.
pub type GDExtensionInterfaceMemAlloc = fn (p_bytes GDSize) voidptr

// Deprecated since 4.6, use mem_realloc2. Does not allow explicitly requesting padding.
pub type GDExtensionInterfaceMemRealloc = fn (p_ptr voidptr, p_bytes GDSize) voidptr

// Deprecated since 4.6, use mem_free2. Does not allow explicitly requesting padding.
pub type GDExtensionInterfaceMemFree = fn (p_ptr voidptr)

pub type GDExtensionInterfaceMemAlloc2 = fn (p_bytes GDSize, p_pad_align GDExtensionBool) voidptr

pub type GDExtensionInterfaceMemRealloc2 = fn (p_ptr voidptr, p_bytes GDSize, p_pad_align GDExtensionBool) voidptr

pub type GDExtensionInterfaceMemFree2 = fn (p_ptr voidptr, p_pad_align GDExtensionBool)

pub type GDExtensionInterfacePrintError = fn (p_description &i8, p_function &i8, p_file &i8, p_line int, p_editor_notify GDExtensionBool)

pub type GDExtensionInterfacePrintErrorWithMessage = fn (p_description &i8, p_message &i8, p_function &i8, p_file &i8, p_line int, p_editor_notify GDExtensionBool)

pub type GDExtensionInterfacePrintWarning = fn (p_description &i8, p_function &i8, p_file &i8, p_line int, p_editor_notify GDExtensionBool)

pub type GDExtensionInterfacePrintWarningWithMessage = fn (p_description &i8, p_message &i8, p_function &i8, p_file &i8, p_line int, p_editor_notify GDExtensionBool)

pub type GDExtensionInterfacePrintScriptError = fn (p_description &i8, p_function &i8, p_file &i8, p_line int, p_editor_notify GDExtensionBool)

pub type GDExtensionInterfacePrintScriptErrorWithMessage = fn (p_description &i8, p_message &i8, p_function &i8, p_file &i8, p_line int, p_editor_notify GDExtensionBool)

pub type GDExtensionInterfaceGetNativeStructSize = fn (p_name &StringName) u64

pub type GDExtensionInterfaceVariantNewCopy = fn (r_dest GDExtensionUninitializedVariantPtr, p_src &Variant)

pub type GDExtensionInterfaceVariantNewNil = fn (r_dest GDExtensionUninitializedVariantPtr)

pub type GDExtensionInterfaceVariantDestroy = fn (p_self &Variant)

pub type GDExtensionInterfaceVariantCall = fn (p_self &Variant, p_method &StringName, p_args &&Variant, p_argument_count GDExtensionInt, r_return GDExtensionUninitializedVariantPtr, r_error &GDExtensionCallError)

pub type GDExtensionInterfaceVariantCallStatic = fn (p_type GDExtensionVariantType, p_method &StringName, p_args &&Variant, p_argument_count GDExtensionInt, r_return GDExtensionUninitializedVariantPtr, r_error &GDExtensionCallError)

pub type GDExtensionInterfaceVariantEvaluate = fn (p_op GDExtensionVariantOperator, p_a &Variant, p_b &Variant, r_return GDExtensionUninitializedVariantPtr, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantSet = fn (p_self &Variant, p_key &Variant, p_value &Variant, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantSetNamed = fn (p_self &Variant, p_key &StringName, p_value &Variant, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantSetKeyed = fn (p_self &Variant, p_key &Variant, p_value &Variant, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantSetIndexed = fn (p_self &Variant, p_index GDExtensionInt, p_value &Variant, r_valid &GDExtensionBool, r_oob &GDExtensionBool)

pub type GDExtensionInterfaceVariantGet = fn (p_self &Variant, p_key &Variant, r_ret GDExtensionUninitializedVariantPtr, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantGetNamed = fn (p_self &Variant, p_key &StringName, r_ret GDExtensionUninitializedVariantPtr, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantGetKeyed = fn (p_self &Variant, p_key &Variant, r_ret GDExtensionUninitializedVariantPtr, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantGetIndexed = fn (p_self &Variant, p_index GDExtensionInt, r_ret GDExtensionUninitializedVariantPtr, r_valid &GDExtensionBool, r_oob &GDExtensionBool)

pub type GDExtensionInterfaceVariantIterInit = fn (p_self &Variant, r_iter GDExtensionUninitializedVariantPtr, r_valid &GDExtensionBool) GDExtensionBool

pub type GDExtensionInterfaceVariantIterNext = fn (p_self &Variant, r_iter &Variant, r_valid &GDExtensionBool) GDExtensionBool

pub type GDExtensionInterfaceVariantIterGet = fn (p_self &Variant, r_iter &Variant, r_ret GDExtensionUninitializedVariantPtr, r_valid &GDExtensionBool)

pub type GDExtensionInterfaceVariantHash = fn (p_self &Variant) GDExtensionInt

pub type GDExtensionInterfaceVariantRecursiveHash = fn (p_self &Variant, p_recursion_count GDExtensionInt) GDExtensionInt

pub type GDExtensionInterfaceVariantHashCompare = fn (p_self &Variant, p_other &Variant) GDExtensionBool

pub type GDExtensionInterfaceVariantBooleanize = fn (p_self &Variant) GDExtensionBool

pub type GDExtensionInterfaceVariantDuplicate = fn (p_self &Variant, r_ret &Variant, p_deep GDExtensionBool)

pub type GDExtensionInterfaceVariantStringify = fn (p_self &Variant, r_ret &String)

pub type GDExtensionInterfaceVariantGetType = fn (p_self &Variant) GDExtensionVariantType

pub type GDExtensionInterfaceVariantHasMethod = fn (p_self &Variant, p_method &StringName) GDExtensionBool

pub type GDExtensionInterfaceVariantHasMember = fn (p_type GDExtensionVariantType, p_member &StringName) GDExtensionBool

pub type GDExtensionInterfaceVariantHasKey = fn (p_self &Variant, p_key &Variant, r_valid &GDExtensionBool) GDExtensionBool

pub type GDExtensionInterfaceVariantGetObjectInstanceId = fn (p_self &Variant) GDObjectInstanceID

pub type GDExtensionInterfaceVariantGetTypeName = fn (p_type GDExtensionVariantType, r_name GDExtensionUninitializedStringPtr)

pub type GDExtensionInterfaceVariantGetTypeByName = fn (p_type_name &String) GDExtensionVariantType

pub type GDExtensionInterfaceVariantCanConvert = fn (p_from GDExtensionVariantType, p_to GDExtensionVariantType) GDExtensionBool

pub type GDExtensionInterfaceVariantCanConvertStrict = fn (p_from GDExtensionVariantType, p_to GDExtensionVariantType) GDExtensionBool

pub type GDExtensionInterfaceGetVariantFromTypeConstructor = fn (p_type GDExtensionVariantType) GDExtensionVariantFromTypeConstructorFunc

pub type GDExtensionInterfaceGetVariantToTypeConstructor = fn (p_type GDExtensionVariantType) GDExtensionTypeFromVariantConstructorFunc

pub type GDExtensionInterfaceVariantGetPtrInternalGetter = fn (p_type GDExtensionVariantType) GDExtensionVariantGetInternalPtrFunc

pub type GDExtensionInterfaceVariantGetPtrOperatorEvaluator = fn (p_operator GDExtensionVariantOperator, p_type_a GDExtensionVariantType, p_type_b GDExtensionVariantType) GDExtensionPtrOperatorEvaluator

pub type GDExtensionInterfaceVariantGetPtrBuiltinMethod = fn (p_type GDExtensionVariantType, p_method &StringName, p_hash GDExtensionInt) GDExtensionPtrBuiltInMethod

pub type GDExtensionInterfaceVariantGetPtrConstructor = fn (p_type GDExtensionVariantType, p_constructor int) GDExtensionPtrConstructor

pub type GDExtensionInterfaceVariantGetPtrDestructor = fn (p_type GDExtensionVariantType) GDExtensionPtrDestructor

pub type GDExtensionInterfaceVariantConstruct = fn (p_type GDExtensionVariantType, r_base GDExtensionUninitializedVariantPtr, p_args &&Variant, p_argument_count int, r_error &GDExtensionCallError)

pub type GDExtensionInterfaceVariantGetPtrSetter = fn (p_type GDExtensionVariantType, p_member &StringName) GDExtensionPtrSetter

pub type GDExtensionInterfaceVariantGetPtrGetter = fn (p_type GDExtensionVariantType, p_member &StringName) GDExtensionPtrGetter

pub type GDExtensionInterfaceVariantGetPtrIndexedSetter = fn (p_type GDExtensionVariantType) GDExtensionPtrIndexedSetter

pub type GDExtensionInterfaceVariantGetPtrIndexedGetter = fn (p_type GDExtensionVariantType) GDExtensionPtrIndexedGetter

pub type GDExtensionInterfaceVariantGetPtrKeyedSetter = fn (p_type GDExtensionVariantType) GDExtensionPtrKeyedSetter

pub type GDExtensionInterfaceVariantGetPtrKeyedGetter = fn (p_type GDExtensionVariantType) GDExtensionPtrKeyedGetter

pub type GDExtensionInterfaceVariantGetPtrKeyedChecker = fn (p_type GDExtensionVariantType) GDExtensionPtrKeyedChecker

pub type GDExtensionInterfaceVariantGetConstantValue = fn (p_type GDExtensionVariantType, p_constant &StringName, r_ret GDExtensionUninitializedVariantPtr)

pub type GDExtensionInterfaceVariantGetPtrUtilityFunction = fn (p_function &StringName, p_hash GDExtensionInt) GDExtensionPtrUtilityFunction

pub type GDExtensionInterfaceStringNewWithLatin1Chars = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &i8)

pub type GDExtensionInterfaceStringNewWithUtf8Chars = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &i8)

pub type GDExtensionInterfaceStringNewWithUtf16Chars = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &u16)

pub type GDExtensionInterfaceStringNewWithUtf32Chars = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &u32)

pub type GDExtensionInterfaceStringNewWithWideChars = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &GDWideChar)

pub type GDExtensionInterfaceStringNewWithLatin1CharsAndLen = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &i8, p_size GDExtensionInt)

// Deprecated since 4.3, use string_new_with_utf8_chars_and_len2
pub type GDExtensionInterfaceStringNewWithUtf8CharsAndLen = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &i8, p_size GDExtensionInt)

pub type GDExtensionInterfaceStringNewWithUtf8CharsAndLen2 = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &i8, p_size GDExtensionInt) GDExtensionInt

// Deprecated since 4.3, use string_new_with_utf16_chars_and_len2
pub type GDExtensionInterfaceStringNewWithUtf16CharsAndLen = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &u16, p_char_count GDExtensionInt)

pub type GDExtensionInterfaceStringNewWithUtf16CharsAndLen2 = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &u16, p_char_count GDExtensionInt, p_default_little_endian GDExtensionBool) GDExtensionInt

pub type GDExtensionInterfaceStringNewWithUtf32CharsAndLen = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &u32, p_char_count GDExtensionInt)

pub type GDExtensionInterfaceStringNewWithWideCharsAndLen = fn (r_dest GDExtensionUninitializedStringPtr, p_contents &GDWideChar, p_char_count GDExtensionInt)

pub type GDExtensionInterfaceStringToLatin1Chars = fn (p_self &String, r_text &i8, p_max_write_length GDExtensionInt) GDExtensionInt

pub type GDExtensionInterfaceStringToUtf8Chars = fn (p_self &String, r_text &i8, p_max_write_length GDExtensionInt) GDExtensionInt

pub type GDExtensionInterfaceStringToUtf16Chars = fn (p_self &String, r_text &u16, p_max_write_length GDExtensionInt) GDExtensionInt

pub type GDExtensionInterfaceStringToUtf32Chars = fn (p_self &String, r_text &u32, p_max_write_length GDExtensionInt) GDExtensionInt

pub type GDExtensionInterfaceStringToWideChars = fn (p_self &String, r_text &GDWideChar, p_max_write_length GDExtensionInt) GDExtensionInt

pub type GDExtensionInterfaceStringOperatorIndex = fn (p_self &String, p_index GDExtensionInt) &u32

pub type GDExtensionInterfaceStringOperatorIndexConst = fn (p_self &String, p_index GDExtensionInt) &u32

pub type GDExtensionInterfaceStringOperatorPlusEqString = fn (p_self &String, p_b &String)

pub type GDExtensionInterfaceStringOperatorPlusEqChar = fn (p_self &String, p_b u32)

pub type GDExtensionInterfaceStringOperatorPlusEqCstr = fn (p_self &String, p_b &i8)

pub type GDExtensionInterfaceStringOperatorPlusEqWcstr = fn (p_self &String, p_b &GDWideChar)

pub type GDExtensionInterfaceStringOperatorPlusEqC32str = fn (p_self &String, p_b &u32)

pub type GDExtensionInterfaceStringResize = fn (p_self &String, p_resize GDExtensionInt) GDExtensionInt

pub type GDExtensionInterfaceStringNameNewWithLatin1Chars = fn (r_dest GDExtensionUninitializedStringNamePtr, p_contents &i8, p_is_static GDExtensionBool)

pub type GDExtensionInterfaceStringNameNewWithUtf8Chars = fn (r_dest GDExtensionUninitializedStringNamePtr, p_contents &i8)

pub type GDExtensionInterfaceStringNameNewWithUtf8CharsAndLen = fn (r_dest GDExtensionUninitializedStringNamePtr, p_contents &i8, p_size GDExtensionInt)

pub type GDExtensionInterfaceXmlParserOpenBuffer = fn (p_instance GDExtensionObjectPtr, p_buffer &u8, p_size GDSize) GDExtensionInt

pub type GDExtensionInterfaceFileAccessStoreBuffer = fn (p_instance GDExtensionObjectPtr, p_src &u8, p_length u64)

pub type GDExtensionInterfaceFileAccessGetBuffer = fn (p_instance GDExtensionConstObjectPtr, p_dst &u8, p_length u64) u64

pub type GDExtensionInterfaceImagePtrw = fn (p_instance GDExtensionObjectPtr) &u8

pub type GDExtensionInterfaceImagePtr = fn (p_instance GDExtensionObjectPtr) &u8

pub type GDExtensionInterfaceWorkerThreadPoolAddNativeGroupTask = fn (p_instance GDExtensionObjectPtr, p_func GDExtensionWorkerThreadPoolGroupTask, p_userdata voidptr, p_elements int, p_tasks int, p_high_priority GDExtensionBool, p_description &String) i64

pub type GDExtensionInterfaceWorkerThreadPoolAddNativeTask = fn (p_instance GDExtensionObjectPtr, p_func GDExtensionWorkerThreadPoolTask, p_userdata voidptr, p_high_priority GDExtensionBool, p_description &String) i64

pub type GDExtensionInterfacePackedByteArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) &u8

pub type GDExtensionInterfacePackedByteArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) &u8

pub type GDExtensionInterfacePackedFloat32ArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) &f32

pub type GDExtensionInterfacePackedFloat32ArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) &f32

pub type GDExtensionInterfacePackedFloat64ArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) &f64

pub type GDExtensionInterfacePackedFloat64ArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) &f64

pub type GDExtensionInterfacePackedInt32ArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) &int

pub type GDExtensionInterfacePackedInt32ArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) &int

pub type GDExtensionInterfacePackedInt64ArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) &i64

pub type GDExtensionInterfacePackedInt64ArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) &i64

pub type GDExtensionInterfacePackedStringArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) &String

pub type GDExtensionInterfacePackedStringArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) &String

pub type GDExtensionInterfacePackedVector2ArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfacePackedVector2ArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfacePackedVector3ArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfacePackedVector3ArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfacePackedVector4ArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfacePackedVector4ArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfacePackedColorArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfacePackedColorArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) GDExtensionTypePtr

pub type GDExtensionInterfaceArrayOperatorIndex = fn (p_self GDExtensionTypePtr, p_index GDExtensionInt) &Variant

pub type GDExtensionInterfaceArrayOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_index GDExtensionInt) &Variant

// Deprecated since 4.5. Removed from interface. Use copy constructor instead.
pub type GDExtensionInterfaceArrayRef = fn (p_self GDExtensionTypePtr, p_from GDExtensionConstTypePtr)

pub type GDExtensionInterfaceArraySetTyped = fn (p_self GDExtensionTypePtr, p_type GDExtensionVariantType, p_class_name &StringName, p_script &Variant)

pub type GDExtensionInterfaceDictionaryOperatorIndex = fn (p_self GDExtensionTypePtr, p_key &Variant) &Variant

pub type GDExtensionInterfaceDictionaryOperatorIndexConst = fn (p_self GDExtensionConstTypePtr, p_key &Variant) &Variant

pub type GDExtensionInterfaceDictionarySetTyped = fn (p_self GDExtensionTypePtr, p_key_type GDExtensionVariantType, p_key_class_name &StringName, p_key_script &Variant, p_value_type GDExtensionVariantType, p_value_class_name &StringName, p_value_script &Variant)

pub type GDExtensionInterfaceObjectMethodBindCall = fn (p_method_bind GDExtensionMethodBindPtr, p_instance GDExtensionObjectPtr, p_args &&Variant, p_arg_count GDExtensionInt, r_ret GDExtensionUninitializedVariantPtr, r_error &GDExtensionCallError)

pub type GDExtensionInterfaceObjectMethodBindPtrcall = fn (p_method_bind GDExtensionMethodBindPtr, p_instance GDExtensionObjectPtr, p_args &GDExtensionConstTypePtr, r_ret GDExtensionTypePtr)

pub type GDExtensionInterfaceObjectDestroy = fn (p_o GDExtensionObjectPtr)

pub type GDExtensionInterfaceGlobalGetSingleton = fn (p_name &StringName) GDExtensionObjectPtr

pub type GDExtensionInterfaceObjectGetInstanceBinding = fn (p_o GDExtensionObjectPtr, p_token voidptr, p_callbacks &GDExtensionInstanceBindingCallbacks) voidptr

pub type GDExtensionInterfaceObjectSetInstanceBinding = fn (p_o GDExtensionObjectPtr, p_token voidptr, p_binding voidptr, p_callbacks &GDExtensionInstanceBindingCallbacks)

pub type GDExtensionInterfaceObjectFreeInstanceBinding = fn (p_o GDExtensionObjectPtr, p_token voidptr)

pub type GDExtensionInterfaceObjectSetInstance = fn (p_o GDExtensionObjectPtr, p_classname &StringName, p_instance GDExtensionClassInstancePtr)

pub type GDExtensionInterfaceObjectGetClassName = fn (p_object GDExtensionConstObjectPtr, p_library GDExtensionClassLibraryPtr, r_class_name GDExtensionUninitializedStringNamePtr) GDExtensionBool

// Deprecated since 4.7. Use the `is_class` method on `Object` to check if an object can be cast instead. If true, the previous pointer can be reinterpreted as a pointer to the target type.
pub type GDExtensionInterfaceObjectCastTo = fn (p_object GDExtensionConstObjectPtr, p_class_tag voidptr) GDExtensionObjectPtr

pub type GDExtensionInterfaceObjectGetInstanceFromId = fn (p_instance_id GDObjectInstanceID) GDExtensionObjectPtr

pub type GDExtensionInterfaceObjectGetInstanceId = fn (p_object GDExtensionConstObjectPtr) GDObjectInstanceID

pub type GDExtensionInterfaceObjectHasScriptMethod = fn (p_object GDExtensionConstObjectPtr, p_method &StringName) GDExtensionBool

pub type GDExtensionInterfaceObjectCallScriptMethod = fn (p_object GDExtensionObjectPtr, p_method &StringName, p_args &&Variant, p_argument_count GDExtensionInt, r_return GDExtensionUninitializedVariantPtr, r_error &GDExtensionCallError)

pub type GDExtensionInterfaceRefGetObject = fn (p_ref GDExtensionConstRefPtr) GDExtensionObjectPtr

pub type GDExtensionInterfaceRefSetObject = fn (p_ref GDExtensionRefPtr, p_object GDExtensionObjectPtr)

// Deprecated since 4.2, use script_instance_create3
pub type GDExtensionInterfaceScriptInstanceCreate = fn (p_info &GDExtensionScriptInstanceInfo, p_instance_data GDExtensionScriptInstanceDataPtr) GDExtensionScriptInstancePtr

// Deprecated since 4.3, use script_instance_create3
pub type GDExtensionInterfaceScriptInstanceCreate2 = fn (p_info &GDExtensionScriptInstanceInfo2, p_instance_data GDExtensionScriptInstanceDataPtr) GDExtensionScriptInstancePtr

pub type GDExtensionInterfaceScriptInstanceCreate3 = fn (p_info &GDExtensionScriptInstanceInfo3, p_instance_data GDExtensionScriptInstanceDataPtr) GDExtensionScriptInstancePtr

pub type GDExtensionInterfacePlaceholderScriptInstanceCreate = fn (p_language GDExtensionObjectPtr, p_script GDExtensionObjectPtr, p_owner GDExtensionObjectPtr) GDExtensionScriptInstancePtr

pub type GDExtensionInterfacePlaceholderScriptInstanceUpdate = fn (p_placeholder GDExtensionScriptInstancePtr, p_properties GDExtensionConstTypePtr, p_values GDExtensionConstTypePtr)

pub type GDExtensionInterfaceObjectGetScriptInstance = fn (p_object GDExtensionConstObjectPtr, p_language GDExtensionObjectPtr) GDExtensionScriptInstanceDataPtr

pub type GDExtensionInterfaceObjectSetScriptInstance = fn (p_object GDExtensionObjectPtr, p_script_instance GDExtensionScriptInstanceDataPtr)

// Deprecated since 4.3, use callable_custom_create2
pub type GDExtensionInterfaceCallableCustomCreate = fn (r_callable GDExtensionUninitializedTypePtr, p_callable_custom_info &GDExtensionCallableCustomInfo)

pub type GDExtensionInterfaceCallableCustomCreate2 = fn (r_callable GDExtensionUninitializedTypePtr, p_callable_custom_info &GDExtensionCallableCustomInfo2)

pub type GDExtensionInterfaceCallableCustomGetUserdata = fn (p_callable GDExtensionConstTypePtr, p_token voidptr) voidptr

// Deprecated since 4.4, use classdb_construct_object3
pub type GDExtensionInterfaceClassdbConstructObject = fn (p_classname &StringName) GDExtensionObjectPtr

// Deprecated since 4.7, use classdb_construct_object3
pub type GDExtensionInterfaceClassdbConstructObject2 = fn (p_classname &StringName) GDExtensionObjectPtr

pub type GDExtensionInterfaceClassdbConstructObject3 = fn (p_classname &StringName) GDExtensionObjectPtr

pub type GDExtensionInterfaceClassdbGetMethodBind = fn (p_classname &StringName, p_methodname &StringName, p_hash GDExtensionInt) GDExtensionMethodBindPtr

// Deprecated since 4.7. No longer needed. Use the `is_class` method on `Object` instead.
pub type GDExtensionInterfaceClassdbGetClassTag = fn (p_classname &StringName) voidptr

// Deprecated since 4.2, use classdb_register_extension_class6
pub type GDExtensionInterfaceClassdbRegisterExtensionClass = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_parent_class_name &StringName, p_extension_funcs &GDExtensionClassCreationInfo)

// Deprecated since 4.3, use classdb_register_extension_class6
pub type GDExtensionInterfaceClassdbRegisterExtensionClass2 = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_parent_class_name &StringName, p_extension_funcs &GDExtensionClassCreationInfo2)

// Deprecated since 4.4, use classdb_register_extension_class6
pub type GDExtensionInterfaceClassdbRegisterExtensionClass3 = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_parent_class_name &StringName, p_extension_funcs &GDExtensionClassCreationInfo3)

// Deprecated since 4.5, use classdb_register_extension_class6
pub type GDExtensionInterfaceClassdbRegisterExtensionClass4 = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_parent_class_name &StringName, p_extension_funcs &GDExtensionClassCreationInfo4)

// Deprecated since 4.7, use classdb_register_extension_class6
pub type GDExtensionInterfaceClassdbRegisterExtensionClass5 = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_parent_class_name &StringName, p_extension_funcs &GDExtensionClassCreationInfo5)

pub type GDExtensionInterfaceClassdbRegisterExtensionClass6 = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_parent_class_name &StringName, p_extension_funcs &GDExtensionClassCreationInfo6)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassMethod = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_method_info &GDExtensionClassMethodInfo)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassVirtualMethod = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_method_info &GDExtensionClassVirtualMethodInfo)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassIntegerConstant = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_enum_name &StringName, p_constant_name &StringName, p_constant_value GDExtensionInt, p_is_bitfield GDExtensionBool)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassProperty = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_info &GDExtensionPropertyInfo, p_setter &StringName, p_getter &StringName)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassPropertyIndexed = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_info &GDExtensionPropertyInfo, p_setter &StringName, p_getter &StringName, p_index GDExtensionInt)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassPropertyGroup = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_group_name &String, p_prefix &String)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassPropertySubgroup = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_subgroup_name &String, p_prefix &String)

pub type GDExtensionInterfaceClassdbRegisterExtensionClassSignal = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName, p_signal_name &StringName, p_argument_info &GDExtensionPropertyInfo, p_argument_count GDExtensionInt)

pub type GDExtensionInterfaceClassdbUnregisterExtensionClass = fn (p_library GDExtensionClassLibraryPtr, p_class_name &StringName)

pub type GDExtensionInterfaceGetLibraryPath = fn (p_library GDExtensionClassLibraryPtr, r_path GDExtensionUninitializedStringPtr)

pub type GDExtensionInterfaceEditorAddPlugin = fn (p_class_name &StringName)

pub type GDExtensionInterfaceEditorRemovePlugin = fn (p_class_name &StringName)

pub type GDExtensionInterfaceEditorHelpLoadXmlFromUtf8Chars = fn (p_data &i8)

pub type GDExtensionInterfaceEditorHelpLoadXmlFromUtf8CharsAndLen = fn (p_data &i8, p_size GDExtensionInt)

pub type GDExtensionInterfaceEditorRegisterGetClassesUsedCallback = fn (p_library GDExtensionClassLibraryPtr, p_callback GDExtensionEditorGetClassesUsedCallback)

pub type GDExtensionInterfaceRegisterMainLoopCallbacks = fn (p_library GDExtensionClassLibraryPtr, p_callbacks &GDExtensionMainLoopCallbacks)

// GDExtensionInterfaceFunctions holds every entry point of the interface.
// Entry points introduced after Godot 4.5 are resolved only when built with
// `-d godot_4_N`, otherwise they stay nil. Deprecated ones may be nil on newer Godot.
@[heap]
pub struct GDExtensionInterfaceFunctions {
pub mut:
	gpaddr                                             fn (&i8) GDExtensionInterfaceFunctionPtr @[required]
	clp                                                GDExtensionClassLibraryPtr               @[required]
	get_godot_version                                  GDExtensionInterfaceGetGodotVersion                      = unsafe { nil } // since 4.1
	get_godot_version2                                 GDExtensionInterfaceGetGodotVersion2                     = unsafe { nil } // since 4.5
	mem_alloc                                          GDExtensionInterfaceMemAlloc                             = unsafe { nil } // since 4.1
	mem_realloc                                        GDExtensionInterfaceMemRealloc                           = unsafe { nil } // since 4.1
	mem_free                                           GDExtensionInterfaceMemFree                              = unsafe { nil } // since 4.1
	mem_alloc2                                         GDExtensionInterfaceMemAlloc2                            = unsafe { nil } // since 4.6
	mem_realloc2                                       GDExtensionInterfaceMemRealloc2                          = unsafe { nil } // since 4.6
	mem_free2                                          GDExtensionInterfaceMemFree2                             = unsafe { nil } // since 4.6
	print_error                                        GDExtensionInterfacePrintError                           = unsafe { nil } // since 4.1
	print_error_with_message                           GDExtensionInterfacePrintErrorWithMessage                = unsafe { nil } // since 4.1
	print_warning                                      GDExtensionInterfacePrintWarning                         = unsafe { nil } // since 4.1
	print_warning_with_message                         GDExtensionInterfacePrintWarningWithMessage              = unsafe { nil } // since 4.1
	print_script_error                                 GDExtensionInterfacePrintScriptError                     = unsafe { nil } // since 4.1
	print_script_error_with_message                    GDExtensionInterfacePrintScriptErrorWithMessage          = unsafe { nil } // since 4.1
	get_native_struct_size                             GDExtensionInterfaceGetNativeStructSize                  = unsafe { nil } // since 4.1
	variant_new_copy                                   GDExtensionInterfaceVariantNewCopy                       = unsafe { nil } // since 4.1
	variant_new_nil                                    GDExtensionInterfaceVariantNewNil                        = unsafe { nil } // since 4.1
	variant_destroy                                    GDExtensionInterfaceVariantDestroy                       = unsafe { nil } // since 4.1
	variant_call                                       GDExtensionInterfaceVariantCall                          = unsafe { nil } // since 4.1
	variant_call_static                                GDExtensionInterfaceVariantCallStatic                    = unsafe { nil } // since 4.1
	variant_evaluate                                   GDExtensionInterfaceVariantEvaluate                      = unsafe { nil } // since 4.1
	variant_set                                        GDExtensionInterfaceVariantSet                           = unsafe { nil } // since 4.1
	variant_set_named                                  GDExtensionInterfaceVariantSetNamed                      = unsafe { nil } // since 4.1
	variant_set_keyed                                  GDExtensionInterfaceVariantSetKeyed                      = unsafe { nil } // since 4.1
	variant_set_indexed                                GDExtensionInterfaceVariantSetIndexed                    = unsafe { nil } // since 4.1
	variant_get                                        GDExtensionInterfaceVariantGet                           = unsafe { nil } // since 4.1
	variant_get_named                                  GDExtensionInterfaceVariantGetNamed                      = unsafe { nil } // since 4.1
	variant_get_keyed                                  GDExtensionInterfaceVariantGetKeyed                      = unsafe { nil } // since 4.1
	variant_get_indexed                                GDExtensionInterfaceVariantGetIndexed                    = unsafe { nil } // since 4.1
	variant_iter_init                                  GDExtensionInterfaceVariantIterInit                      = unsafe { nil } // since 4.1
	variant_iter_next                                  GDExtensionInterfaceVariantIterNext                      = unsafe { nil } // since 4.1
	variant_iter_get                                   GDExtensionInterfaceVariantIterGet                       = unsafe { nil } // since 4.1
	variant_hash                                       GDExtensionInterfaceVariantHash                          = unsafe { nil } // since 4.1
	variant_recursive_hash                             GDExtensionInterfaceVariantRecursiveHash                 = unsafe { nil } // since 4.1
	variant_hash_compare                               GDExtensionInterfaceVariantHashCompare                   = unsafe { nil } // since 4.1
	variant_booleanize                                 GDExtensionInterfaceVariantBooleanize                    = unsafe { nil } // since 4.1
	variant_duplicate                                  GDExtensionInterfaceVariantDuplicate                     = unsafe { nil } // since 4.1
	variant_stringify                                  GDExtensionInterfaceVariantStringify                     = unsafe { nil } // since 4.1
	variant_get_type                                   GDExtensionInterfaceVariantGetType                       = unsafe { nil } // since 4.1
	variant_has_method                                 GDExtensionInterfaceVariantHasMethod                     = unsafe { nil } // since 4.1
	variant_has_member                                 GDExtensionInterfaceVariantHasMember                     = unsafe { nil } // since 4.1
	variant_has_key                                    GDExtensionInterfaceVariantHasKey                        = unsafe { nil } // since 4.1
	variant_get_object_instance_id                     GDExtensionInterfaceVariantGetObjectInstanceId           = unsafe { nil } // since 4.4
	variant_get_type_name                              GDExtensionInterfaceVariantGetTypeName                   = unsafe { nil } // since 4.1
	variant_get_type_by_name                           GDExtensionInterfaceVariantGetTypeByName                 = unsafe { nil } // since 4.7
	variant_can_convert                                GDExtensionInterfaceVariantCanConvert                    = unsafe { nil } // since 4.1
	variant_can_convert_strict                         GDExtensionInterfaceVariantCanConvertStrict              = unsafe { nil } // since 4.1
	get_variant_from_type_constructor                  GDExtensionInterfaceGetVariantFromTypeConstructor        = unsafe { nil } // since 4.1
	get_variant_to_type_constructor                    GDExtensionInterfaceGetVariantToTypeConstructor          = unsafe { nil } // since 4.1
	variant_get_ptr_internal_getter                    GDExtensionInterfaceVariantGetPtrInternalGetter          = unsafe { nil } // since 4.4
	variant_get_ptr_operator_evaluator                 GDExtensionInterfaceVariantGetPtrOperatorEvaluator       = unsafe { nil } // since 4.1
	variant_get_ptr_builtin_method                     GDExtensionInterfaceVariantGetPtrBuiltinMethod           = unsafe { nil } // since 4.1
	variant_get_ptr_constructor                        GDExtensionInterfaceVariantGetPtrConstructor             = unsafe { nil } // since 4.1
	variant_get_ptr_destructor                         GDExtensionInterfaceVariantGetPtrDestructor              = unsafe { nil } // since 4.1
	variant_construct                                  GDExtensionInterfaceVariantConstruct                     = unsafe { nil } // since 4.1
	variant_get_ptr_setter                             GDExtensionInterfaceVariantGetPtrSetter                  = unsafe { nil } // since 4.1
	variant_get_ptr_getter                             GDExtensionInterfaceVariantGetPtrGetter                  = unsafe { nil } // since 4.1
	variant_get_ptr_indexed_setter                     GDExtensionInterfaceVariantGetPtrIndexedSetter           = unsafe { nil } // since 4.1
	variant_get_ptr_indexed_getter                     GDExtensionInterfaceVariantGetPtrIndexedGetter           = unsafe { nil } // since 4.1
	variant_get_ptr_keyed_setter                       GDExtensionInterfaceVariantGetPtrKeyedSetter             = unsafe { nil } // since 4.1
	variant_get_ptr_keyed_getter                       GDExtensionInterfaceVariantGetPtrKeyedGetter             = unsafe { nil } // since 4.1
	variant_get_ptr_keyed_checker                      GDExtensionInterfaceVariantGetPtrKeyedChecker            = unsafe { nil } // since 4.1
	variant_get_constant_value                         GDExtensionInterfaceVariantGetConstantValue              = unsafe { nil } // since 4.1
	variant_get_ptr_utility_function                   GDExtensionInterfaceVariantGetPtrUtilityFunction         = unsafe { nil } // since 4.1
	string_new_with_latin1_chars                       GDExtensionInterfaceStringNewWithLatin1Chars             = unsafe { nil } // since 4.1
	string_new_with_utf8_chars                         GDExtensionInterfaceStringNewWithUtf8Chars               = unsafe { nil } // since 4.1
	string_new_with_utf16_chars                        GDExtensionInterfaceStringNewWithUtf16Chars              = unsafe { nil } // since 4.1
	string_new_with_utf32_chars                        GDExtensionInterfaceStringNewWithUtf32Chars              = unsafe { nil } // since 4.1
	string_new_with_wide_chars                         GDExtensionInterfaceStringNewWithWideChars               = unsafe { nil } // since 4.1
	string_new_with_latin1_chars_and_len               GDExtensionInterfaceStringNewWithLatin1CharsAndLen       = unsafe { nil } // since 4.1
	string_new_with_utf8_chars_and_len                 GDExtensionInterfaceStringNewWithUtf8CharsAndLen         = unsafe { nil } // since 4.1
	string_new_with_utf8_chars_and_len2                GDExtensionInterfaceStringNewWithUtf8CharsAndLen2        = unsafe { nil } // since 4.3
	string_new_with_utf16_chars_and_len                GDExtensionInterfaceStringNewWithUtf16CharsAndLen        = unsafe { nil } // since 4.1
	string_new_with_utf16_chars_and_len2               GDExtensionInterfaceStringNewWithUtf16CharsAndLen2       = unsafe { nil } // since 4.3
	string_new_with_utf32_chars_and_len                GDExtensionInterfaceStringNewWithUtf32CharsAndLen        = unsafe { nil } // since 4.1
	string_new_with_wide_chars_and_len                 GDExtensionInterfaceStringNewWithWideCharsAndLen         = unsafe { nil } // since 4.1
	string_to_latin1_chars                             GDExtensionInterfaceStringToLatin1Chars                  = unsafe { nil } // since 4.1
	string_to_utf8_chars                               GDExtensionInterfaceStringToUtf8Chars                    = unsafe { nil } // since 4.1
	string_to_utf16_chars                              GDExtensionInterfaceStringToUtf16Chars                   = unsafe { nil } // since 4.1
	string_to_utf32_chars                              GDExtensionInterfaceStringToUtf32Chars                   = unsafe { nil } // since 4.1
	string_to_wide_chars                               GDExtensionInterfaceStringToWideChars                    = unsafe { nil } // since 4.1
	string_operator_index                              GDExtensionInterfaceStringOperatorIndex                  = unsafe { nil } // since 4.1
	string_operator_index_const                        GDExtensionInterfaceStringOperatorIndexConst             = unsafe { nil } // since 4.1
	string_operator_plus_eq_string                     GDExtensionInterfaceStringOperatorPlusEqString           = unsafe { nil } // since 4.1
	string_operator_plus_eq_char                       GDExtensionInterfaceStringOperatorPlusEqChar             = unsafe { nil } // since 4.1
	string_operator_plus_eq_cstr                       GDExtensionInterfaceStringOperatorPlusEqCstr             = unsafe { nil } // since 4.1
	string_operator_plus_eq_wcstr                      GDExtensionInterfaceStringOperatorPlusEqWcstr            = unsafe { nil } // since 4.1
	string_operator_plus_eq_c32str                     GDExtensionInterfaceStringOperatorPlusEqC32str           = unsafe { nil } // since 4.1
	string_resize                                      GDExtensionInterfaceStringResize                         = unsafe { nil } // since 4.2
	string_name_new_with_latin1_chars                  GDExtensionInterfaceStringNameNewWithLatin1Chars         = unsafe { nil } // since 4.2
	string_name_new_with_utf8_chars                    GDExtensionInterfaceStringNameNewWithUtf8Chars           = unsafe { nil } // since 4.2
	string_name_new_with_utf8_chars_and_len            GDExtensionInterfaceStringNameNewWithUtf8CharsAndLen     = unsafe { nil } // since 4.2
	xml_parser_open_buffer                             GDExtensionInterfaceXmlParserOpenBuffer                  = unsafe { nil } // since 4.1
	file_access_store_buffer                           GDExtensionInterfaceFileAccessStoreBuffer                = unsafe { nil } // since 4.1
	file_access_get_buffer                             GDExtensionInterfaceFileAccessGetBuffer                  = unsafe { nil } // since 4.1
	image_ptrw                                         GDExtensionInterfaceImagePtrw                            = unsafe { nil } // since 4.3
	image_ptr                                          GDExtensionInterfaceImagePtr                             = unsafe { nil } // since 4.3
	worker_thread_pool_add_native_group_task           GDExtensionInterfaceWorkerThreadPoolAddNativeGroupTask   = unsafe { nil } // since 4.1
	worker_thread_pool_add_native_task                 GDExtensionInterfaceWorkerThreadPoolAddNativeTask        = unsafe { nil } // since 4.1
	packed_byte_array_operator_index                   GDExtensionInterfacePackedByteArrayOperatorIndex         = unsafe { nil } // since 4.1
	packed_byte_array_operator_index_const             GDExtensionInterfacePackedByteArrayOperatorIndexConst    = unsafe { nil } // since 4.1
	packed_float32_array_operator_index                GDExtensionInterfacePackedFloat32ArrayOperatorIndex      = unsafe { nil } // since 4.1
	packed_float32_array_operator_index_const          GDExtensionInterfacePackedFloat32ArrayOperatorIndexConst = unsafe { nil } // since 4.1
	packed_float64_array_operator_index                GDExtensionInterfacePackedFloat64ArrayOperatorIndex      = unsafe { nil } // since 4.1
	packed_float64_array_operator_index_const          GDExtensionInterfacePackedFloat64ArrayOperatorIndexConst = unsafe { nil } // since 4.1
	packed_int32_array_operator_index                  GDExtensionInterfacePackedInt32ArrayOperatorIndex        = unsafe { nil } // since 4.1
	packed_int32_array_operator_index_const            GDExtensionInterfacePackedInt32ArrayOperatorIndexConst   = unsafe { nil } // since 4.1
	packed_int64_array_operator_index                  GDExtensionInterfacePackedInt64ArrayOperatorIndex        = unsafe { nil } // since 4.1
	packed_int64_array_operator_index_const            GDExtensionInterfacePackedInt64ArrayOperatorIndexConst   = unsafe { nil } // since 4.1
	packed_string_array_operator_index                 GDExtensionInterfacePackedStringArrayOperatorIndex       = unsafe { nil } // since 4.1
	packed_string_array_operator_index_const           GDExtensionInterfacePackedStringArrayOperatorIndexConst  = unsafe { nil } // since 4.1
	packed_vector2_array_operator_index                GDExtensionInterfacePackedVector2ArrayOperatorIndex      = unsafe { nil } // since 4.1
	packed_vector2_array_operator_index_const          GDExtensionInterfacePackedVector2ArrayOperatorIndexConst = unsafe { nil } // since 4.1
	packed_vector3_array_operator_index                GDExtensionInterfacePackedVector3ArrayOperatorIndex      = unsafe { nil } // since 4.1
	packed_vector3_array_operator_index_const          GDExtensionInterfacePackedVector3ArrayOperatorIndexConst = unsafe { nil } // since 4.1
	packed_vector4_array_operator_index                GDExtensionInterfacePackedVector4ArrayOperatorIndex      = unsafe { nil } // since 4.3
	packed_vector4_array_operator_index_const          GDExtensionInterfacePackedVector4ArrayOperatorIndexConst = unsafe { nil } // since 4.3
	packed_color_array_operator_index                  GDExtensionInterfacePackedColorArrayOperatorIndex        = unsafe { nil } // since 4.1
	packed_color_array_operator_index_const            GDExtensionInterfacePackedColorArrayOperatorIndexConst   = unsafe { nil } // since 4.1
	array_operator_index                               GDExtensionInterfaceArrayOperatorIndex                   = unsafe { nil } // since 4.1
	array_operator_index_const                         GDExtensionInterfaceArrayOperatorIndexConst              = unsafe { nil } // since 4.1
	array_ref                                          GDExtensionInterfaceArrayRef                                      = unsafe { nil } // since 4.1
	array_set_typed                                    GDExtensionInterfaceArraySetTyped                                 = unsafe { nil } // since 4.1
	dictionary_operator_index                          GDExtensionInterfaceDictionaryOperatorIndex                       = unsafe { nil } // since 4.1
	dictionary_operator_index_const                    GDExtensionInterfaceDictionaryOperatorIndexConst                  = unsafe { nil } // since 4.1
	dictionary_set_typed                               GDExtensionInterfaceDictionarySetTyped                            = unsafe { nil } // since 4.4
	object_method_bind_call                            GDExtensionInterfaceObjectMethodBindCall                          = unsafe { nil } // since 4.1
	object_method_bind_ptrcall                         GDExtensionInterfaceObjectMethodBindPtrcall                       = unsafe { nil } // since 4.1
	object_destroy                                     GDExtensionInterfaceObjectDestroy                                 = unsafe { nil } // since 4.1
	global_get_singleton                               GDExtensionInterfaceGlobalGetSingleton                            = unsafe { nil } // since 4.1
	object_get_instance_binding                        GDExtensionInterfaceObjectGetInstanceBinding                      = unsafe { nil } // since 4.1
	object_set_instance_binding                        GDExtensionInterfaceObjectSetInstanceBinding                      = unsafe { nil } // since 4.1
	object_free_instance_binding                       GDExtensionInterfaceObjectFreeInstanceBinding                     = unsafe { nil } // since 4.2
	object_set_instance                                GDExtensionInterfaceObjectSetInstance                             = unsafe { nil } // since 4.1
	object_get_class_name                              GDExtensionInterfaceObjectGetClassName                            = unsafe { nil } // since 4.1
	object_cast_to                                     GDExtensionInterfaceObjectCastTo                                  = unsafe { nil } // since 4.1
	object_get_instance_from_id                        GDExtensionInterfaceObjectGetInstanceFromId                       = unsafe { nil } // since 4.1
	object_get_instance_id                             GDExtensionInterfaceObjectGetInstanceId                           = unsafe { nil } // since 4.1
	object_has_script_method                           GDExtensionInterfaceObjectHasScriptMethod                         = unsafe { nil } // since 4.3
	object_call_script_method                          GDExtensionInterfaceObjectCallScriptMethod                        = unsafe { nil } // since 4.3
	ref_get_object                                     GDExtensionInterfaceRefGetObject                                  = unsafe { nil } // since 4.1
	ref_set_object                                     GDExtensionInterfaceRefSetObject                                  = unsafe { nil } // since 4.1
	script_instance_create                             GDExtensionInterfaceScriptInstanceCreate                          = unsafe { nil } // since 4.1
	script_instance_create2                            GDExtensionInterfaceScriptInstanceCreate2                         = unsafe { nil } // since 4.2
	script_instance_create3                            GDExtensionInterfaceScriptInstanceCreate3                         = unsafe { nil } // since 4.3
	placeholder_script_instance_create                 GDExtensionInterfacePlaceholderScriptInstanceCreate               = unsafe { nil } // since 4.2
	placeholder_script_instance_update                 GDExtensionInterfacePlaceholderScriptInstanceUpdate               = unsafe { nil } // since 4.2
	object_get_script_instance                         GDExtensionInterfaceObjectGetScriptInstance                       = unsafe { nil } // since 4.2
	object_set_script_instance                         GDExtensionInterfaceObjectSetScriptInstance                       = unsafe { nil } // since 4.5
	callable_custom_create                             GDExtensionInterfaceCallableCustomCreate                          = unsafe { nil } // since 4.2
	callable_custom_create2                            GDExtensionInterfaceCallableCustomCreate2                         = unsafe { nil } // since 4.3
	callable_custom_get_userdata                       GDExtensionInterfaceCallableCustomGetUserdata                     = unsafe { nil } // since 4.2
	classdb_construct_object                           GDExtensionInterfaceClassdbConstructObject                        = unsafe { nil } // since 4.1
	classdb_construct_object2                          GDExtensionInterfaceClassdbConstructObject2                       = unsafe { nil } // since 4.4
	classdb_construct_object3                          GDExtensionInterfaceClassdbConstructObject3                       = unsafe { nil } // since 4.7
	classdb_get_method_bind                            GDExtensionInterfaceClassdbGetMethodBind                          = unsafe { nil } // since 4.1
	classdb_get_class_tag                              GDExtensionInterfaceClassdbGetClassTag                            = unsafe { nil } // since 4.1
	classdb_register_extension_class                   GDExtensionInterfaceClassdbRegisterExtensionClass                 = unsafe { nil } // since 4.1
	classdb_register_extension_class2                  GDExtensionInterfaceClassdbRegisterExtensionClass2                = unsafe { nil } // since 4.2
	classdb_register_extension_class3                  GDExtensionInterfaceClassdbRegisterExtensionClass3                = unsafe { nil } // since 4.3
	classdb_register_extension_class4                  GDExtensionInterfaceClassdbRegisterExtensionClass4                = unsafe { nil } // since 4.4
	classdb_register_extension_class5                  GDExtensionInterfaceClassdbRegisterExtensionClass5                = unsafe { nil } // since 4.5
	classdb_register_extension_class6                  GDExtensionInterfaceClassdbRegisterExtensionClass6                = unsafe { nil } // since 4.7
	classdb_register_extension_class_method            GDExtensionInterfaceClassdbRegisterExtensionClassMethod           = unsafe { nil } // since 4.1
	classdb_register_extension_class_virtual_method    GDExtensionInterfaceClassdbRegisterExtensionClassVirtualMethod    = unsafe { nil } // since 4.3
	classdb_register_extension_class_integer_constant  GDExtensionInterfaceClassdbRegisterExtensionClassIntegerConstant  = unsafe { nil } // since 4.1
	classdb_register_extension_class_property          GDExtensionInterfaceClassdbRegisterExtensionClassProperty         = unsafe { nil } // since 4.1
	classdb_register_extension_class_property_indexed  GDExtensionInterfaceClassdbRegisterExtensionClassPropertyIndexed  = unsafe { nil } // since 4.2
	classdb_register_extension_class_property_group    GDExtensionInterfaceClassdbRegisterExtensionClassPropertyGroup    = unsafe { nil } // since 4.1
	classdb_register_extension_class_property_subgroup GDExtensionInterfaceClassdbRegisterExtensionClassPropertySubgroup = unsafe { nil } // since 4.1
	classdb_register_extension_class_signal            GDExtensionInterfaceClassdbRegisterExtensionClassSignal           = unsafe { nil } // since 4.1
	classdb_unregister_extension_class                 GDExtensionInterfaceClassdbUnregisterExtensionClass               = unsafe { nil } // since 4.1
	get_library_path                                   GDExtensionInterfaceGetLibraryPath                       = unsafe { nil } // since 4.1
	editor_add_plugin                                  GDExtensionInterfaceEditorAddPlugin                      = unsafe { nil } // since 4.1
	editor_remove_plugin                               GDExtensionInterfaceEditorRemovePlugin                   = unsafe { nil } // since 4.1
	editor_help_load_xml_from_utf8_chars               GDExtensionInterfaceEditorHelpLoadXmlFromUtf8Chars       = unsafe { nil } // since 4.3
	editor_help_load_xml_from_utf8_chars_and_len       GDExtensionInterfaceEditorHelpLoadXmlFromUtf8CharsAndLen = unsafe { nil } // since 4.3
	editor_register_get_classes_used_callback          GDExtensionInterfaceEditorRegisterGetClassesUsedCallback = unsafe { nil } // since 4.5
	register_main_loop_callbacks                       GDExtensionInterfaceRegisterMainLoopCallbacks            = unsafe { nil } // since 4.5
}

pub struct Class {
	godot_class bool = true
}

// HACK: using this to distinguish user-defined classes
pub interface IClass {
	// ptr voidptr
	godot_class bool
}
