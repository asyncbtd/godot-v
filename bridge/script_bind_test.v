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

fn test_text_of_reads_cstring() {
	assert text_of(unsafe { nil }, 0) == ''
	assert text_of(unsafe { nil }, 5) == ''
	assert text_of(c'hello', 5) == 'hello'
	assert text_of(c'hello', 2) == 'he'
}

fn test_flag_of_converts_bool() {
	assert flag_of(true) == u8(1)
	assert flag_of(false) == u8(0)
}

fn test_source_has_method() {
	assert source_has_method("if name == 'jump' {", 'jump')
	assert source_has_method('if name == "jump" {', 'jump')
	assert source_has_method('fn (mut self Foo) ready() {}', 'ready')
	assert source_has_method('fn (mut self Foo) ready() {}', 'process') == false
	assert source_has_method('', 'ready') == false
	assert source_has_method('fn (mut self Foo) ready() {}', '') == false
}

fn test_script_key_strips_path_and_suffix() {
	assert script_key('res://game/player.v') == 'player'
	assert script_key('player.v') == 'player'
	assert script_key('res://game/sub/dir/player.v') == 'player'
	assert script_key('res://game/player') == 'player'
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
