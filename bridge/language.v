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

fn write_validate(dest voidptr, report ValidateReport) {
	if dest == unsafe { nil } || godot_host.api.new_dictionary == unsafe { nil } {
		return
	}
	write_dictionary(dest)
	dict_put_bool(dest, 'valid', report.errors.len == 0)
	if gdf == unsafe { nil } {
		return
	}
	errors := issue_variant(report.errors)
	warnings := issue_variant(report.warnings)
	functions := function_variant(report.functions)
	dict_put_raw(dest, 'errors', errors)
	dict_put_raw(dest, 'warnings', warnings)
	dict_put_raw(dest, 'functions', functions)
	release_variant(errors)
	release_variant(warnings)
	release_variant(functions)
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
		destroy_variant(voidptr(&wrapped[0]))
		release_godot(item, GDExtensionVariantType.type_dictionary)
	}
	wrapped := heap_alloc(24)
	from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_array)
	from(wrapped, list)
	release_godot(list, GDExtensionVariantType.type_array)
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
		destroy_variant(voidptr(&wrapped[0]))
		release_godot(item, GDExtensionVariantType.type_dictionary)
	}
	wrapped := heap_alloc(24)
	from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_array)
	from(wrapped, list)
	release_godot(list, GDExtensionVariantType.type_array)
	return wrapped
}
