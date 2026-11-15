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

fn text_from_ptr(ptr &u8, len int) string {
	if ptr == unsafe { nil } || len <= 0 {
		return ''
	}
	return unsafe { tos(ptr, len) }
}

fn bool_to_u8(value bool) u8 {
	if value {
		return 1
	}
	return 0
}

fn temp_variant() voidptr {
	return alloc(24)
}

fn free_variant(ptr voidptr) {
	destroy_variant(ptr)
	free_mem(ptr)
}

fn destroy_variant(ptr voidptr) {
	if ptr == unsafe { nil } || godot_host.api.variant_destroy == unsafe { nil } {
		return
	}
	f := unsafe { VariantDestroy(godot_host.api.variant_destroy) }
	f(ptr)
}
