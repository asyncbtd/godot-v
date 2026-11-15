#!/usr/bin/env -S v run

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

module main

import os
import generator { GeneratorInterface }

fn main() {
	launched := os.getwd()
	dump_path := os.abs_path(if os.args.len > 1 {
		os.args[1]
	} else {
		os.join_path(launched, 'gdextension_interface.json')
	})
	module_root := os.real_path(os.join_path(@VMODROOT, '..'))
	os.chdir(module_root) or { panic(err) }
	out_dir := os.join_path(module_root, 'extension')
	body := os.read_file(dump_path) or { panic('Failed to read ${dump_path}: ${err}') }
	println('Generating GDExtension interface into ${out_dir}...')
	mut gen := GeneratorInterface.new(body, out_dir) or {
		panic('Failed to parse ${dump_path}: ${err}')
	}
	gen.run() or { panic('Failed to generate GDExtension interface: ${err}') }
	out := os.join_path(out_dir, 'interface.v')
	res := os.exec([@VEXE, 'fmt', '-w', out])
	if res.exit_code != 0 {
		panic('Failed to format interface.v: ${res.output}')
	}
	println('Wrote ${out}')
}
