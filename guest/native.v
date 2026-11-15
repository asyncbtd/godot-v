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

struct NativeClass {
	name   string
	parent string
	create fn (voidptr) voidptr
	free   fn (voidptr)
}

__global (
	native_kept  = []&NativeClass{}
	native_bound = map[string]bool{}
)

// register_class records a native extension class Godot can construct.
// create receives the parent object and returns the instance data stored on it.
// free receives that instance data when Godot destroys the object.
pub fn register_class(name string, parent string, create fn (voidptr) voidptr, free fn (voidptr)) {
	if name == '' || parent == '' {
		return
	}
	class := NativeClass{
		name:   name
		parent: parent
		create: create
		free:   free
	}
	held := remember_native(class)
	if godot_host.api.register_class != unsafe { nil } {
		bind_native(held)
	}
}

fn register_native_classes() {
	if godot_host.api.register_class == unsafe { nil } {
		return
	}
	for class in native_kept {
		bind_native(class)
	}
}

fn remember_native(class NativeClass) &NativeClass {
	held := unsafe { &NativeClass(heap_alloc(int(sizeof(NativeClass)))) }
	unsafe {
		*held = class
	}
	native_kept << held
	return held
}

fn bind_native(class &NativeClass) {
	if native_bound[class.name] || godot_host.api.register_class == unsafe { nil } {
		return
	}
	name := string_name(class.name)
	parent_name := string_name(class.parent)
	info := ClassInfo{
		is_exposed:           1
		create_instance_func: voidptr(create_native)
		free_instance_func:   voidptr(free_native)
		class_userdata:       voidptr(class)
	}
	register := unsafe { RegisterClass(godot_host.api.register_class) }
	register(godot_host.api.library, voidptr(&name), voidptr(&parent_name), voidptr(&info))
	destroy_string_name(&name)
	destroy_string_name(&parent_name)
	native_bound[class.name] = true
}

fn create_native(userdata voidptr, notify u8) voidptr {
	class := unsafe { &NativeClass(userdata) }
	parent_name := string_name(class.parent)
	construct := unsafe { Construct(godot_host.api.construct) }
	object := construct(voidptr(&parent_name))
	destroy_string_name(&parent_name)
	instance := if class.create != unsafe { nil } { class.create(object) } else { object }
	name := string_name(class.name)
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

fn free_native(userdata voidptr, instance voidptr) {
	class := unsafe { &NativeClass(userdata) }
	if class.free != unsafe { nil } {
		class.free(instance)
	}
}
