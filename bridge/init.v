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
	api.get_proc = get_proc_address
	api.library = library
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
	api.editor_hint = method_bind('Engine', 'is_editor_hint', 36873697)
	api.engine = singleton('Engine')
	api.resource_loader = singleton('ResourceLoader')
	api.resource_saver = singleton('ResourceSaver')
	register_classes()
	api.language = construct_class(kind_language)
	api.loader = construct_class(kind_loader)
	api.saver = construct_class(kind_saver)
	mut err := i64(-1)
	call_ptr(api.register_language, api.engine, voidptr(&api.language), voidptr(&err))
	if err != 0 {
		report('register_script_language returned ${err}')
	}
	at_front := u8(1)
	call_ptr2(api.add_loader, api.resource_loader, voidptr(&api.loader), voidptr(&at_front),
		unsafe { nil })
	call_ptr2(api.add_saver, api.resource_saver, voidptr(&api.saver), voidptr(&at_front),
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
	if api.language != unsafe { nil } {
		language := api.language
		call_ptr(api.unregister_language, api.engine, voidptr(&api.language), voidptr(&err))
		api.language = unsafe { nil }
		destroy_object(language)
	}
	if api.loader != unsafe { nil } {
		call_ptr(api.remove_loader, api.resource_loader, voidptr(&api.loader), voidptr(&err))
		api.loader = unsafe { nil }
	}
	if api.saver != unsafe { nil } {
		call_ptr(api.remove_saver, api.resource_saver, voidptr(&api.saver), voidptr(&err))
		api.saver = unsafe { nil }
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
	if object == unsafe { nil } || api.destroy_object == unsafe { nil } {
		return
	}
	f := unsafe { MemFree(api.destroy_object) }
	f(object)
}
