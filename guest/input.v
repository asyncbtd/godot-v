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

// feature reports whether Godot was started with the named feature.
pub fn feature(name string) bool {
	return feature_impl(name)
}

// action_down reports whether an input action is pressed.
pub fn action_down(name string) bool {
	return action_down_impl(name)
}

// delta_of reads the process delta of a node.
pub fn delta_of(object voidptr) f64 {
	return delta_of_impl(object)
}

fn delta_of_impl(object voidptr) f64 {
	ret := scratch()
	ok := invoke(object, 'get_process_delta_time', []voidptr{}, ret)
	mut value := f64(0)
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_float)) }
		to(voidptr(&value), ret)
	}
	free_variant(ret)
	return value
}

fn feature_impl(name string) bool {
	target := singleton('OS')
	mut text := GdString{}
	text.set_text(name)
	slot := scratch()
	put_string(slot, text)
	ret := scratch()
	ok := invoke(target, 'has_feature', [slot], ret)
	mut flag := u8(0)
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_bool)) }
		to(voidptr(&flag), ret)
	}
	free_variant(slot)
	free_variant(ret)
	text.clear()
	return flag != 0
}

fn action_down_impl(name string) bool {
	input := singleton('Input')
	stored := cached_name(name)
	slot := scratch()
	put_name(slot, stored)
	ret := scratch()
	ok := invoke(input, 'is_action_pressed', [slot], ret)
	mut flag := u8(0)
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_bool)) }
		to(voidptr(&flag), ret)
	}
	free_variant(slot)
	free_variant(ret)
	return flag != 0
}
