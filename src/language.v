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

fn dispatch(action int, instance voidptr, args voidptr, ret voidptr) {
	match action {
		action_lang_name { write_string(ret, 'V') }
		action_lang_type { write_string(ret, 'VScript') }
		action_lang_extension { write_string(ret, 'v') }
		action_lang_extensions { write_packed(ret, ['v']) }
		action_lang_comments { write_packed(ret, ['//']) }
		action_lang_strings { write_packed(ret, ["'", '"']) }
		action_lang_templates { write_bool(ret, true) }
		action_lang_validate { dictionary_bool(ret, 'valid', true) }
		action_lang_template { write_template(args, ret) }
		action_lang_create { write_pointer(ret, construct_class(kind_script)) }
		action_script_can_instantiate { write_bool(ret, script_can_run(instance)) }
		action_script_instance {
			write_pointer(ret, make_live(script_state(instance), arg_object(args, 0)))
		}
		action_script_has_method {
			write_bool(ret, script_has_method(instance, read_name(arg(args, 0))))
		}
		action_script_reload_file { write_bool(ret, true) }
		action_script_valid { write_bool(ret, true) }
		action_script_reload {
			load_project_scripts()
			write_number(ret, 0)
		}
		action_scripts_refresh { load_project_scripts() }
		action_script_language { write_pointer(ret, api.language) }
		action_script_base { write_script_base(instance, ret) }
		action_script_has_source { write_bool(ret, script_state(instance).source.text().len > 0) }
		action_script_get_source { script_state(instance).source.copy_to(ret) }
		action_script_set_source { set_script_source(instance, arg_string(args, 0)) }
		action_script_placeholder { write_placeholder(instance, args, ret) }
		action_loader_extensions { write_packed(ret, ['v']) }
		action_saver_extensions { write_saver_extensions(args, ret) }
		action_loader_handles { write_bool(ret, handles_script_type(arg(args, 0))) }
		action_loader_type { write_loader_type(args, ret) }
		action_loader_recognize { write_bool(ret, is_v_path(arg_string(args, 0))) }
		action_loader_load { load_script(args, ret) }
		action_saver_recognize { write_bool(ret, is_v_script(arg_object(args, 0))) }
		action_saver_path {
			write_bool(ret, is_v_script(arg_object(args, 0)) && is_v_path(arg_string(args, 1)))
		}
		action_saver_save { save_script(args, ret) }
		else { write_stub(ret, ret_none) }
	}
}

fn write_template(args voidptr, ret voidptr) {
	class_name := arg_string(args, 1)
	base := arg_string(args, 2)
	script := construct_class(kind_script)
	set_script_source(binding_of(script), template_source(class_name, base))
	write_pointer(ret, script)
}

fn template_source(class_name string, base string) string {
	name := if class_name.len == 0 { 'Script' } else { class_name }
	parent := if base.len == 0 { 'Node' } else { base }
	return "@[godot.extends('${parent}')]\npub struct ${name} {\n}\n\npub fn (mut self ${name}) ready() {}\n"
}

fn script_state(instance voidptr) &ScriptState {
	return unsafe { &ScriptState(instance) }
}

fn write_script_base(instance voidptr, ret voidptr) {
	base := script_state(instance).base.text()
	name := if base.len == 0 { 'Node' } else { base }
	write_string_name(ret, name)
}

fn set_script_source(instance voidptr, source string) {
	mut state := unsafe { &ScriptState(instance) }
	state.source.set_text(source)
	state.base.set_text(base_type_from(source))
}

fn set_script_path(instance voidptr, path string) {
	mut state := unsafe { &ScriptState(instance) }
	state.path.set_text(path)
}

fn write_placeholder(instance voidptr, args voidptr, ret voidptr) {
	state := script_state(instance)
	node := arg_object(args, 0)
	f := unsafe { Placeholder(api.placeholder) }
	write_pointer(ret, f(api.language, state.object, node))
}

fn handles_script_type(typ voidptr) bool {
	return same_name(typ, api.script_name) || same_name(typ, api.vscript_name)
}

fn same_name(value voidptr, expected GdString) bool {
	if value == unsafe { nil } || expected.data == unsafe { nil } {
		return false
	}
	return unsafe { *&voidptr(value) } == expected.data
}

fn write_saver_extensions(args voidptr, ret voidptr) {
	if is_v_script(arg_object(args, 0)) {
		write_packed(ret, ['v'])
		return
	}
	write_packed(ret, []string{})
}

fn is_v_path(path string) bool {
	return path.ends_with('.v')
}

fn write_loader_type(args voidptr, ret voidptr) {
	path := arg_string(args, 0)
	if is_v_path(path) {
		write_string(ret, 'VScript')
		return
	}
	write_string(ret, '')
}

fn is_v_script(object voidptr) bool {
	if object == unsafe { nil } {
		return false
	}
	mut name := GdString{}
	ok := class_name_of(object, voidptr(&name))
	same := name.data == api.vscript_name.data
	destroy_string_name(&name)
	return ok && same
}

type ClassNameOf = fn (voidptr, voidptr, voidptr) u8

fn class_name_of(object voidptr, name voidptr) bool {
	f := unsafe { ClassNameOf(api.get_class_name) }
	return f(object, api.library, name) != 0
}

fn load_script(args voidptr, ret voidptr) {
	path := arg_string(args, 0)
	original := arg_string(args, 1)
	resource_path := if original.len > 0 { original } else { path }
	mut path_string := GdString{}
	path_string.set_text(path)
	mut file_text := GdString{}
	call_ptr(api.file_read, unsafe { nil }, voidptr(&path_string), voidptr(&file_text))
	path_string.clear()
	source := file_text.text()
	file_text.clear()
	script := construct_class(kind_script)
	state := binding_of(script)
	set_script_source(state, source)
	set_script_path(state, resource_path)
	remember_script(state)
	variant_object(ret, script)
}

fn release_ref(object voidptr) bool {
	mut die := u8(0)
	call_none(api.unref, object, voidptr(&die))
	if die == 0 {
		return false
	}
	destroy_object(object)
	return true
}

fn save_script(args voidptr, ret voidptr) {
	resource := arg_object(args, 0)
	path := arg_string(args, 1)
	state := unsafe { &ScriptState(binding_of(resource)) }
	mut path_string := GdString{}
	path_string.set_text(path)
	flags := i64(2)
	mut file := voidptr(0)
	call_ptr2(api.file_open, unsafe { nil }, voidptr(&path_string), voidptr(&flags), voidptr(&file))
	path_string.clear()
	if file == unsafe { nil } {
		write_number(ret, 12)
		return
	}
	mut source := GdString{}
	state.source.copy_to(voidptr(&source))
	mut stored := u8(0)
	call_ptr(api.file_store, file, voidptr(&source), voidptr(&stored))
	source.clear()
	call_none(api.file_close, file, unsafe { nil })
	release_ref(file)
	code := if stored == 0 { i64(12) } else { i64(0) }
	write_number(ret, code)
}
