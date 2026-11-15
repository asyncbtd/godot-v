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

// object_as views ptr as a generated Godot class.
pub fn object_as[T](ptr voidptr) T {
	mut value := T{}
	value.ptr = ptr
	return value
}

// child returns the node at path as T.
pub fn child[T](parent Node, path string) T {
	found := node_at(parent, path)
	return object_as[T](found.ptr)
}

// instantiate_as instantiates the scene as T.
pub fn (s &PackedScene) instantiate_as[T]() T {
	return object_as[T](instance_scene(s.ptr).ptr)
}

fn node_at(parent Node, path string) Node {
	if gdf == unsafe { nil } || parent.ptr == unsafe { nil } || path == '' {
		return Node{}
	}
	route := NodePath.new(path)
	defer {
		route.deinit()
	}
	return Node{
		ptr: parent.ptr
	}.get_node_or_null(route)
}
