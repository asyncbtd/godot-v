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

import time

__global (
	gdf = &GDExt(unsafe { nil })
)

pub struct GDExt {
	GDExtensionInterfaceFunctions
}

// setup loads the GDExtension interface and keeps it for later calls.
pub fn setup(gpaddr fn (&i8) GDExtensionInterfaceFunctionPtr, clp GDExtensionClassLibraryPtr) &GDExt {
	C._vinit(0, unsafe { nil })

	mut interface_fns := &GDExtensionInterfaceFunctions{
		gpaddr: gpaddr
		clp:    clp
	}
	interface_load(mut interface_fns)
	gdf = &GDExt{
		GDExtensionInterfaceFunctions: interface_fns
	}
	check_target_version(interface_fns)
	prepare_binds()

	return gdf
}

// check_target_version verifies the running Godot against the bindings: its
// version must be at least the version the bindings were built for.
fn check_target_version(fns &GDExtensionInterfaceFunctions) {
	mut version := GDExtensionGodotVersion2{}
	fns.get_godot_version2(&version)
	target := target_godot_minor()
	if version.major == 4 && int(version.minor) < target {
		panic('GDExtension interface: built for Godot 4.${target}+ but Godot 4.${version.minor} is running, rebuild without -d godot_4_${target}')
	}
	if version.major == 4 && int(version.minor) < godot_base_minor {
		panic('GDExtension interface: Godot 4.${version.minor} is older than the supported 4.${godot_base_minor}')
	}
}

pub struct InfoVersion {
	name        string
	description string
	major       int
	minor       int
	patch       int
	full        string
	time        time.Time
	status      string
	build       string
}

pub struct Info {
	version InfoVersion
	godot   InfoVersion
}

__global (
	class_bind_ptrs   []voidptr
	builtin_bind_ptrs []voidptr
	utility_bind_ptrs []voidptr
)

// prepare_binds allocates the method-bind pointer tables.
pub fn prepare_binds() {
	if class_bind_ptrs.len != class_bind_count {
		class_bind_ptrs = []voidptr{len: class_bind_count, init: unsafe { nil }}
	}
	if builtin_bind_ptrs.len != builtin_bind_count {
		builtin_bind_ptrs = []voidptr{len: builtin_bind_count, init: unsafe { nil }}
	}
	if utility_bind_ptrs.len != utility_bind_count {
		utility_bind_ptrs = []voidptr{len: utility_bind_count, init: unsafe { nil }}
	}
}

fn class_method_bind(index int, class_name string, method string, hash i64) voidptr {
	prepare_binds()
	cached := class_bind_ptrs[index]
	if cached != unsafe { nil } {
		return cached
	}
	classname := StringName.new(class_name)
	fnname := StringName.new(method)
	defer {
		classname.deinit()
		fnname.deinit()
	}
	ptr := gdf.classdb_get_method_bind(&classname, &fnname, hash)
	class_bind_ptrs[index] = ptr
	return ptr
}

fn builtin_method_bind(index int, typ GDExtensionVariantType, method string, hash i64) GDExtensionPtrBuiltInMethod {
	prepare_binds()
	cached := builtin_bind_ptrs[index]
	if cached != unsafe { nil } {
		return GDExtensionPtrBuiltInMethod(cached)
	}
	fnname := StringName.new(method)
	defer {
		fnname.deinit()
	}
	ptr := gdf.variant_get_ptr_builtin_method(typ, &fnname, hash)
	builtin_bind_ptrs[index] = voidptr(ptr)
	return ptr
}

fn utility_function(index int, method string, hash i64) GDExtensionPtrUtilityFunction {
	prepare_binds()
	cached := utility_bind_ptrs[index]
	if cached != unsafe { nil } {
		return GDExtensionPtrUtilityFunction(cached)
	}
	fnname := StringName.new(method)
	defer {
		fnname.deinit()
	}
	ptr := gdf.variant_get_ptr_utility_function(&fnname, hash)
	utility_bind_ptrs[index] = voidptr(ptr)
	return ptr
}
