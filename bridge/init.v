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
	godot_host.api.engine = singleton('Engine')
	godot_host.api.resource_loader = singleton('ResourceLoader')
	godot_host.api.resource_saver = singleton('ResourceSaver')
	register_classes()
	godot_host.api.language = construct_class(kind_language)
	godot_host.api.loader = construct_class(kind_loader)
	godot_host.api.saver = construct_class(kind_saver)
	err := Engine{
		ptr: godot_host.api.engine
	}.register_script_language(ScriptLanguage{
		ptr: godot_host.api.language
	})
	if err != GDError.ok {
		report('register_script_language returned ${int(err)}')
	}
	ResourceLoader{
		ptr: godot_host.api.resource_loader
	}.add_resource_format_loader(ResourceFormatLoader{
		ptr: godot_host.api.loader
	}, at_front: true)
	ResourceSaver{
		ptr: godot_host.api.resource_saver
	}.add_resource_format_saver(ResourceFormatSaver{
		ptr: godot_host.api.saver
	}, at_front: true)
	if editor_open() == false {
		load_project_scripts()
	}
}

fn deinitialize_level(_userdata voidptr, level u32) {
	if level != level_scene {
		return
	}
	if godot_host.api.language != unsafe { nil } {
		language := godot_host.api.language
		Engine{
			ptr: godot_host.api.engine
		}.unregister_script_language(ScriptLanguage{
			ptr: language
		})
		godot_host.api.language = unsafe { nil }
		destroy_object(language)
	}
	if godot_host.api.loader != unsafe { nil } {
		ResourceLoader{
			ptr: godot_host.api.resource_loader
		}.remove_resource_format_loader(ResourceFormatLoader{
			ptr: godot_host.api.loader
		})
		godot_host.api.loader = unsafe { nil }
	}
	if godot_host.api.saver != unsafe { nil } {
		ResourceSaver{
			ptr: godot_host.api.resource_saver
		}.remove_resource_format_saver(ResourceFormatSaver{
			ptr: godot_host.api.saver
		})
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
