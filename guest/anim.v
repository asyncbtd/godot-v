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

// play_anim plays an animation, or the current one when name is empty.
pub fn play_anim(object voidptr, name string) {
	play_anim_impl(object, name)
}

// stop_anim stops an animated sprite.
pub fn stop_anim(object voidptr) {
	call_void(object, 'stop')
}

fn play_anim_impl(object voidptr, name string) {
	if name == '' {
		call_void(object, 'play')
		return
	}
	stored := cached_name(name)
	slot := scratch()
	put_name(slot, stored)
	call_with(object, 'play', slot)
	free_variant(slot)
}
