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

@[export: 'godot_v_init']
fn godot_v_init(get_proc_address voidptr, library voidptr, initialization voidptr) u8 {
	C._vinit(0, unsafe { nil })
	godot_host.api.get_proc = get_proc_address
	godot_host.api.library = library
	load_api()
	load_gdf(get_proc_address, library)
	mut startup := unsafe { &Initialization(initialization) }
	startup.minimum_level = level_scene
	startup.userdata = unsafe { nil }
	startup.initialize = voidptr(initialize_level)
	startup.deinitialize = voidptr(deinitialize_level)
	return 1
}

fn initialize_level(_userdata voidptr, level u32) {
	if level != level_scene {
		return
	}
	godot_host.api.editor_hint = method_bind('Engine', 'is_editor_hint', 36873697)
	godot_host.api.engine = singleton('Engine')
	godot_host.api.resource_loader = singleton('ResourceLoader')
	godot_host.api.resource_saver = singleton('ResourceSaver')
	register_classes()
	godot_host.api.language = construct_class(kind_language)
	godot_host.api.loader = construct_class(kind_loader)
	godot_host.api.saver = construct_class(kind_saver)
	mut err := i64(-1)
	call_ptr(godot_host.api.register_language, godot_host.api.engine, voidptr(&godot_host.api.language), voidptr(&err))
	if err != 0 {
		report('register_script_language returned ${err}')
	}
	at_front := u8(1)
	call_ptr2(godot_host.api.add_loader, godot_host.api.resource_loader, voidptr(&godot_host.api.loader), voidptr(&at_front),
		unsafe { nil })
	call_ptr2(godot_host.api.add_saver, godot_host.api.resource_saver, voidptr(&godot_host.api.saver), voidptr(&at_front),
		unsafe { nil })
	if editor_open() == false {
		load_project_scripts()
	}
}

fn deinitialize_level(_userdata voidptr, level u32) {
	if level != level_scene {
		return
	}
	mut err := i64(0)
	if godot_host.api.language != unsafe { nil } {
		language := godot_host.api.language
		call_ptr(godot_host.api.unregister_language, godot_host.api.engine, voidptr(&godot_host.api.language), voidptr(&err))
		godot_host.api.language = unsafe { nil }
		destroy_object(language)
	}
	if godot_host.api.loader != unsafe { nil } {
		call_ptr(godot_host.api.remove_loader, godot_host.api.resource_loader, voidptr(&godot_host.api.loader), voidptr(&err))
		godot_host.api.loader = unsafe { nil }
	}
	if godot_host.api.saver != unsafe { nil } {
		call_ptr(godot_host.api.remove_saver, godot_host.api.resource_saver, voidptr(&godot_host.api.saver), voidptr(&err))
		godot_host.api.saver = unsafe { nil }
	}
	release_kept_names()
}

type ProcAddress = fn (&i8) GDExtensionInterfaceFunctionPtr

fn load_gdf(get_proc_address voidptr, library voidptr) {
	mut interface_fns := &GDExtensionInterfaceFunctions{
		gpaddr: unsafe { ProcAddress(get_proc_address) }
		clp:    library
	}
	interface_load(mut interface_fns)
	gdf = &GDExt{
		GDExtensionInterfaceFunctions: interface_fns
	}
}

fn destroy_object(object voidptr) {
	if object == unsafe { nil } || godot_host.api.destroy_object == unsafe { nil } {
		return
	}
	f := unsafe { MemFree(godot_host.api.destroy_object) }
	f(object)
}
