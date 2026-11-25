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
	keep := if ctx.args == unsafe { nil } { false } else { arg_bool(ctx.args, 0) }
	write_number(ctx.ret, reload_game(keep))
}

fn on_scripts_refresh(ctx Call) {
	reload_game(ctx.args != unsafe { nil })
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

fn on_placeholder_erased(ctx Call) {
	forget_placeholder(ctx.instance, arg_object(ctx.args, 0))
}

fn on_script_exports(ctx Call) {
	refresh_exports(ctx.instance)
}

fn on_placeholder_fallback(ctx Call) {
	write_bool(ctx.ret, true)
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
	refresh_exports(instance)
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
	holder := f(godot_host.api.language, state.object, node)
	remember_placeholder(instance, holder)
	write_pointer(ret, holder)
	refresh_exports(instance)
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
		for prop in exported_of(instance) {
			info := property_dictionary(prop)
			push_godot(ret, voidptr(&info), GDExtensionVariantType.type_dictionary)
		}
		return
	}
	for name in names {
		push_named_dict(ret, name)
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

__global placeholders_of = map[u64][]voidptr{}

fn remember_placeholder(instance voidptr, holder voidptr) {
	if instance == unsafe { nil } || holder == unsafe { nil } {
		return
	}
	key := u64(instance)
	mut list := placeholders_of[key] or { []voidptr{} }
	for item in list {
		if item == holder {
			return
		}
	}
	list << holder
	placeholders_of[key] = list
}

fn forget_placeholder(instance voidptr, holder voidptr) {
	if instance == unsafe { nil } {
		return
	}
	key := u64(instance)
	list := placeholders_of[key] or { return }
	mut next := []voidptr{}
	for item in list {
		if item != holder {
			next << item
		}
	}
	if next.len == 0 {
		placeholders_of.delete(key)
		return
	}
	placeholders_of[key] = next
}

fn drop_placeholders(instance voidptr) {
	if instance == unsafe { nil } {
		return
	}
	key := u64(instance)
	if key in placeholders_of {
		placeholders_of.delete(key)
	}
}

fn placeholders_for(instance voidptr) []voidptr {
	return placeholders_of[u64(instance)] or { []voidptr{} }
}

fn exported_of(instance voidptr) []PropRecord {
	if instance == unsafe { nil } {
		return []PropRecord{}
	}
	parsed := parse_outline(script_state(instance).source.text())
	if parsed.props.len > 0 {
		return parsed.props
	}
	mut props := []PropRecord{}
	for prop in outline_of_script(instance).props {
		if prop.exported {
			props << prop
		}
	}
	return props
}

fn property_dictionary(prop PropRecord) Dictionary {
	mut info := Dictionary.new0()
	dict_put_text(voidptr(&info), 'name', prop.name)
	dict_put_int(voidptr(&info), 'type', i64(variant_type_of(prop.typ)))
	dict_put_int(voidptr(&info), 'hint', i64(hint_code(prop.hint)))
	dict_put_text(voidptr(&info), 'hint_string', prop.hint_string)
	dict_put_int(voidptr(&info), 'usage', 4102)
	return info
}

fn refresh_exports(instance voidptr) {
	if gdf == unsafe { nil } || instance == unsafe { nil } {
		return
	}
	holders := placeholders_for(instance)
	if holders.len == 0 {
		return
	}
	mut props := Array.new0()
	mut values := Dictionary.new0()
	for prop in exported_of(instance) {
		info := property_dictionary(prop)
		push_godot(voidptr(&props), voidptr(&info), GDExtensionVariantType.type_dictionary)
		mut value := [24]u8{}
		write_fallback(voidptr(&value[0]), prop)
		dict_put_raw(voidptr(&values), prop.name, voidptr(&value[0]))
		destroy_variant(voidptr(&value[0]))
	}
	update := gdf.placeholder_script_instance_update
	for holder in holders {
		update(holder, voidptr(&props), voidptr(&values))
	}
}

fn write_fallback(dest voidptr, prop PropRecord) {
	match prop.typ {
		'bool' {
			flag := u8(if prop.fallback == 'true' { 1 } else { 0 })
			from := unsafe { TypeCtor(godot_host.api.variant_from_bool) }
			from(dest, voidptr(&flag))
		}
		'int', 'i64' {
			number := prop.fallback.i64()
			variant_number(dest, number)
		}
		'f32', 'f64' {
			number := prop.fallback.f64()
			from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_float)
			from(dest, voidptr(&number))
		}
		'string' {
			mut raw := GdString{}
			raw.set_text(quoted_text(prop.fallback))
			from := unsafe { TypeCtor(godot_host.api.variant_from_string) }
			from(dest, voidptr(&raw))
			raw.clear()
		}
		else {}
	}
}

fn quoted_text(value string) string {
	if value.len >= 2 && (value[0] == `'` || value[0] == `"`) {
		return value[1..value.len - 1]
	}
	return value
}
