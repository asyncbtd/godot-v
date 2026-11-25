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

struct Counter {
mut:
	n i64
}

fn (mut self Counter) bump(step i64) i64 {
	self.n += step
	return self.n
}

fn (mut self Counter) add(left i64, right i64) i64 {
	return left + right
}

// vfmt off
@[NodeClass('Node2D')]
struct Hero {
pub mut:
	hp    int    @[Export]
	speed f64    @[ExportRange(min: 0, max: 10)]
	pose  string @[ExportEnum(values: 'idle,run')]
	died  VSignal[int]
}
// vfmt on

@[SignalOn('HUD/StartButton', 'pressed')]
fn (mut self Hero) start() {}

fn (mut self Hero) enter_tree() {
	hero_hits++
}

fn (mut self Hero) ready() {
	hero_hits += 10
}

__global hero_hits = 0

fn test_state_survives_calls_and_returns_values() {
	reset_state[Counter]()
	register[Counter]()
	bound_values = [
		CallValue{
			kind: kind_i64
			i:    4
		},
	]
	assert call_named[Counter](unsafe { nil }, 'bump')
	assert bound_result.i == 4
	bound_values = [
		CallValue{
			kind: kind_i64
			i:    3
		},
	]
	assert call_named[Counter](unsafe { nil }, 'bump')
	assert bound_result.i == 7
	bound_values = [
		CallValue{
			kind: kind_i64
			i:    2
		},
		CallValue{
			kind: kind_i64
			i:    5
		},
	]
	assert call_named[Counter](unsafe { nil }, 'add')
	assert bound_result.i == 7
	slot := godot_host.registry.get('counter') or {
		assert false
		return
	}
	assert slot.info.len == 2
	assert slot.info[0].args.len == 1
	assert slot.info[0].args[0].typ == 'i64'
	assert slot.info[0].ret == 'i64'
	assert slot.info[1].args.len == 2
}

fn test_register_stores_exports_signals_and_links() {
	register[Hero]()
	slot := godot_host.registry.get('hero') or {
		assert false
		return
	}
	assert slot.base == 'Node2D'
	assert 'enter_tree' in slot.methods
	assert '_enter_tree' in slot.methods
	assert '_ready' in slot.methods
	assert slot.props.len == 3
	assert slot.props[0].name == 'hp'
	assert slot.props[0].typ == 'int'
	assert slot.props[1].hint == 'range'
	assert slot.props[1].hint_string == '0,10'
	assert slot.props[2].hint == 'enum'
	assert slot.props[2].hint_string == 'idle,run'
	assert slot.signals.len == 1
	assert slot.signals[0].name == 'died'
	assert slot.links.len == 1
	assert slot.links[0].method == 'start'
	assert slot.links[0].node == 'HUD/StartButton'
	assert slot.links[0].signal == 'pressed'
}

fn test_properties_round_trip_and_can_revert() {
	reset_state[Hero]()
	register[Hero]()
	bound_key = 'hero'
	bound_values = [
		CallValue{
			kind: kind_int
			i:    9
		},
	]
	assert set_named[Hero]('hp')
	assert get_named[Hero]('hp')
	assert bound_result.i == 9
	assert can_revert_named[Hero]('hp')
	assert can_revert_named[Hero]('missing') == false
	bound_result = CallValue{}
	assert revert_named[Hero]('hp')
	assert bound_result.i == 0
}

fn test_notification_runs_enter_and_ready_once() {
	reset_state[Hero]()
	register[Hero]()
	hero_hits = 0
	mut node := 3
	mut box := ScriptInstance{
		node: voidptr(&node)
		id:   'hero'
	}
	box.notify(10)
	assert hero_hits == 1
	box.call_name('_enter_tree', unsafe { nil }, 0, unsafe { nil }, unsafe { nil })
	assert hero_hits == 1
	box.notify(13)
	assert hero_hits == 11
	box.call_name('_ready', unsafe { nil }, 0, unsafe { nil }, unsafe { nil })
	assert hero_hits == 11
	assert notification_name(16) == 'physics_process'
	assert notification_name(1) == 'predelete'
	assert notification_name(99) == ''
}

fn test_outline_parser_and_validate() {
	source := "@[godot.NodeClass('Area2D')]\npub struct Player {\npub mut:\n\t@[export]\nhp int\n\t@[signal]\ndied VSignal[int]\n}\n\n@[godot.SignalOn('HUD/StartButton', 'pressed')]\nfn (mut self Player) ready() {}\n\nfn (mut self Player) hop(step i64) {}\n"
	outline := parse_outline(source)
	assert outline.base == 'Area2D'
	assert outline.methods.len == 2
	assert outline.methods[0].name == 'ready'
	assert outline.methods[1].name == 'hop'
	assert outline.methods[1].args.len == 1
	assert outline.methods[1].args[0].typ == 'i64'
	assert outline.props.len == 1
	assert outline.props[0].name == 'hp'
	same_line := parse_outline('pub struct Player {\npub mut:\n\tspeed f32 = 400 @[godot.Export]\n}\n')
	assert same_line.props.len == 1
	assert same_line.props[0].name == 'speed'
	assert same_line.props[0].typ == 'f32'
	assert same_line.props[0].fallback == '400'
	assert outline.signals.len == 1
	assert outline.signals[0].name == 'died'
	assert outline.signals[0].args[0].typ == 'int'
	assert outline.links.len == 1
	assert outline.links[0].signal == 'pressed'
	assert find_function_line('hop', source) > 0
	assert find_function_line('_ready', source) == outline.methods[0].line
	assert find_member_line('hp', source) == outline.props[0].line
	assert find_function_line('missing', source) == -1
	bad := validate_source('fn (')
	assert bad.errors.len > 0
	assert bad.errors[0].line > 0
	ok := validate_source('fn fine() {}\n')
	assert ok.errors.len == 0
	assert ok.functions.len == 1
	assert ok.functions[0].name == 'fine'
}
