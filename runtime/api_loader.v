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

__global binding = BindingCallbacks{}

type GetProc = fn (&u8) voidptr

type StringNew = fn (voidptr, &u8, i64) i64

type StringRead = fn (voidptr, &u8, i64) i64

type StringNameNew = fn (voidptr, &u8, u8)

type MemAlloc = fn (uint) voidptr

type MemFree = fn (voidptr)

type Construct = fn (voidptr) voidptr

type GetMethod = fn (voidptr, voidptr, i64) voidptr

type Ptrcall = fn (voidptr, voidptr, voidptr, voidptr)

type RegisterClass = fn (voidptr, voidptr, voidptr, voidptr)

type Singleton = fn (voidptr) voidptr

type SetInstance = fn (voidptr, voidptr, voidptr)

type SetBinding = fn (voidptr, voidptr, voidptr, voidptr)

type GetBinding = fn (voidptr, voidptr, voidptr) voidptr

type PrintError = fn (&u8, &u8, &u8, int, u8)

type Placeholder = fn (voidptr, voidptr, voidptr) voidptr

type Constructor = fn (int, int) voidptr

type Destructor = fn (int) voidptr

type BuiltinMethod = fn (int, voidptr, i64) voidptr

type FromType = fn (int) voidptr

type KeyedSetter = fn (int) voidptr

type VariantDestroy = fn (voidptr)

type TypeCtor = fn (voidptr, voidptr)

type BuiltinCall = fn (voidptr, voidptr, voidptr, int)

type KeyedSet = fn (voidptr, voidptr, voidptr)

// report writes a message to Godot's error output.
pub fn report(message string) {
	if gdf != unsafe { nil } {
		text := String.new(message)
		defer {
			text.deinit()
		}
		push_error(text)
		return
	}
	if godot_host.api.print_error == unsafe { nil } {
		return
	}
	f := unsafe { PrintError(godot_host.api.print_error) }
	f(message.str, c'godot_v', c'bridge/entry.v', 0, 1)
}

fn proc(name string) voidptr {
	get_proc := unsafe { GetProc(godot_host.api.get_proc) }
	return get_proc(name.str)
}

