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

fn test_object_as_keeps_the_pointer() {
	ptr := voidptr(1)
	node := object_as[Node](ptr)
	assert node.ptr == ptr
	body := object_as[Node2D](ptr)
	assert body.ptr == ptr
	scene := object_as[PackedScene](ptr)
	assert scene.ptr == ptr
}

fn test_child_and_autoload_stay_empty_without_godot() {
	assert child[Timer](Node{}, 'ScoreTimer').ptr == unsafe { nil }
	assert autoload('Game').ptr == unsafe { nil }
	assert load_scene('res://node/mob.tscn').ptr == unsafe { nil }
	assert PackedScene{}.instantiate_as[Node]().ptr == unsafe { nil }
}

fn test_register_class_queues_a_native_class() {
	before := native_kept.len
	register_class('Marker', 'Node2D', unsafe { nil }, unsafe { nil })
	assert native_kept.len == before + 1
	assert native_kept.last().name == 'Marker'
	assert native_kept.last().parent == 'Node2D'
	assert native_bound['Marker'] == false
	register_class('', 'Node', unsafe { nil }, unsafe { nil })
	assert native_kept.len == before + 1
	held := native_kept.last()
	native_kept.delete_last()
	native_bound.delete('Marker')
	heap_free(held)
}
