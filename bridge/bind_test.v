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

@[NodeClass('Area2D')]
struct TestCritter {
mut:
	visits int
}

fn (mut self TestCritter) ready() {
	self.visits += 1
}

fn (mut self TestCritter) hop() {
	self.visits += 10
}

fn (mut self TestCritter) process(delta f64) {
	self.visits += 2
}

fn test_register_stores_class_and_methods() {
	register[TestCritter]()
	slot := binding_of_key('testcritter') or {
		assert false
		return
	}
	assert slot.base == 'Area2D'
	assert 'ready' in slot.methods
	assert '_ready' in slot.methods
	assert 'hop' in slot.methods
	assert 'process' in slot.methods
	assert '_process' in slot.methods
	assert slot.methods.len == 5
}

fn test_register_updates_existing_slot() {
	register[TestCritter]()
	register[TestCritter]()
	slot := binding_of_key('testcritter') or {
		assert false
		return
	}
	assert slot.methods.len == 5
}

fn test_base_for_registered_and_fallback() {
	register[TestCritter]()
	// The registry key is the lowercased struct name, and script_key does not
	// normalize the file name, so the script file must be named exactly
	// 'testcritter.v' (docs/PLAN.ru.md 1.4.7).
	assert base_for('res://scripts/testcritter.v') == 'Area2D'
	assert base_for('res://scripts/unknown.v') == 'Node'
}

fn test_underscored_filename_misses_the_registry() {
	// Known gap (docs/PLAN.ru.md 1.4.7): 'test_critter.v' does not match the
	// register key 'testcritter', so the lookup falls back to 'Node'.
	// Update this test when the registry key becomes path-based.
	assert base_for('res://scripts/test_critter.v') == 'Node'
}

fn test_answers_uses_registry() {
	register[TestCritter]()
	assert answers('res://scripts/testcritter.v', '', 'hop')
	assert answers('res://scripts/testcritter.v', '', '_ready')
	assert answers('res://scripts/testcritter.v', '', 'missing') == false
}

fn test_answers_falls_back_to_source_scan() {
	assert answers('res://scripts/ghost.v', 'fn (mut self Ghost) ready() {}', 'ready')
	assert answers('res://scripts/ghost.v', "if name == 'jump' {}", 'jump')
	assert answers('res://scripts/ghost.v', 'if name == "jump" {}', 'jump')
	assert answers('res://scripts/ghost.v', '', 'anything') == false
}

fn test_call_named_dispatches_methods() {
	register[TestCritter]()
	assert call_named[TestCritter]('ready')
	assert call_named[TestCritter]('_ready')
	assert call_named[TestCritter]('hop')
	assert call_named[TestCritter]('missing') == false
}
