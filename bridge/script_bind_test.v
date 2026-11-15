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

fn test_text_from_ptr_reads_cstring() {
	assert text_from_ptr(unsafe { nil }, 0) == ''
	assert text_from_ptr(unsafe { nil }, 5) == ''
	assert text_from_ptr(c'hello', 5) == 'hello'
	assert text_from_ptr(c'hello', 2) == 'he'
}

fn test_bool_to_u8_converts_bool() {
	assert bool_to_u8(true) == u8(1)
	assert bool_to_u8(false) == u8(0)
}

fn test_script_id_of_path_strips_path_and_suffix() {
	assert script_id_of_path('res://game/player.v') == 'player'
	assert script_id_of_path('player.v') == 'player'
	assert script_id_of_path('res://game/sub/dir/player.v') == 'player'
	assert script_id_of_path('res://game/player') == 'player'
}

fn test_script_library_suffix_matches_platform() {
	$if windows {
		assert script_library_suffix() == '.dll'
	} $else $if macos {
		assert script_library_suffix() == '.dylib'
	} $else {
		assert script_library_suffix() == '.so'
	}
}
