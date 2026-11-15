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

fn critter_signal(name string) bool {
	return name == 'hop'
}

fn test_registry_set_updates_existing_binding() {
	registry.set('critter', 'Node', ['ready'])
	registry.set('critter', 'Area2D', ['hop', '_ready'])
	slot := registry.get('critter') or {
		assert false
		return
	}
	assert slot.base == 'Area2D'
	assert slot.methods == ['hop', '_ready']
	assert registry.get('missing') == none
}

fn test_registry_add_script_replaces_hook() {
	registry.add_script('critter', unsafe { nil }, unsafe { nil }, voidptr(critter_signal))
	hook := registry.hook('res://game/critter.v')
	assert call_signal(hook.signal, 'hop')
	assert call_signal(hook.signal, 'idle') == false
	registry.add_script('critter', voidptr(critter_signal), unsafe { nil }, hook.signal)
	assert registry.hook('critter.v').enter == voidptr(critter_signal)
	assert registry.hook('res://missing.v').enter == unsafe { nil }
}

fn test_script_instance_owner_and_callbacks() {
	mut node := 1
	mut resource := 2
	box := ScriptInstance{
		node:     voidptr(&node)
		resource: voidptr(&resource)
	}
	assert box.owner() == voidptr(&node)
	assert box.script() == voidptr(&resource)
	assert box.placeholder() == 0
	assert box.can_die() == 1
	box.notify(0)
	assert script_instance_of(unsafe { nil }) == unsafe { nil }
	assert instance_owner(unsafe { nil }) == unsafe { nil }
	assert instance_owner(voidptr(&box)) == voidptr(&node)
	assert instance_script(voidptr(&box)) == voidptr(&resource)
	assert instance_placeholder(unsafe { nil }) == 0
	assert instance_can_die(unsafe { nil }) == 1
	mut err := 0
	mark_bad(voidptr(&err))
	assert err == 1
	mark_bad(unsafe { nil })
}
