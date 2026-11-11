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

module generator

fn test_convert_name_lowercases() {
	assert convert_name('GetNode') == 'getnode'
	assert convert_name('OK') == 'ok'
}

fn test_convert_name_strips_leading_underscore() {
	assert convert_name('_Private') == 'gd_private'
	assert convert_name('_get_name') == 'gd_get_name'
}

fn test_convert_name_escapes_keywords() {
	assert convert_name('For') == 'gd_for'
	assert convert_name('__Global') == 'gd___global'
	assert convert_name('Args') == 'gd_args'
	assert convert_name('Result') == 'gd_result'
}

fn test_convert_type_primitives() {
	assert convert_type('int', ConvertCfg{}) == 'i64'
	assert convert_type('float', ConvertCfg{}) == 'f64'
	assert convert_type('double', ConvertCfg{}) == 'f64'
	assert convert_type('real_t', ConvertCfg{}) == 'f64'
	assert convert_type('void*', ConvertCfg{}) == 'voidptr'
	assert convert_type('uint8_t', ConvertCfg{}) == 'u8'
	assert convert_type('int64_t', ConvertCfg{}) == 'i64'
	assert convert_type('const String*', ConvertCfg{}) == '&String'
}

fn test_convert_type_namespaces() {
	assert convert_type('enum::Error', ConvertCfg{}) == 'GDError'
	assert convert_type('typedarray::Array[String]', ConvertCfg{}) == 'Array'
	cfg := ConvertCfg{ ns: 'godot' }
	assert convert_type('Node', cfg) == 'godot.Node'
	assert convert_type('Vector2', cfg) == 'godot.Vector2'
}

fn test_convert_return_defaults() {
	assert convert_return('bool', 'bool', {}) == 'false'
	assert convert_return('voidptr', 'voidptr', {}) == 'unsafe{nil}'
	assert convert_return('f32', 'f32', {}) == 'f32(0)'
	assert convert_return('i64', 'i64', {}) == 'i64(0)'
	assert convert_return('String', 'String', {}) == 'String{}'
}

fn test_convert_return_enum_default() {
	defaults := {
		'GDError': 'ok'
	}
	assert convert_return('GDError', 'enum::Error', defaults) == 'i64(GDError.ok)'
}

fn test_convert_strings() {
	assert convert_strings('String') == 'string'
	assert convert_strings('StringName') == 'string'
	assert convert_strings('Node') == 'Node'
}

fn test_interface_name() {
	assert interface_name(.virtual, 'Node', 'get_child') == 'INodeGetChild'
	assert interface_name(.signal, 'Area2D', 'area_entered') == 'ISignalArea2DAreaEntered'
}

fn test_convert_dumb_value() {
	assert convert_dumb_value('Vector2', 'Vector2(1, 2)')? == 'Vector2{1, 2}'
	assert convert_dumb_value('Rect2', 'Rect2(1, 2, 3, 4)')? == 'Rect2{Vector2{1, 2}, Vector2{3, 4}}'
	empty := convert_dumb_value('String', '""')
	assert empty == none
}
