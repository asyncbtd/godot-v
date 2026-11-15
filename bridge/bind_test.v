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

__global critter_seen = 0

fn (mut self TestCritter) ready() {
	self.visits += 1
	critter_seen = self.visits
}

fn (mut self TestCritter) hop() {
	self.visits += 10
	critter_seen = self.visits
}

fn (mut self TestCritter) process(delta f64) {
	self.visits += 2
}

fn test_register_stores_class_and_methods() {
	register[TestCritter]()
	slot := godot_host.registry.get('testcritter') or {
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
	slot := godot_host.registry.get('testcritter') or {
		assert false
		return
	}
	assert slot.methods.len == 5
}

fn test_base_for_registered_and_fallback() {
	register[TestCritter]()
	// The registry key is the lowercased struct name, and script_id_of_path does not
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

fn test_has_method_uses_registry() {
	register[TestCritter]()
	assert godot_host.registry.has_method('res://scripts/testcritter.v', 'hop')
	assert godot_host.registry.has_method('res://scripts/testcritter.v', '_ready')
	assert godot_host.registry.has_method('res://scripts/testcritter.v', 'missing') == false
}

fn test_has_method_ignores_source_text() {
	assert godot_host.registry.has_method('res://scripts/ghost.v', 'ready') == false
}

@[NodeClass('Node')]
struct BasedCritter {
pub mut:
	base Node
}

__global seen_base = unsafe { nil }

fn (mut self BasedCritter) ready() {
	seen_base = self.base.ptr
}

fn test_call_named_writes_base() {
	register[BasedCritter]()
	mut node := 1
	assert call_named[BasedCritter](voidptr(&node), 'ready')
	assert seen_base == voidptr(&node)
}

fn test_call_named_dispatches_methods() {
	register[TestCritter]()
	assert call_named[TestCritter](unsafe { nil }, 'ready')
	assert call_named[TestCritter](unsafe { nil }, '_ready')
	assert call_named[TestCritter](unsafe { nil }, 'hop')
	assert call_named[TestCritter](unsafe { nil }, 'missing') == false
}

struct PlainSprite {}

fn (mut self PlainSprite) idle() {
	plain_hits += 1
}

fn (mut self PlainSprite) ready(_flag bool) {}

fn (mut self PlainSprite) bounce(_speed f64) {}

fn (mut self PlainSprite) dash(_x f64, _y f64) {}

fn (mut self PlainSprite) process() {
	plain_hits += 10
}

@[NodeClass('')]
struct EmptyClassName {}

fn (mut self EmptyClassName) ready() {}

__global plain_hits = 0

fn test_register_skips_methods_that_are_not_callable() {
	register[PlainSprite]()
	slot := godot_host.registry.get('plainsprite') or {
		assert false
		return
	}
	mut methods := slot.methods.clone()
	methods.sort()
	assert slot.base == ''
	assert methods == ['bounce', 'dash', 'idle', 'process', 'ready']
	assert base_for('res://scripts/plainsprite.v') == 'Node'
	plain_hits = 0
	assert call_named[PlainSprite](unsafe { nil }, 'idle')
	assert call_named[PlainSprite](unsafe { nil }, 'process')
	assert call_named[PlainSprite](unsafe { nil }, '_process') == false
	assert call_named[PlainSprite](unsafe { nil }, '_ready') == false
	assert call_named[PlainSprite](unsafe { nil }, 'bounce')
	assert call_named[PlainSprite](unsafe { nil }, 'dash')
	assert call_named[PlainSprite](unsafe { nil }, 'ready')
	assert plain_hits == 11
}

fn test_empty_node_class_falls_back_to_node() {
	register[EmptyClassName]()
	slot := godot_host.registry.get('emptyclassname') or {
		assert false
		return
	}
	assert slot.base == ''
	assert 'ready' in slot.methods
	assert '_ready' in slot.methods
	assert base_for('emptyclassname.v') == 'Node'
}
