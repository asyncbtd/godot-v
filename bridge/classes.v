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

struct MethodSlot {
	key    u64
	method &MethodDef
}

__global language_methods = []MethodSlot{}
__global script_methods = []MethodSlot{}
__global loader_methods = []MethodSlot{}
__global saver_methods = []MethodSlot{}

fn register_classes() {
	language_methods = []MethodSlot{}
	script_methods = []MethodSlot{}
	loader_methods = []MethodSlot{}
	saver_methods = []MethodSlot{}
	for spec in method_specs() {
		register_method(spec)
	}
	register_host_class('VLanguage', 'ScriptLanguageExtension', kind_language)
	register_host_class('VScript', 'ScriptExtension', kind_script)
	register_host_class('VScriptLoader', 'ResourceFormatLoader', kind_loader)
	register_host_class('VScriptSaver', 'ResourceFormatSaver', kind_saver)
	register_native_classes()
}

fn register_method(spec MethodSpec) {
	name := string_name(spec.name)
	keep_name(name.data)
	key := u64(uint(name.data))
	mut method := unsafe { &MethodDef(alloc(uint(sizeof(MethodDef)))) }
	method.handler = voidptr(spec.handler)
	method.ret = spec.ret
	slot := MethodSlot{
		key:    key
		method: method
	}
	match spec.kind {
		kind_language { language_methods << slot }
		kind_script { script_methods << slot }
		kind_loader { loader_methods << slot }
		kind_saver { saver_methods << slot }
		else {}
	}
}

fn find_method(list []MethodSlot, key u64) voidptr {
	for slot in list {
		if slot.key == key {
			return voidptr(slot.method)
		}
	}
	return unsafe { nil }
}

fn register_host_class(class_name string, parent string, kind int) {
	name := string_name(class_name)
	parent_name := string_name(parent)
	info := ClassInfo{
		is_exposed:                  1
		create_instance_func:        voidptr(create_instance)
		free_instance_func:          voidptr(free_instance)
		get_virtual_call_data_func:  voidptr(virtual_data)
		call_virtual_with_data_func: voidptr(call_virtual)
		class_userdata:              kind_pointer(kind)
	}
	f := unsafe { RegisterClass(godot_host.api.register_class) }
	f(godot_host.api.library, voidptr(&name), voidptr(&parent_name), voidptr(&info))
	destroy_string_name(&name)
	destroy_string_name(&parent_name)
}

fn kind_pointer(kind int) voidptr {
	return voidptr(uint(u32(kind + 1)))
}

fn pointer_kind(ptr voidptr) int {
	return int(uint(ptr)) - 1
}

fn construct_class(kind int) voidptr {
	class_name := match kind {
		kind_language { 'VLanguage' }
		kind_script { 'VScript' }
		kind_loader { 'VScriptLoader' }
		kind_saver { 'VScriptSaver' }
		else { '' }
	}
	name := string_name(class_name)
	construct := unsafe { Construct(godot_host.api.construct) }
	object := construct(voidptr(&name))
	destroy_string_name(&name)
	if object != unsafe { nil } {
		postinitialize(object)
	}
	return object
}

fn create_instance(class_userdata voidptr, notify u8) voidptr {
	kind := pointer_kind(class_userdata)
	parent := match kind {
		kind_language { 'ScriptLanguageExtension' }
		kind_script { 'ScriptExtension' }
		kind_loader { 'ResourceFormatLoader' }
		kind_saver { 'ResourceFormatSaver' }
		else { '' }
	}
	class_name := match kind {
		kind_language { 'VLanguage' }
		kind_script { 'VScript' }
		kind_loader { 'VScriptLoader' }
		kind_saver { 'VScriptSaver' }
		else { '' }
	}
	parent_name := string_name(parent)
	construct := unsafe { Construct(godot_host.api.construct) }
	object := construct(voidptr(&parent_name))
	destroy_string_name(&parent_name)
	instance := new_instance(kind, object)
	name := string_name(class_name)
	set_instance := unsafe { SetInstance(godot_host.api.set_instance) }
	set_instance(object, voidptr(&name), instance)
	set_binding := unsafe { SetBinding(godot_host.api.set_binding) }
	set_binding(object, godot_host.api.library, instance, voidptr(&binding))
	destroy_string_name(&name)
	if notify != 0 {
		postinitialize(object)
	}
	return object
}

fn new_instance(kind int, object voidptr) voidptr {
	if kind == kind_script {
		mut state := unsafe { &ScriptResource(alloc(uint(sizeof(ScriptResource)))) }
		state.kind = kind
		state.object = object
		return voidptr(state)
	}
	mut plain := unsafe { &RawObject(alloc(uint(sizeof(RawObject)))) }
	plain.kind = kind
	plain.object = object
	return voidptr(plain)
}

fn free_instance(class_userdata voidptr, instance voidptr) {
	if instance == unsafe { nil } {
		return
	}
	kind := pointer_kind(class_userdata)
	if kind == kind_script {
		if script_is_remembered(instance) {
			return
		}
		mut state := unsafe { &ScriptResource(instance) }
		state.source.clear()
		state.base.clear()
		state.path.clear()
	}
	free_mem(instance)
}

fn script_is_remembered(state voidptr) bool {
	for item in godot_host.scripts {
		if item == state {
			return true
		}
	}
	return false
}

fn virtual_data(class_userdata voidptr, name voidptr, _hash u32) voidptr {
	key := u64(uint(unsafe { *&voidptr(name) }))
	kind := pointer_kind(class_userdata)
	return match kind {
		kind_language { find_method(language_methods, key) }
		kind_script { find_method(script_methods, key) }
		kind_loader { find_method(loader_methods, key) }
		kind_saver { find_method(saver_methods, key) }
		else { unsafe { nil } }
	}
}

fn call_virtual(instance voidptr, _name voidptr, method_data voidptr, args voidptr, ret voidptr) {
	method := unsafe { &MethodDef(method_data) }
	if method.handler == unsafe { nil } {
		write_stub(ret, method.ret)
		return
	}
	call := Call{
		instance: instance
		args:     args
		ret:      ret
	}
	handler := unsafe { CallHandler(method.handler) }
	handler(call)
}
