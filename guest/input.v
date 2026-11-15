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

// delta_of reads the process delta of a node.
pub fn delta_of(object voidptr) f64 {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return 0
	}
	return Node{
		ptr: object
	}.get_process_delta_time()
}

// feature reports whether Godot was started with the named feature.
pub fn feature(name string) bool {
	if gdf == unsafe { nil } || name == '' {
		return false
	}
	return OS.singleton().has_feature(name)
}

// action_down reports whether an input action is pressed.
pub fn action_down(name string) bool {
	if gdf == unsafe { nil } || name == '' {
		return false
	}
	return Input.singleton().is_action_pressed(name)
}
