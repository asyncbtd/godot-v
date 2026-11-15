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

fn C.dlclose(handle voidptr) int

fn C.dlerror() &u8

fn C.LoadLibraryA(name &u8) voidptr

fn C.GetProcAddress(handle voidptr, name &u8) voidptr

fn C.FreeLibrary(handle voidptr) int

fn C.GetLastError() u32

fn C.godot_v_module_address() voidptr

struct C.Dl_info {
	dli_fname &u8
	dli_fbase voidptr
	dli_sname &u8
	dli_saddr voidptr
}

fn C.dladdr(addr voidptr, info &C.Dl_info) int

fn C.GetModuleHandleExA(flags u32, addr voidptr, module &voidptr) int

fn C.GetModuleFileNameA(module voidptr, buf &u8, size u32) u32

__global dyn_error = ''

// dyn_open loads a shared library. A nil handle leaves the reason in dyn_last_error.
fn dyn_open(path string) voidptr {
	$if windows {
		handle := C.LoadLibraryA(path.str)
		if handle == unsafe { nil } {
			dyn_error = 'LoadLibrary failed (${C.GetLastError()})'
			return unsafe { nil }
		}
		dyn_error = ''
		return handle
	} $else {
		C.dlerror()
		handle := C.dlopen(path.str, dyn_open_flags())
		if handle == unsafe { nil } {
			dyn_error = dyn_c_error()
			return unsafe { nil }
		}
		dyn_error = ''
		return handle
	}
}

// dyn_symbol looks up an exported symbol. A miss returns nil and does not change dyn_last_error.
fn dyn_symbol(handle voidptr, name string) voidptr {
	if handle == unsafe { nil } {
		return unsafe { nil }
	}
	$if windows {
		return C.GetProcAddress(handle, name.str)
	} $else {
		return C.dlsym(handle, name.str)
	}
}

// dyn_close unloads a library opened with dyn_open. A nil handle is ignored.
fn dyn_close(handle voidptr) {
	if handle == unsafe { nil } {
		return
	}
	$if windows {
		if C.FreeLibrary(handle) == 0 {
			dyn_error = 'FreeLibrary failed (${C.GetLastError()})'
		}
	} $else {
		if C.dlclose(handle) != 0 {
			dyn_error = dyn_c_error()
		}
	}
}

// dyn_last_error is the text of the last failed open or close.
fn dyn_last_error() string {
	return dyn_error
}

fn dyn_open_flags() int {
	// RTLD_NOW combined with the global/deep-bind bit this loader already used (10).
	return 10
}

fn dyn_promote_flags() int {
	// RTLD_NOW | RTLD_NOLOAD | RTLD_GLOBAL, so an already mapped host stays visible to the game library.
	$if macos {
		return 26
	} $else {
		return 262
	}
}

fn dyn_c_error() string {
	ptr := C.dlerror()
	if ptr == unsafe { nil } {
		return ''
	}
	return unsafe { cstring_to_vstring(ptr) }
}

fn dyn_promote(path string) {
	if path == '' {
		return
	}
	$if windows {
		C.LoadLibraryA(path.str)
	} $else {
		C.dlopen(path.str, dyn_promote_flags())
	}
}

fn shared_library_file(path string) bool {
	return path.ends_with('.so') || path.ends_with('.dll') || path.ends_with('.dylib')
}

fn loaded_module_path() string {
	addr := C.godot_v_module_address()
	$if windows {
		mut handle := voidptr(0)
		if C.GetModuleHandleExA(u32(0x4 | 0x2), addr, &handle) == 0 || handle == unsafe { nil } {
			return ''
		}
		buf := []u8{len: 4096}
		n := int(C.GetModuleFileNameA(handle, buf.data, 4096))
		if n <= 0 {
			return ''
		}
		return unsafe { tos(buf.data, n) }.clone()
	} $else {
		info := C.Dl_info{}
		if C.dladdr(addr, &info) == 0 || info.dli_fname == unsafe { nil } {
			return ''
		}
		return unsafe { cstring_to_vstring(info.dli_fname) }
	}
}

fn mapped_host_library() string {
	$if windows {
		return ''
	} $else $if macos {
		return ''
	} $else {
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
}

fn host_library() string {
	path := loaded_module_path()
	if shared_library_file(path) {
		return path
	}
	return mapped_host_library()
}

fn promote_host() {
	dyn_promote(host_library())
}

fn call_symbol(handle voidptr, name string) {
	ptr := dyn_symbol(handle, name)
	if ptr == unsafe { nil } {
		return
	}
	f := unsafe { EnterFn(ptr) }
	f()
}

fn open_shared(path string) voidptr {
	return dyn_open(path)
}

fn symbol_of(handle voidptr, name string) voidptr {
	return dyn_symbol(handle, name)
}

fn load_error() string {
	return dyn_last_error()
}
