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

fn on_lang_name(ctx Call) {
	write_string(ctx.ret, 'V')
}

fn on_lang_type(ctx Call) {
	write_string(ctx.ret, 'VScript')
}

fn on_lang_extension(ctx Call) {
	write_string(ctx.ret, 'v')
}

fn on_lang_extensions(ctx Call) {
	write_packed(ctx.ret, ['v'])
}

fn on_lang_comments(ctx Call) {
	write_packed(ctx.ret, ['//'])
}

fn on_lang_reserved(ctx Call) {
	write_packed(ctx.ret, v_keywords())
}

fn on_lang_flow(ctx Call) {
	write_bool(ctx.ret, is_v_flow(arg_string(ctx.args, 0)))
}

fn on_lang_doc(ctx Call) {
	write_packed(ctx.ret, doc_comment_delimiters())
}

fn on_lang_builtin(ctx Call) {
	write_builtin_templates(ctx.ret, arg_string(ctx.args, 0))
}

fn on_lang_path(ctx Call) {
	write_string(ctx.ret, path_problem(arg_string(ctx.args, 0)))
}

fn on_lang_global_type(ctx Call) {
	write_bool(ctx.ret, handles_global_class(arg_string(ctx.args, 0)))
}

fn on_lang_global_class(ctx Call) {
	write_global_class(ctx.ret, global_class_at(arg_string(ctx.args, 0)))
}

fn on_lang_open(ctx Call) {
	write_number(ctx.ret, open_in_editor(arg_object(ctx.args, 0), arg_i64(ctx.args, 1), arg_i64(ctx.args,
		2)))
}

fn on_lang_external(ctx Call) {
	write_bool(ctx.ret, editor_program().len > 0)
}

fn on_lang_strings(ctx Call) {
	write_packed(ctx.ret, ["'", '"'])
}

fn on_lang_templates(ctx Call) {
	write_bool(ctx.ret, true)
}

fn on_lang_validate(ctx Call) {
	write_validate(ctx.ret, validate_source(arg_string(ctx.args, 0)))
}

fn on_lang_find(ctx Call) {
	write_number(ctx.ret, i64(find_function_line(arg_string(ctx.args, 0), arg_string(ctx.args, 1))))
}

fn on_lang_template(ctx Call) {
	write_template(ctx.args, ctx.ret)
}

fn on_lang_create(ctx Call) {
	write_pointer(ctx.ret, construct_class(kind_script))
}

fn on_script_can_instantiate(ctx Call) {
	write_bool(ctx.ret, script_can_run(ctx.instance))
}

fn on_script_instance(ctx Call) {
	write_pointer(ctx.ret, make_live(script_state(ctx.instance), arg_object(ctx.args, 0)))
}

fn on_script_has_method(ctx Call) {
	write_bool(ctx.ret, script_has_method(ctx.instance, read_name(arg(ctx.args, 0))))
}

fn on_script_methods(ctx Call) {
	write_methods(ctx.instance, ctx.ret)
}

fn on_script_member(ctx Call) {
	write_number(ctx.ret, i64(member_line_of(ctx.instance, read_name(arg(ctx.args, 0)))))
}

fn on_script_has_signal(ctx Call) {
	write_bool(ctx.ret, script_has_signal_name(ctx.instance, read_name(arg(ctx.args, 0))))
}

fn on_script_signals(ctx Call) {
	write_named_list(ctx.instance, ctx.ret, 'signal')
}

fn on_script_properties(ctx Call) {
	write_named_list(ctx.instance, ctx.ret, 'prop')
}

fn on_script_arg_count(ctx Call) {
	write_arg_count(ctx.instance, read_name(arg(ctx.args, 0)), ctx.ret)
}

fn on_script_global(ctx Call) {
	write_string_name(ctx.ret, script_facts(ctx.instance).name)
}

fn on_script_tool(ctx Call) {
	write_bool(ctx.ret, script_facts(ctx.instance).tool)
}

fn on_script_abstract(ctx Call) {
	write_bool(ctx.ret, script_facts(ctx.instance).abstract)
}

fn on_script_icon(ctx Call) {
	write_string(ctx.ret, script_facts(ctx.instance).icon)
}

fn on_script_rpc(ctx Call) {
	write_rpc_config(ctx.ret, script_facts(ctx.instance).rpcs)
}

fn on_script_reload_file(ctx Call) {
	write_bool(ctx.ret, true)
}

fn on_script_valid(ctx Call) {
	write_bool(ctx.ret, true)
}

