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

__global host_session Session

// register_main stores the callbacks for a main script.
pub fn register_main(enter fn (), signal fn (string) bool) {
	bind_script('main', voidptr(enter), unsafe { nil }, voidptr(signal))
}

// register_player stores the callbacks for a player script.
pub fn register_player(enter fn (), frame fn (f64), signal fn (string) bool) {
	bind_script('player', voidptr(enter), voidptr(frame), voidptr(signal))
}

// register_mob stores the callback for a mob script.
pub fn register_mob(enter fn ()) {
	bind_script('mob', voidptr(enter), unsafe { nil }, unsafe { nil })
}

// live returns the session shared by the running scripts.
pub fn live() &Session {
	return active_session
}

// load_resource loads the resource at path.
pub fn load_resource(path string) voidptr {
	return load_resource_impl(path)
}

// instance_scene instantiates a packed scene.
pub fn instance_scene(scene voidptr) voidptr {
	return call_object(scene, 'instantiate')
}

fn init() {
	active_session = unsafe { &host_session }
}

fn load_resource_impl(path string) voidptr {
	loader := singleton('ResourceLoader')
	mut text := GdString{}
	text.set_text(path)
	slot := scratch()
	put_string(slot, text)
	ret := scratch()
	ok := invoke(loader, 'load', [slot], ret)
	found := variant_object_ptr(ret)
	if ok && found != unsafe { nil } {
		keep_ref(found)
	}
	free_variant(slot)
	free_variant(ret)
	text.clear()
	if ok == false {
		return unsafe { nil }
	}
	return found
}
