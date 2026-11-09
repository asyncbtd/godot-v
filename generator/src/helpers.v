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

// TODO: make `TODO` et al look nice

// TODO: make V support `///` for docstrings
// TODO: fix V stripping `#.*` from comments
// TODO: fix V not working with the first item in a list

@[params]
struct DocstringCfg {
	// Add text before valid docstrings.
	before string
	// Add text after valid docstrings.
	after string
	// Add text before each line.
	prefix string
	// Add text after each line.
	suffix string
}

// Creates a doc comment string from the given comments.
// Converts some bbcode to markdown.
fn docstring(comments string, cfg DocstringCfg) string {
	if comments == '' {
		return ''
	}
	mut lines := []string{}
	for comment in comments.split_into_lines() {
		line := comment
			.replace('[codeblock]', '```gdscript')
			.replace('[/codeblock]', '```')
			.replace('[code]', '`')
			.replace('[/code]', '`')
		lines << '${cfg.prefix}// ${line}${cfg.suffix}'
	}
	return cfg.before + lines.join('\n') + cfg.after
}

@[params]
struct SignatureCfg {
	return      string
	strip_names bool
}

// Determines the function signature string from the given arguments.
// Also returns a name generated from the signature.
fn signature(args []APIArg, cfg SignatureCfg) (string, string) {
	ret_sig := ' ${cfg.return}'.trim_space_right()
	args_sig := args.map(fn [cfg] (arg APIArg) string {
		type := convert_strings(convert_type(arg.type))
		if cfg.strip_names {
			return type
		}
		return '${arg.name} ${type}'
	}).join(', ')

	sig := 'fn (${args_sig})${ret_sig}'
	name := sig
		.replace('fn ', 'SignalFn void ')
		.replace('(', '')
		.replace(')', '')
		.replace(',', '')
		.replace(':', '')
		.trim_space_right()
		.replace(' ', '_')
		.replace('_void_', '_')
	return sig, name
}