fn on_script_reload(ctx Call) {
	load_project_scripts()
	write_number(ctx.ret, 0)
}

fn on_scripts_refresh(_ctx Call) {
	load_project_scripts()
}

fn on_script_language(ctx Call) {
	write_pointer(ctx.ret, godot_host.api.language)
}

fn on_script_base(ctx Call) {
	write_script_base(ctx.instance, ctx.ret)
}

fn on_script_has_source(ctx Call) {
	write_bool(ctx.ret, script_state(ctx.instance).source.text().len > 0)
}

fn on_script_get_source(ctx Call) {
	script_state(ctx.instance).source.copy_to(ctx.ret)
}

fn on_script_set_source(ctx Call) {
	set_script_source(ctx.instance, arg_string(ctx.args, 0))
}

fn on_script_placeholder(ctx Call) {
	write_placeholder(ctx.instance, ctx.args, ctx.ret)
}

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

fn write_template(args voidptr, ret voidptr) {
	class_name := arg_string(args, 1)
	base := arg_string(args, 2)
	script := construct_class(kind_script)
	set_script_source(binding_of(script), template_source(class_name, base))
	write_pointer(ret, script)
}

fn template_source(class_name string, base string) string {
	name := if class_name == '' { 'Script' } else { class_name }
	parent := if base == '' { 'Node' } else { base }
	return "@[godot.NodeClass('${parent}')]\npub struct ${name} {\n}\n\npub fn (mut self ${name}) ready() {}\n"
}

fn script_state(instance voidptr) &ScriptResource {
	return unsafe { &ScriptResource(instance) }
}

fn write_script_base(instance voidptr, ret voidptr) {
	base := script_state(instance).base.text()
	name := if base.len == 0 { 'Node' } else { base }
	write_string_name(ret, name)
}

fn set_script_source(instance voidptr, source string) {
	mut state := unsafe { &ScriptResource(instance) }
	state.source.set_text(source)
	refresh_base(mut state)
}

fn set_script_path(instance voidptr, path string) {
	mut state := unsafe { &ScriptResource(instance) }
	state.path.set_text(path)
	refresh_base(mut state)
}

fn write_placeholder(instance voidptr, args voidptr, ret voidptr) {
	state := script_state(instance)
	node := arg_object(args, 0)
	f := unsafe { Placeholder(godot_host.api.placeholder) }
	write_pointer(ret, f(godot_host.api.language, state.object, node))
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

fn write_named_list(instance voidptr, ret voidptr, kind string) {
	if godot_host.api.new_array == unsafe { nil } {
		return
	}
	write_array(ret)
	outline := outline_of_script(instance)
	mut names := []string{}
	if kind == 'signal' {
		for signal in outline.signals {
			names << signal.name
		}
	} else {
		for prop in outline.props {
			if prop.exported {
				names << prop.name
			}
		}
	}
	for name in names {
		item := temp_variant()
		dictionary_text(item, 'name', name)
		push_array(ret, item)
		free_variant(item)
	}
}

fn write_arg_count(instance voidptr, name string, ret voidptr) {
	if ret == unsafe { nil } {
		return
	}
	zero(ret, 24)
	if gdf == unsafe { nil } {
		return
	}
	plain := if name.starts_with('_') { name[1..] } else { name }
	for method in outline_of_script(instance).methods {
		if method.name == name || method.name == plain {
			value := i64(method.args.len)
			from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_int)
			from(ret, voidptr(&value))
			return
		}
	}
}

fn write_validate(dest voidptr, report ValidateReport) {
	if dest == unsafe { nil } || godot_host.api.new_dictionary == unsafe { nil } {
		return
	}
	write_dictionary(dest)
	dict_put_bool(dest, 'valid', report.errors.len == 0)
	if gdf == unsafe { nil } {
		return
	}
	dict_put_raw(dest, 'errors', issue_variant(report.errors))
	dict_put_raw(dest, 'warnings', issue_variant(report.warnings))
	dict_put_raw(dest, 'functions', function_variant(report.functions))
}

