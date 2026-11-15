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

struct Host {
mut:
	api      Api
	registry Registry
	names    voidptr
	scripts  []voidptr
	library  voidptr
}

struct HostApi {
	register fn (string, string, fn (voidptr) voidptr, fn (voidptr)) = unsafe { nil }
}

__global godot_host = Host{}

// godot_v_api returns the function table a separately linked game can call once.
pub fn godot_v_api() &HostApi {
	return &HostApi{
		register: register_class
	}
}
