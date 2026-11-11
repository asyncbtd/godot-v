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

import os
import generator { Generator, InterfaceGen }

fn json_field(body string, key string) string {
	needle := '"${key}": "'
	start := body.index(needle) or { return '' }
	rest := body[start + needle.len..]
	end := rest.index('"') or { return '' }
	return rest[..end]
}

fn main() {
	launched := os.getwd()
	dump_path := os.abs_path(if os.args.len > 1 {
		os.args[1]
	} else {
		os.join_path(launched, 'extension_api.json')
	})
	module_root := os.real_path(os.join_path(@VMODROOT, '..'))
	interface_path := os.abs_path(if os.args.len > 2 {
		os.args[2]
	} else {
		os.join_path(module_root, 'gdextension_interface.json')
	})
	os.chdir(module_root) or { panic(err) }
	out_dir := os.join_path(module_root, 'extension')
	body := os.read_file(dump_path) or { panic(err) }
	interface_body := os.read_file(interface_path) or { panic(err) }
	label := json_field(body, 'version_full_name')
	precision := json_field(body, 'precision')
	println('API ${label} precision ${precision}')
	println('Generating V bindings into ${out_dir}...')
	for name in os.ls(out_dir) or { panic(err) } {
		if name.starts_with('_') && name.ends_with('.v') {
			os.rm(os.join_path(out_dir, name)) or { panic(err) }
		}
	}
	mut interface_gen := InterfaceGen.new(interface_body, out_dir) or {
		panic('Failed to read ${interface_path}: ${err}')
	}
	interface_gen.run() or { panic('Failed to generate GDExtension interface: ${err}') }
	for name in ['interface.v', 'runtime.v'] {
		res := os.exec([@VEXE, 'fmt', '-w', os.join_path(out_dir, name)])
		if res.exit_code != 0 {
			panic('Failed to format ${name}: ${res.output}')
		}
	}
	mut gen := Generator.new(body, out_dir)
	gen.run() or { panic('Failed to generate V bindings: ${err}') }
	println('V bindings generated.')
}
