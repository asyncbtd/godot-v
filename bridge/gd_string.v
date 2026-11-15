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

#include "@VMODROOT/bridge/string_read.h"

fn C.godot_call_string_read(f voidptr, src voidptr, buf voidptr, n i64) i64

fn string_name(text string) GdString {
	mut name := GdString{}
	f := unsafe { StringNameNew(api.string_name_new) }
	f(voidptr(&name), text.str, 1)
	return name
}

fn destroy_string_name(name &GdString) {
	if name.data == unsafe { nil } {
		return
	}
}

fn (mut s GdString) set_text(text string) {
	s.clear()
	if text == '' {
		return
	}
	f := unsafe { StringNew(api.string_new) }
	f(voidptr(&s), text.str, i64(text.len))
}

fn (s &GdString) text() string {
	if s.data == unsafe { nil } {
		return ''
	}
	return read_gd_string(voidptr(s))
}

fn (mut s GdString) clear() {
	if s.data == unsafe { nil } {
		return
	}
	call := unsafe { TypeCtor(api.string_dtor) }
	call(voidptr(&s), unsafe { nil })
	s.data = unsafe { nil }
}

fn (s &GdString) copy_to(dest voidptr) {
	if s.data == unsafe { nil } {
		zero(dest, 8)
		return
	}
	src := voidptr(s)
	call := unsafe { TypeCtor(api.string_copy) }
	call(dest, voidptr(&src))
}

fn read_name(name voidptr) string {
	if name == unsafe { nil } || api.string_from_name == unsafe { nil } {
		return ''
	}
	mut text := GdString{}
	ctor := unsafe { TypeCtor(api.string_from_name) }
	ctor(voidptr(&text), voidptr(&name))
	value := text.text()
	text.clear()
	return value
}

fn read_gd_string(src voidptr) string {
	len := int(C.godot_call_string_read(api.string_read, src, unsafe { nil }, 0))
	if len <= 0 {
		return ''
	}
	mut out := string{
		str: unsafe { malloc(int(len + 1)) }
		len: len
	}
	C.godot_call_string_read(api.string_read, src, out.str, i64(len))
	unsafe {
		out.str[len] = 0
	}
	return out
}

fn write_string(dest voidptr, text string) {
	if text == '' {
		zero(dest, 8)
		return
	}
	f := unsafe { StringNew(api.string_new) }
	f(dest, text.str, i64(text.len))
}

fn write_string_name(dest voidptr, text string) {
	if text == '' {
		zero(dest, 8)
		return
	}
	f := unsafe { StringNameNew(api.string_name_new) }
	f(dest, text.str, 1)
}

fn keep_name(data voidptr) {
	mut node := unsafe { &NameNode(alloc(uint(sizeof(NameNode)))) }
	node.data = data
	node.next = api.names
	api.names = voidptr(node)
}

fn release_kept_names() {
	destroy_string_name(&api.script_name)
	api.script_name = GdString{}
	destroy_string_name(&api.vscript_name)
	api.vscript_name = GdString{}
	for api.names != unsafe { nil } {
		node := unsafe { &NameNode(api.names) }
		mut name := GdString{
			data: node.data
		}
		api.names = node.next
		destroy_string_name(&name)
		release(voidptr(node))
	}
}
