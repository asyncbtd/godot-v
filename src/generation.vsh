#!/usr/bin/env -S v run

// Adapted from gdext-v (https://github.com/rawsp33d/gdext-v).
// Copyright (c) 2025 Ross Hadden
//
// Modifications Copyright 2026 Timofey Brukhanchik
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

module main

import crypto.sha256
import os
import generator { Generator }

fn quote(path string) string {
	mut out := [u8(39)]
	for ch in path {
		if ch == u8(39) {
			out << u8(39)
			out << u8(92)
			out << u8(39)
			out << u8(39)
		} else {
			out << ch
		}
	}
	out << u8(39)
	return out.bytestr()
}

fn cache_dir() string {
	raw := os.getenv('GODOT_V_CACHE')
	if raw == '' {
		eprintln('GODOT_V_CACHE is not set')
		exit(1)
	}
	return raw
}

fn json_field(dump string, key string) string {
	needle := '"${key}": "'
	start := dump.index(needle) or { return '' }
	rest := dump[start + needle.len..]
	end := rest.index('"') or { return '' }
	return rest[..end]
}

fn copy_runtime(out_dir string) {
	for name in ['gdext.v', 'interface.v', 'variant.v', 'object.v'] {
		text := os.read_file('src/gdext/${name}') or { panic(err) }
		os.write_file(os.join_path(out_dir, name), text) or { panic(err) }
	}
}

fn main() {
	os.chdir(@VMODROOT) or { panic(err) }
	cache := cache_dir()
	out_dir := os.join_path(cache, 'gdext')
	dump_path := os.join_path(cache, 'extension_api.json')
	hash_path := os.join_path(cache, 'extension_api.sha256')
	dump := os.read_file(dump_path) or { panic(err) }
	sum := sha256.hexhash(dump)
	label := json_field(dump, 'version_full_name')
	precision := json_field(dump, 'precision')
	println('API ${label} precision ${precision}')
	previous := os.read_file(hash_path) or { '' }
	if previous.trim_space() == sum && os.exists(os.join_path(out_dir, '__info.v')) {
		println('API unchanged, bindings are up to date.')
		return
	}
	println('Generating V bindings into ${out_dir}...')
	os.mkdir_all(out_dir) or { panic(err) }
	os.execute('rm -f ${quote(out_dir)}/_*.v')
	mut gen := Generator.new(dump, out_dir)
	gen.run() or { panic('Failed to generate V bindings: ${err}') }
	copy_runtime(out_dir)
	os.write_file(hash_path, '${sum}\n') or { panic(err) }
	println('V bindings generated.')
}
