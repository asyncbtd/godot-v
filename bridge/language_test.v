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

fn test_template_source_defaults() {
	assert template_source('', '') == "@[godot.NodeClass('Node')]\npub struct Script {\n}\n\npub fn (mut self Script) ready() {}\n"
}

fn test_template_source_uses_name_and_base() {
	assert template_source('Player', 'Area2D') == "@[godot.NodeClass('Area2D')]\npub struct Player {\n}\n\npub fn (mut self Player) ready() {}\n"
}

fn test_is_v_path() {
	assert is_v_path('res://scripts/player.v')
	assert is_v_path('player.v')
	assert is_v_path('res://scripts/player.gd') == false
	assert is_v_path('res://scripts/player') == false
}
