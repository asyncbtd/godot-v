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

fn prepare_binding() {
	binding.create_callback = voidptr(binding_create)
	binding.free_callback = voidptr(binding_free)
	binding.reference_callback = voidptr(binding_reference)
}

fn binding_create(_token voidptr, object voidptr) voidptr {
	attach_gc_thread()
	mut state := unsafe { &ScriptResource(alloc(uint(sizeof(ScriptResource)))) }
	state.kind = kind_script
	state.object = object
	state.owned = 1
	return voidptr(state)
}

fn binding_free(_token voidptr, _object voidptr, instance voidptr) {
	attach_gc_thread()
	if instance == unsafe { nil } {
		return
	}
	mut state := unsafe { &ScriptResource(instance) }
	if state.kind != kind_script || state.owned == 0 {
		return
	}
	state.source.clear()
	state.base.clear()
	state.path.clear()
	drop_placeholders(instance)
	free_mem(instance)
}

fn binding_reference(_token voidptr, _binding voidptr, _reference u8) u8 {
	return 1
}

fn binding_of(object voidptr) voidptr {
	if object == unsafe { nil } || godot_host.api.get_binding == unsafe { nil } {
		return unsafe { nil }
	}
	f := unsafe { GetBinding(godot_host.api.get_binding) }
	return f(object, godot_host.api.library, voidptr(&binding))
}
