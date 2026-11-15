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

fn version_at_target(version &GDExtensionGodotVersion2) {
	unsafe {
		version.major = 4
		version.minor = u32(target_godot_minor())
		version.patch = 1
	}
}

fn version_newer_than_target(version &GDExtensionGodotVersion2) {
	unsafe {
		version.major = 4
		version.minor = u32(target_godot_minor() + 1)
	}
}

fn version_other_major(version &GDExtensionGodotVersion2) {
	unsafe {
		version.major = 3
		version.minor = 0
	}
}

fn test_check_target_version_accepts_compatible_engines() {
	mut fns := &GDExtensionInterfaceFunctions{
		gpaddr:             unsafe { nil }
		clp:                unsafe { nil }
		get_godot_version2: version_at_target
	}
	check_target_version(fns)
	fns.get_godot_version2 = version_newer_than_target
	check_target_version(fns)
	fns.get_godot_version2 = version_other_major
	check_target_version(fns)
}

fn test_prepare_binds_sizes_tables_once() {
	prepare_binds()
	assert class_bind_ptrs.len == class_bind_count
	assert builtin_bind_ptrs.len == builtin_bind_count
	assert utility_bind_ptrs.len == utility_bind_count
	prepare_binds()
	assert class_bind_ptrs.len == class_bind_count
	assert builtin_bind_ptrs.len == builtin_bind_count
	assert utility_bind_ptrs.len == utility_bind_count
}
