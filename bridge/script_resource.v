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
