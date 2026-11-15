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

struct Initialization {
mut:
	minimum_level u32
	pad           u32
	userdata      voidptr
	initialize    voidptr
	deinitialize  voidptr
}

struct ClassInfo {
	is_virtual                  u8
	is_abstract                 u8
	is_exposed                  u8
	is_runtime                  u8
	pad                         u32
	icon_path                   voidptr
	set_func                    voidptr
	get_func                    voidptr
	get_property_list_func      voidptr
	free_property_list_func     voidptr
	property_can_revert_func    voidptr
	property_get_revert_func    voidptr
	validate_property_func      voidptr
	notification_func           voidptr
	to_string_func              voidptr
	reference_func              voidptr
	unreference_func            voidptr
	create_instance_func        voidptr
	free_instance_func          voidptr
	recreate_instance_func      voidptr
	get_virtual_func            voidptr
	get_virtual_call_data_func  voidptr
	call_virtual_with_data_func voidptr
	class_userdata              voidptr
}

struct BindingCallbacks {
mut:
	create_callback    voidptr
	free_callback      voidptr
	reference_callback voidptr
}

struct GdString {
mut:
	data voidptr
}

struct ScriptResource {
mut:
	kind   int
	object voidptr
	source GdString
	base   GdString
	path   GdString
	owned  u8
}

struct RawObject {
mut:
	kind   int
	object voidptr
}

struct KeptName {
mut:
	data voidptr
	next voidptr
}

struct Call {
	instance voidptr
	args     voidptr
	ret      voidptr
}

type CallHandler = fn (Call)

struct MethodDef {
mut:
	handler voidptr
	ret     int
}

struct MethodSpec {
	kind    int
	name    string
	ret     int
	handler CallHandler = unsafe { nil }
}

struct Api {
mut:
	get_proc            voidptr
	library             voidptr
	string_new          voidptr
	string_read         voidptr
	string_name_new     voidptr
	string_dtor         voidptr
	string_copy         voidptr
	mem_alloc           voidptr
	mem_free            voidptr
	construct           voidptr
	ptrcall             voidptr
	register_class      voidptr
	singleton           voidptr
	set_instance        voidptr
	set_binding         voidptr
	get_binding         voidptr
	get_class_name      voidptr
	print_error         voidptr
	destroy_object      voidptr
	placeholder         voidptr
	constructor         voidptr
	destructor          voidptr
	from_type           voidptr
	keyed_setter        voidptr
	variant_destroy     voidptr
	new_dictionary      voidptr
	new_array           voidptr
	new_packed          voidptr
	dict_set            voidptr
	variant_from_bool   voidptr
	variant_from_int    voidptr
	variant_from_string voidptr
	variant_from_object voidptr
	engine              voidptr
	resource_loader     voidptr
	resource_saver      voidptr
	language            voidptr
	loader              voidptr
	saver               voidptr
	script_instance     voidptr
	call_script         voidptr
	variant_call        voidptr
	to_type             voidptr
	string_from_name    voidptr
	script_name         GdString
	vscript_name        GdString
}