fn load_api() {
	prepare_binding()
	godot_host.api.string_new = proc('string_new_with_utf8_chars_and_len2')
	godot_host.api.string_read = proc('string_to_utf8_chars')
	godot_host.api.string_name_new = proc('string_name_new_with_latin1_chars')
	godot_host.api.mem_alloc = proc('mem_alloc')
	godot_host.api.mem_free = proc('mem_free')
	godot_host.api.construct = proc('classdb_construct_object2')
	godot_host.api.get_method = proc('classdb_get_method_bind')
	godot_host.api.ptrcall = proc('object_method_bind_ptrcall')
	godot_host.api.register_class = proc('classdb_register_extension_class5')
	godot_host.api.singleton = proc('global_get_singleton')
	godot_host.api.set_instance = proc('object_set_instance')
	godot_host.api.set_binding = proc('object_set_instance_binding')
	godot_host.api.get_binding = proc('object_get_instance_binding')
	godot_host.api.get_class_name = proc('object_get_class_name')
	godot_host.api.print_error = proc('print_error')
	godot_host.api.destroy_object = proc('object_destroy')
	godot_host.api.placeholder = proc('placeholder_script_instance_create')
	godot_host.api.constructor = proc('variant_get_ptr_constructor')
	godot_host.api.destructor = proc('variant_get_ptr_destructor')
	godot_host.api.builtin_method = proc('variant_get_ptr_builtin_method')
	godot_host.api.from_type = proc('get_variant_from_type_constructor')
	godot_host.api.keyed_setter = proc('variant_get_ptr_keyed_setter')
	godot_host.api.variant_destroy = proc('variant_destroy')
	godot_host.api.string_dtor = destructor_of(int(GDExtensionVariantType.type_string))
	godot_host.api.string_copy = constructor_of(int(GDExtensionVariantType.type_string), 1)
	godot_host.api.new_dictionary = constructor_of(int(GDExtensionVariantType.type_dictionary), 0)
	godot_host.api.new_array = constructor_of(int(GDExtensionVariantType.type_array), 0)
	godot_host.api.new_packed = constructor_of(int(GDExtensionVariantType.type_packedstringarray), 0)
	godot_host.api.dict_set = keyed_setter_of(int(GDExtensionVariantType.type_dictionary))
	godot_host.api.variant_from_bool = from_type_of(int(GDExtensionVariantType.type_bool))
	godot_host.api.variant_from_int = from_type_of(int(GDExtensionVariantType.type_int))
	godot_host.api.variant_from_string = from_type_of(int(GDExtensionVariantType.type_string))
	godot_host.api.variant_from_object = from_type_of(int(GDExtensionVariantType.type_object))
	godot_host.api.notification = method_bind('Object', 'notification', 4023243586)
	godot_host.api.register_language = method_bind('Engine', 'register_script_language', 1850254898)
	godot_host.api.unregister_language = method_bind('Engine', 'unregister_script_language', 1850254898)
	godot_host.api.get_class = method_bind('Object', 'get_class', 201670096)
	godot_host.api.set_path = method_bind('Resource', 'set_path', 83702148)
	godot_host.api.file_read = method_bind('FileAccess', 'get_file_as_string', 1703090593)
	godot_host.api.file_open = method_bind('FileAccess', 'open', 1247358404)
	godot_host.api.file_store = method_bind('FileAccess', 'store_string', 2323990056)
	godot_host.api.file_close = method_bind('FileAccess', 'close', 3218959716)
	godot_host.api.unref = method_bind('RefCounted', 'unreference', 2240911060)
	godot_host.api.add_loader = method_bind('ResourceLoader', 'add_resource_format_loader', 2896595483)
	godot_host.api.remove_loader = method_bind('ResourceLoader', 'remove_resource_format_loader', 405397102)
	godot_host.api.add_saver = method_bind('ResourceSaver', 'add_resource_format_saver', 362894272)
	godot_host.api.remove_saver = method_bind('ResourceSaver', 'remove_resource_format_saver', 3373026878)
	godot_host.api.script_instance = proc('script_instance_create3')
	godot_host.api.call_script = proc('object_call_script_method')
	godot_host.api.variant_call = proc('variant_call')
	godot_host.api.to_type = proc('get_variant_to_type_constructor')
	godot_host.api.string_from_name = constructor_of(int(GDExtensionVariantType.type_string), 2)
	godot_host.api.script_name = string_name('Script')
	godot_host.api.vscript_name = string_name('VScript')
	prepare_instance_info()
	if sizeof(Initialization) != 32 || sizeof(ClassInfo) != 160 || sizeof(InstanceInfo) != 208 {
		report('GDExtension struct size mismatch')
	}
}

fn constructor_of(typ int, index int) voidptr {
	f := unsafe { Constructor(godot_host.api.constructor) }
	return f(typ, index)
}

fn destructor_of(typ int) voidptr {
	f := unsafe { Destructor(godot_host.api.destructor) }
	return f(typ)
}

fn from_type_of(typ int) voidptr {
	f := unsafe { FromType(godot_host.api.from_type) }
	return f(typ)
}

fn to_type_of(typ int) voidptr {
	f := unsafe { FromType(godot_host.api.to_type) }
	return f(typ)
}

fn keyed_setter_of(typ int) voidptr {
	f := unsafe { KeyedSetter(godot_host.api.keyed_setter) }
	return f(typ)
}

fn builtin_method_of(typ int, name voidptr, hash i64) voidptr {
	f := unsafe { BuiltinMethod(godot_host.api.builtin_method) }
	return f(typ, name, hash)
}

fn method_bind(class_name string, method string, hash i64) voidptr {
	return resolve_method(class_name, method, hash, true)
}

fn resolve_method(class_name string, method string, hash i64, report_missing bool) voidptr {
	class := string_name(class_name)
	name := string_name(method)
	f := unsafe { GetMethod(godot_host.api.get_method) }
	bind := f(voidptr(&class), voidptr(&name), hash)
	destroy_string_name(&class)
	destroy_string_name(&name)
	if bind == unsafe { nil } && report_missing {
		report('missing method ${class_name}.${method}')
	}
	return bind
}

fn singleton(name string) voidptr {
	sn := string_name(name)
	f := unsafe { Singleton(godot_host.api.singleton) }
	object := f(voidptr(&sn))
	destroy_string_name(&sn)
	return object
}
