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

import strings

fn operator_code(class_name string, operators []APIOperator) string {
	mut buf := strings.new_builder(256)
	gen_operators(mut buf, class_name, operators)
	return buf.str()
}

fn test_operators_skip_unknown_and_variant_right() {
	out := operator_code('Vector2', [
		APIOperator{
			name:        '~'
			right_type:  'Vector2'
			return_type: 'Vector2'
		},
		APIOperator{
			name:        '+'
			right_type:  'Variant'
			return_type: 'Vector2'
		},
	])
	assert out.trim_space() == ''
}

fn test_operators_cover_same_type_and_other_types() {
	out := operator_code('Vector2', [
		APIOperator{
			name:        '+'
			right_type:  'Vector2'
			return_type: 'Vector2'
			description: '[code]dot[/code]'
		},
		APIOperator{
			name:        '<'
			right_type:  'f64'
			return_type: 'bool'
		},
		APIOperator{
			name:        '!='
			right_type:  'Vector2'
			return_type: 'bool'
		},
		APIOperator{
			name:        '*'
			right_type:  'i64'
			return_type: 'Vector2'
		},
		APIOperator{
			name:        '/'
			right_type:  'String'
			return_type: 'voidptr'
		},
		APIOperator{
			name:        '-'
			right_type:  'int'
			return_type: 'f32'
		},
	])
	assert out.contains('// `dot`\n')
	assert out.contains('pub fn (a Vector2) + (b Vector2) Vector2 {')
	assert out.contains('GDExtensionVariantOperator.op_add, GDExtensionVariantType.type_vector2, GDExtensionVariantType.type_vector2)')
	assert out.contains('res := Vector2{}')
	assert out.contains('pub fn (a Vector2) add_vector2(b Vector2) Vector2 {')
	assert out.contains('pub fn (a Vector2) lt_f64(b f64) bool {')
	assert out.contains('res := false')
	assert out.contains('GDExtensionVariantType.type_float)')
	assert !out.contains('pub fn (a Vector2) != ')
	assert out.contains('pub fn (a Vector2) ne_vector2(b Vector2) bool {')
	assert out.contains('pub fn (a Vector2) mul_i64(b i64) Vector2 {')
	assert out.contains('GDExtensionVariantType.type_int)')
	assert out.contains('pub fn (a Vector2) div_string(b String) voidptr {')
	assert out.contains('res := unsafe{nil}')
	assert out.contains('pub fn (a Vector2) sub_i64(b i64) f32 {')
	assert out.contains('res := f32(0)')
}
