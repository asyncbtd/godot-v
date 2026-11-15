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

const level_scene = u32(2)
const level_editor = u32(3)

const type_bool = 1
const type_int = 2
const type_float = 3
const type_string = 4
const type_vector2 = 5
const type_rect2 = 7
const type_string_name = 21
const type_node_path = 22
const type_object = 24
const type_callable = 25
const type_dictionary = 27
const type_array = 28
const type_packed_string_array = 34

const kind_language = 0
const kind_script = 1
const kind_loader = 2
const kind_saver = 3

const ret_none = 0
const ret_bool = 1
const ret_number = 2
const ret_pointer = 3
const ret_string = 4
const ret_string_name = 5
const ret_dictionary = 6
const ret_array = 7
const ret_packed_string = 8
const ret_variant = 9
