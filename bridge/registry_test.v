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

fn critter_signal(_owner voidptr, name string) bool {
	return name == 'hop'
}

__global enter_calls = 0
__global saw_owner = unsafe { nil }

fn count_enter() {
	enter_calls++
}

fn signal_reads_owner(owner voidptr, name string) bool {
	saw_owner = owner
	return name == 'hop'
}

fn test_registry_set_updates_existing_binding() {
	godot_host.registry.set('critter', 'Node', ['ready'])
	godot_host.registry.set('critter', 'Area2D', ['hop', '_ready'])
	slot := godot_host.registry.get('critter') or {
		assert false
		return
	}
	assert slot.base == 'Area2D'
	assert slot.methods == ['hop', '_ready']
	assert godot_host.registry.get('missing') == none
	godot_host.registry.set('other', 'Node', []string{})
	other := godot_host.registry.get('other') or {
		assert false
		return
	}
	assert other.base == 'Node'
	assert other.methods.len == 0
	mut copy := godot_host.registry.get('critter') or {
		assert false
		return
	}
	copy.base = 'Sprite2D'
	stored := godot_host.registry.get('critter') or {
		assert false
		return
	}
	assert stored.base == 'Area2D'
}

fn test_registry_add_script_replaces_hook() {
	godot_host.registry.add_script('critter', unsafe { nil }, unsafe { nil }, voidptr(critter_signal))
	hook := godot_host.registry.hook('res://game/critter.v')
	assert call_script(hook.call, unsafe { nil }, 'hop')
	assert call_script(hook.call, unsafe { nil }, 'idle') == false
	godot_host.registry.add_script('critter', voidptr(critter_signal), unsafe { nil }, hook.call)
	assert godot_host.registry.hook('critter.v').enter == voidptr(critter_signal)
	assert godot_host.registry.hook('res://missing.v').enter == unsafe { nil }
	assert call_script(unsafe { nil }, unsafe { nil }, 'hop') == false
	assert godot_host.registry.hook('').enter == unsafe { nil }
	assert godot_host.registry.has_method('res://game/critter.v', '') == false
}

fn test_script_instance_owner_and_callbacks() {
	mut node := 1
	mut resource := 2
	mut box := ScriptInstance{
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
	assert instance_script(unsafe { nil }) == unsafe { nil }
	assert instance_has_method(unsafe { nil }, unsafe { nil }) == false
	assert instance_language(unsafe { nil }) == godot_host.api.language
	assert instance_placeholder(voidptr(&box)) == 0
	assert instance_can_die(voidptr(&box)) == 1
	instance_free(unsafe { nil })
	instance_notify(unsafe { nil }, 13, 0)
	mut bad := 0
	mut untouched := u8(4)
	instance_call(unsafe { nil }, unsafe { nil }, unsafe { nil }, 0, voidptr(&untouched),
		voidptr(&bad))
	assert bad == 1
	assert untouched == 4
}

fn test_script_enter_and_call_use_the_empty_path() {
	saved_lib := godot_host.library
	godot_host.library = voidptr(1)
	defer {
		godot_host.library = saved_lib
		godot_host.registry.set('', '', []string{})
		godot_host.registry.add_script('', unsafe { nil }, unsafe { nil }, unsafe { nil })
	}
	mut node := 7
	mut box := ScriptInstance{
		node: voidptr(&node)
	}
	enter_calls = 0
	godot_host.registry.set('', 'Node', ['_ready', 'hop'])
	godot_host.registry.add_script('', voidptr(count_enter), unsafe { nil }, voidptr(signal_reads_owner))
	run_script_enter(unsafe { nil })
	run_script_enter(voidptr(&box))
	box.notify(0)
	instance_notify(voidptr(&box), 12, 1)
	assert enter_calls == 0
	saw_owner = unsafe { nil }
	assert run_script_method(unsafe { nil }, 'hop') == false
	assert run_script_method(voidptr(&box), '') == false
	assert run_script_method(voidptr(&box), 'idle') == false
	assert run_script_method(voidptr(&box), 'hop')
	assert saw_owner == voidptr(&node)
	godot_host.registry.set('', 'Node', ['idle'])
	godot_host.registry.add_script('', unsafe { nil }, unsafe { nil }, unsafe { nil })
	run_script_enter(voidptr(&box))
	assert enter_calls == 0
	godot_host.registry.add_script('', voidptr(count_enter), unsafe { nil }, unsafe { nil })
	run_script_enter(voidptr(&box))
	box.notify(13)
	instance_notify(voidptr(&box), 13, 0)
	assert enter_calls == 3
	mut ret := [24]u8{}
	mut err := [12]u8{}
	unsafe {
		for i in 0 .. ret.len {
			ret[i] = 7
		}
		for i in 0 .. err.len {
			err[i] = 7
		}
		box.call(unsafe { nil }, unsafe { nil }, 0, voidptr(&ret[0]), voidptr(&err[0]))
		assert ret.all(it == 0)
		assert err[0] == 1
		assert err[1] == 0
	}
	box.call(unsafe { nil }, unsafe { nil }, 0, unsafe { nil }, unsafe { nil })
	assert instance_has_method(voidptr(&box), unsafe { nil }) == false
}
