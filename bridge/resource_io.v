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

fn on_loader_extensions(ctx Call) {
	write_packed(ctx.ret, ['v'])
}

fn on_saver_extensions(ctx Call) {
	write_saver_extensions(ctx.args, ctx.ret)
}

fn on_loader_handles(ctx Call) {
	write_bool(ctx.ret, handles_script_type(arg(ctx.args, 0)))
}

fn on_loader_type(ctx Call) {
	write_loader_type(ctx.args, ctx.ret)
}

fn on_loader_recognize(ctx Call) {
	write_bool(ctx.ret, is_v_path(arg_string(ctx.args, 0)))
}

fn on_loader_load(ctx Call) {
	load_script(ctx.args, ctx.ret)
}

fn on_saver_recognize(ctx Call) {
	write_bool(ctx.ret, is_v_script(arg_object(ctx.args, 0)))
}

fn on_saver_path(ctx Call) {
	write_bool(ctx.ret, is_v_script(arg_object(ctx.args, 0)) && is_v_path(arg_string(ctx.args, 1)))
}

fn on_saver_save(ctx Call) {
	save_script(ctx.args, ctx.ret)
}

fn handles_script_type(typ voidptr) bool {
	return same_name(typ, godot_host.api.script_name) || same_name(typ, godot_host.api.vscript_name)
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
	same := name.data == godot_host.api.vscript_name.data
	destroy_string_name(&name)
	return ok && same
}

type ClassNameOf = fn (voidptr, voidptr, voidptr) u8

fn class_name_of(object voidptr, name voidptr) bool {
	f := unsafe { ClassNameOf(godot_host.api.get_class_name) }
	return f(object, godot_host.api.library, name) != 0
}

fn load_script(args voidptr, ret voidptr) {
	if gdf == unsafe { nil } {
		return
	}
	path := arg_string(args, 0)
	original := arg_string(args, 1)
	resource_path := if original.len > 0 { original } else { path }
	source := FileAccess.get_file_as_string(path)
	script := construct_class(kind_script)
	state := binding_of(script)
	set_script_source(state, source)
	set_script_path(state, resource_path)
	remember_script(state)
	variant_object(ret, script)
}

fn release_ref(object voidptr) bool {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return false
	}
	if RefCounted{
		ptr: object
	}.unreference() == false {
		return false
	}
	destroy_object(object)
	return true
}

fn save_script(args voidptr, ret voidptr) {
	if gdf == unsafe { nil } {
		write_number(ret, 12)
		return
	}
	resource := arg_object(args, 0)
	path := arg_string(args, 1)
	state := unsafe { &ScriptResource(binding_of(resource)) }
	file := FileAccess.open(path, FileAccessModeFlags.write)
	if file.ptr == unsafe { nil } {
		write_number(ret, 12)
		return
	}
	stored := file.store_string(state.source.text())
	file.close()
	release_ref(file.ptr)
	code := if stored { i64(0) } else { i64(12) }
	write_number(ret, code)
}
