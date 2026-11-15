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
	registry.add_script('main', voidptr(enter), unsafe { nil }, voidptr(signal))
}

// register_player stores the callbacks for a player script.
pub fn register_player(enter fn (), frame fn (f64), signal fn (string) bool) {
	registry.add_script('player', voidptr(enter), voidptr(frame), voidptr(signal))
}

// register_mob stores the callback for a mob script.
pub fn register_mob(enter fn ()) {
	registry.add_script('mob', voidptr(enter), unsafe { nil }, unsafe { nil })
}

// instance_scene instantiates a packed scene.
pub fn instance_scene(scene voidptr) voidptr {
	if gdf == unsafe { nil } || scene == unsafe { nil } {
		return unsafe { nil }
	}
	packed := PackedScene{
		ptr: scene
	}
	return packed.instantiate().ptr
}

// load_resource loads the resource at path.
pub fn load_resource(path string) voidptr {
	if gdf == unsafe { nil } || path == '' {
		return unsafe { nil }
	}
	found := ResourceLoader.singleton().load(path)
	if found.ptr != unsafe { nil } {
		RefCounted{
			ptr: found.ptr
		}.reference()
	}
	return found.ptr
}

// load_scene loads a packed scene at path.
pub fn load_scene(path string) PackedScene {
	return object_as[PackedScene](load_resource(path))
}

// autoload returns the autoload node registered under name.
pub fn autoload(name string) Node {
	if gdf == unsafe { nil } || name == '' {
		return Node{}
	}
	loop := Engine.singleton().get_main_loop()
	tree := SceneTree{
		MainLoop: loop
	}
	root := tree.get_root()
	route := NodePath.new('/root/${name}')
	defer {
		route.deinit()
	}
	return Node{
		ptr: root.ptr
	}.get_node_or_null(route)
}

fn init() {
	active_session = unsafe { &host_session }
}