fn dict_put_bool(dest voidptr, key string, value bool) {
	mut key_string := GdString{}
	key_string.set_text(key)
	mut key_variant := [24]u8{}
	mut value_variant := [24]u8{}
	from_string := unsafe { TypeCtor(godot_host.api.variant_from_string) }
	from_bool := unsafe { TypeCtor(godot_host.api.variant_from_bool) }
	flag := u8(if value { 1 } else { 0 })
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_bool(voidptr(&value_variant[0]), voidptr(&flag))
		set := KeyedSet(godot_host.api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(godot_host.api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
		destroy(voidptr(&value_variant[0]))
	}
	key_string.clear()
}

fn dict_put_int(dest voidptr, key string, value i64) {
	mut key_string := GdString{}
	key_string.set_text(key)
	mut key_variant := [24]u8{}
	mut value_variant := [24]u8{}
	from_string := unsafe { TypeCtor(godot_host.api.variant_from_string) }
	from_int := unsafe { TypeCtor(godot_host.api.variant_from_int) }
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_int(voidptr(&value_variant[0]), voidptr(&value))
		set := KeyedSet(godot_host.api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(godot_host.api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
		destroy(voidptr(&value_variant[0]))
	}
	key_string.clear()
}

fn dict_put_text(dest voidptr, key string, value string) {
	mut key_string := GdString{}
	key_string.set_text(key)
	mut value_string := GdString{}
	value_string.set_text(value)
	mut key_variant := [24]u8{}
	mut value_variant := [24]u8{}
	from_string := unsafe { TypeCtor(godot_host.api.variant_from_string) }
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_string(voidptr(&value_variant[0]), voidptr(&value_string))
		set := KeyedSet(godot_host.api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(godot_host.api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
		destroy(voidptr(&value_variant[0]))
	}
	key_string.clear()
	value_string.clear()
}

fn dict_put_raw(dest voidptr, key string, value voidptr) {
	mut key_string := GdString{}
	key_string.set_text(key)
	mut key_variant := [24]u8{}
	from_string := unsafe { TypeCtor(godot_host.api.variant_from_string) }
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		set := KeyedSet(godot_host.api.dict_set)
		set(dest, voidptr(&key_variant[0]), value)
		destroy := VariantDestroy(godot_host.api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
	}
	key_string.clear()
}

fn issue_variant(issues []ScriptIssue) voidptr {
	list := heap_alloc(24)
	write_array(list)
	for issue in issues {
		item := heap_alloc(24)
		write_dictionary(item)
		dict_put_int(item, 'line', i64(issue.line))
		dict_put_int(item, 'column', i64(issue.column))
		dict_put_text(item, 'message', issue.message)
		mut wrapped := [24]u8{}
		from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_dictionary)
		from(voidptr(&wrapped[0]), item)
		push_array(list, voidptr(&wrapped[0]))
	}
	wrapped := heap_alloc(24)
	from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_array)
	from(wrapped, list)
	return wrapped
}

fn function_variant(methods []MethodRecord) voidptr {
	list := heap_alloc(24)
	write_array(list)
	for method in methods {
		item := heap_alloc(24)
		write_dictionary(item)
		dict_put_text(item, 'name', method.name)
		dict_put_int(item, 'line', i64(method.line))
		mut wrapped := [24]u8{}
		from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_dictionary)
		from(voidptr(&wrapped[0]), item)
		push_array(list, voidptr(&wrapped[0]))
	}
	wrapped := heap_alloc(24)
	from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_array)
	from(wrapped, list)
	return wrapped
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
	path := arg_string(args, 0)
	original := arg_string(args, 1)
	resource_path := if original.len > 0 { original } else { path }
	mut path_string := GdString{}
	path_string.set_text(path)
	mut file_text := GdString{}
	call_ptr(godot_host.api.file_read, unsafe { nil }, voidptr(&path_string), voidptr(&file_text))
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
	call_none(godot_host.api.unref, object, voidptr(&die))
	if die == 0 {
		return false
	}
	destroy_object(object)
	return true
}

fn save_script(args voidptr, ret voidptr) {
	resource := arg_object(args, 0)
	path := arg_string(args, 1)
	state := unsafe { &ScriptResource(binding_of(resource)) }
	mut path_string := GdString{}
	path_string.set_text(path)
	flags := i64(2)
	mut file := voidptr(0)
	call_ptr2(godot_host.api.file_open, unsafe { nil }, voidptr(&path_string), voidptr(&flags), voidptr(&file))
	path_string.clear()
	if file == unsafe { nil } {
		write_number(ret, 12)
		return
	}
	mut source := GdString{}
	state.source.copy_to(voidptr(&source))
	mut stored := u8(0)
	call_ptr(godot_host.api.file_store, file, voidptr(&source), voidptr(&stored))
	source.clear()
	call_none(godot_host.api.file_close, file, unsafe { nil })
	release_ref(file)
	code := if stored == 0 { i64(12) } else { i64(0) }
	write_number(ret, code)
}
