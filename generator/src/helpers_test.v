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

module generator

fn test_docstring_formats_comments() {
	assert docstring('', DocstringCfg{}) == ''
	assert docstring('hello', before: 'B', after: 'A', prefix: 'P', suffix: 'S') == 'BP// helloSA'
	assert docstring('a\nb', prefix: '\t') == '\t// a\n\t// b'
	assert docstring('[code]x[/code]\n[codeblock]\ny\n[/codeblock]', after: '\n') == '// `x`\n// ```gdscript\n// y\n// ```\n'
}

fn test_signature_names_and_strips() {
	empty_sig, empty_name := signature([]APIArg{}, SignatureCfg{})
	assert empty_sig == 'fn ()'
	assert empty_name == 'SignalFn_void'
	ret_sig, ret_name := signature([]APIArg{}, SignatureCfg{
		return: 'bool'
	})
	assert ret_sig == 'fn () bool'
	assert ret_name == 'SignalFn__bool'
	sig, name := signature([
		APIArg{
			name: 'x'
			type: 'String'
		},
	], SignatureCfg{
		return: 'bool'
	})
	assert sig == 'fn (x string) bool'
	assert name == 'SignalFn_x_string_bool'
	stripped, stripped_name := signature([
		APIArg{
			name: 'x'
			type: 'String'
		},
	], SignatureCfg{
		return:      'bool'
		strip_names: true
	})
	assert stripped == 'fn (string) bool'
	assert stripped_name == 'SignalFn_string_bool'
	pair, pair_name := signature([
		APIArg{
			name: 'a'
			type: 'int'
		},
		APIArg{
			name: 'b'
			type: 'float'
		},
	], SignatureCfg{})
	assert pair == 'fn (a i64, b f64)'
	assert pair_name == 'SignalFn_a_i64_b_f64'
}
