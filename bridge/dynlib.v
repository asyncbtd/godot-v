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

import os

fn C.dlopen(filename &u8, flags int) voidptr

fn C.dlsym(handle voidptr, name &u8) voidptr

fn C.dlerror() &u8

fn C.LoadLibraryA(name &u8) voidptr

fn C.GetProcAddress(handle voidptr, name &u8) voidptr

fn host_library() string {
	text := os.read_file('/proc/self/maps') or { return '' }
	for line in text.split_into_lines() {
		if line.contains('libgodotv.so') == false {
			continue
		}
		start := line.index('/') or { continue }
		return line[start..]
	}
	return ''
}

fn load_error() string {
	$if windows {
		return 'LoadLibrary failed'
	} $else {
		ptr := C.dlerror()
		if ptr == unsafe { nil } {
			return ''
		}
		return unsafe { cstring_to_vstring(ptr) }
	}
}

fn open_shared(path string) voidptr {
	$if windows {
		return C.LoadLibraryA(path.str)
	} $else {
		return C.dlopen(path.str, 10)
	}
}

fn symbol_of(handle voidptr, name string) voidptr {
	$if windows {
		return C.GetProcAddress(handle, name.str)
	} $else {
		return C.dlsym(handle, name.str)
	}
}

fn promote_host() {
	$if windows {
		return
	} $else {
		path := host_library()
		if path.len == 0 {
			return
		}
		C.dlopen(path.str, 262)
	}
}

fn call_symbol(handle voidptr, name string) {
	ptr := symbol_of(handle, name)
	if ptr == unsafe { nil } {
		return
	}
	f := unsafe { EnterFn(ptr) }
	f()
}
