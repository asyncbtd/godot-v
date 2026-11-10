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

#include "@VMODROOT/src/bridge_string_read.h"

fn C.godot_call_string_read(f voidptr, src voidptr, buf voidptr, n i64) i64

const level_scene = u32(2)
const level_editor = u32(3)

const type_bool = 1
const type_int = 2
const type_float = 3
const type_string = 4
const type_vector2 = 5
const type_rect2 = 7
const type_string_name = 21
const type_node_path = 22
const type_object = 24
const type_callable = 25
const type_dictionary = 27
const type_array = 28
const type_packed_string_array = 34

const kind_language = 0
const kind_script = 1
const kind_loader = 2
const kind_saver = 3

const ret_none = 0
const ret_bool = 1
const ret_number = 2
const ret_pointer = 3
const ret_string = 4
const ret_string_name = 5
const ret_dictionary = 6
const ret_array = 7
const ret_packed_string = 8
const ret_variant = 9

const action_stub = 0
const action_lang_name = 1
const action_lang_type = 2
const action_lang_extension = 3
const action_lang_extensions = 4
const action_lang_comments = 5
const action_lang_strings = 6
const action_lang_template = 7
const action_lang_create = 8
const action_lang_templates = 9
const action_lang_validate = 10
const action_script_can_instantiate = 11
const action_script_base = 12
const action_script_placeholder = 13
const action_script_has_source = 14
const action_script_get_source = 15
const action_script_set_source = 16
const action_script_reload = 17
const action_script_valid = 18
const action_script_language = 19
const action_script_reload_file = 20
const action_loader_extensions = 21
const action_loader_handles = 22
const action_loader_type = 23
const action_loader_recognize = 24
const action_loader_load = 25
const action_saver_recognize = 26
const action_saver_extensions = 27
const action_saver_path = 28
const action_saver_save = 29
const action_script_instance = 30
const action_script_has_method = 31
const action_scripts_refresh = 32

struct Initialization {
mut:
	minimum_level u32
	pad           u32
	userdata      voidptr
	initialize    voidptr
	deinitialize  voidptr
}

struct ClassInfo {
	is_virtual                  u8
	is_abstract                 u8
	is_exposed                  u8
	is_runtime                  u8
	pad                         u32
	icon_path                   voidptr
	set_func                    voidptr
	get_func                    voidptr
	get_property_list_func      voidptr
	free_property_list_func     voidptr
	property_can_revert_func    voidptr
	property_get_revert_func    voidptr
	validate_property_func      voidptr
	notification_func           voidptr
	to_string_func              voidptr
	reference_func              voidptr
	unreference_func            voidptr
	create_instance_func        voidptr
	free_instance_func          voidptr
	recreate_instance_func      voidptr
	get_virtual_func            voidptr
	get_virtual_call_data_func  voidptr
	call_virtual_with_data_func voidptr
	class_userdata              voidptr
}

struct BindingCallbacks {
	create_callback    voidptr
	free_callback      voidptr
	reference_callback voidptr
}

struct GdString {
mut:
	data voidptr
}

struct ScriptState {
mut:
	kind   int
	object voidptr
	source GdString
	base   GdString
	path   GdString
	owned  u8
}

struct PlainObject {
mut:
	kind   int
	object voidptr
}

struct NameNode {
mut:
	data voidptr
	next voidptr
}

struct Method {
mut:
	action int
	ret    int
}

struct Spec {
	kind   int
	name   string
	action int
	ret    int
}

struct Api {
mut:
	get_proc            voidptr
	library             voidptr
	string_new          voidptr
	string_read         voidptr
	string_name_new     voidptr
	string_dtor         voidptr
	string_copy         voidptr
	mem_alloc           voidptr
	mem_free            voidptr
	construct           voidptr
	get_method          voidptr
	ptrcall             voidptr
	register_class      voidptr
	singleton           voidptr
	set_instance        voidptr
	set_binding         voidptr
	get_binding         voidptr
	get_class_name      voidptr
	print_error         voidptr
	destroy_object      voidptr
	placeholder         voidptr
	constructor         voidptr
	destructor          voidptr
	builtin_method      voidptr
	from_type           voidptr
	keyed_setter        voidptr
	variant_destroy     voidptr
	new_dictionary      voidptr
	new_array           voidptr
	new_packed          voidptr
	packed_push         voidptr
	dict_set            voidptr
	variant_from_bool   voidptr
	variant_from_int    voidptr
	variant_from_string voidptr
	variant_from_object voidptr
	notification        voidptr
	register_language   voidptr
	unregister_language voidptr
	get_class           voidptr
	set_path            voidptr
	file_read           voidptr
	file_open           voidptr
	file_store          voidptr
	file_close          voidptr
	unref               voidptr
	add_loader          voidptr
	remove_loader       voidptr
	add_saver           voidptr
	remove_saver        voidptr
	engine              voidptr
	resource_loader     voidptr
	resource_saver      voidptr
	language            voidptr
	loader              voidptr
	saver               voidptr
	script_instance     voidptr
	call_script         voidptr
	variant_call        voidptr
	to_type             voidptr
	editor_hint         voidptr
	string_from_name    voidptr
	script_name         GdString
	vscript_name        GdString
	names               voidptr
}

__global (
	api     Api
	binding BindingCallbacks
)

struct MethodSlot {
	key    u64
	method &Method
}

__global language_methods = []MethodSlot{}
__global script_methods = []MethodSlot{}
__global loader_methods = []MethodSlot{}
__global saver_methods = []MethodSlot{}

type GetProc = fn (&u8) voidptr

type StringNew = fn (voidptr, &u8, i64) i64

type StringRead = fn (voidptr, &u8, i64) i64

type StringNameNew = fn (voidptr, &u8, u8)

type MemAlloc = fn (uint) voidptr

type MemFree = fn (voidptr)

type Construct = fn (voidptr) voidptr

type GetMethod = fn (voidptr, voidptr, i64) voidptr

type Ptrcall = fn (voidptr, voidptr, voidptr, voidptr)

type RegisterClass = fn (voidptr, voidptr, voidptr, voidptr)

type Singleton = fn (voidptr) voidptr

type SetInstance = fn (voidptr, voidptr, voidptr)

type SetBinding = fn (voidptr, voidptr, voidptr, voidptr)

type GetBinding = fn (voidptr, voidptr, voidptr) voidptr

type PrintError = fn (&u8, &u8, &u8, int, u8)

type Placeholder = fn (voidptr, voidptr, voidptr) voidptr

type Constructor = fn (int, int) voidptr

type Destructor = fn (int) voidptr

type BuiltinMethod = fn (int, voidptr, i64) voidptr

type FromType = fn (int) voidptr

type KeyedSetter = fn (int) voidptr

type VariantDestroy = fn (voidptr)

type TypeCtor = fn (voidptr, voidptr)

type BuiltinCall = fn (voidptr, voidptr, voidptr, int)

type KeyedSet = fn (voidptr, voidptr, voidptr)

fn proc(name string) voidptr {
	get_proc := unsafe { GetProc(api.get_proc) }
	return get_proc(name.str)
}

fn load_api() {
	prepare_binding()
	api.string_new = proc('string_new_with_utf8_chars_and_len2')
	api.string_read = proc('string_to_utf8_chars')
	api.string_name_new = proc('string_name_new_with_latin1_chars')
	api.mem_alloc = proc('mem_alloc')
	api.mem_free = proc('mem_free')
	api.construct = proc('classdb_construct_object2')
	api.get_method = proc('classdb_get_method_bind')
	api.ptrcall = proc('object_method_bind_ptrcall')
	api.register_class = proc('classdb_register_extension_class5')
	api.singleton = proc('global_get_singleton')
	api.set_instance = proc('object_set_instance')
	api.set_binding = proc('object_set_instance_binding')
	api.get_binding = proc('object_get_instance_binding')
	api.get_class_name = proc('object_get_class_name')
	api.print_error = proc('print_error')
	api.destroy_object = proc('object_destroy')
	api.placeholder = proc('placeholder_script_instance_create')
	api.constructor = proc('variant_get_ptr_constructor')
	api.destructor = proc('variant_get_ptr_destructor')
	api.builtin_method = proc('variant_get_ptr_builtin_method')
	api.from_type = proc('get_variant_from_type_constructor')
	api.keyed_setter = proc('variant_get_ptr_keyed_setter')
	api.variant_destroy = proc('variant_destroy')
	api.string_dtor = destructor_of(type_string)
	api.string_copy = constructor_of(type_string, 1)
	api.new_dictionary = constructor_of(type_dictionary, 0)
	api.new_array = constructor_of(type_array, 0)
	api.new_packed = constructor_of(type_packed_string_array, 0)
	api.dict_set = keyed_setter_of(type_dictionary)
	api.variant_from_bool = from_type_of(type_bool)
	api.variant_from_int = from_type_of(type_int)
	api.variant_from_string = from_type_of(type_string)
	api.variant_from_object = from_type_of(type_object)
	push_name := string_name('push_back')
	api.packed_push = builtin_method_of(type_packed_string_array, &push_name, 816187996)
	destroy_string_name(&push_name)
	api.notification = method_bind('Object', 'notification', 4023243586)
	api.register_language = method_bind('Engine', 'register_script_language', 1850254898)
	api.unregister_language = method_bind('Engine', 'unregister_script_language', 1850254898)
	api.get_class = method_bind('Object', 'get_class', 201670096)
	api.set_path = method_bind('Resource', 'set_path', 83702148)
	api.file_read = method_bind('FileAccess', 'get_file_as_string', 1703090593)
	api.file_open = method_bind('FileAccess', 'open', 1247358404)
	api.file_store = method_bind('FileAccess', 'store_string', 2323990056)
	api.file_close = method_bind('FileAccess', 'close', 3218959716)
	api.unref = method_bind('RefCounted', 'unreference', 2240911060)
	api.add_loader = method_bind('ResourceLoader', 'add_resource_format_loader', 2896595483)
	api.remove_loader = method_bind('ResourceLoader', 'remove_resource_format_loader', 405397102)
	api.add_saver = method_bind('ResourceSaver', 'add_resource_format_saver', 362894272)
	api.remove_saver = method_bind('ResourceSaver', 'remove_resource_format_saver', 3373026878)
	api.script_instance = proc('script_instance_create3')
	api.call_script = proc('object_call_script_method')
	api.variant_call = proc('variant_call')
	api.to_type = proc('get_variant_to_type_constructor')
	api.string_from_name = constructor_of(type_string, 2)
	api.script_name = string_name('Script')
	api.vscript_name = string_name('VScript')
	prepare_instance_info()
	if sizeof(Initialization) != 32 || sizeof(ClassInfo) != 160 || sizeof(InstanceInfo) != 208 {
		report('GDExtension struct size mismatch')
	}
}

fn constructor_of(typ int, index int) voidptr {
	f := unsafe { Constructor(api.constructor) }
	return f(typ, index)
}

fn destructor_of(typ int) voidptr {
	f := unsafe { Destructor(api.destructor) }
	return f(typ)
}

fn from_type_of(typ int) voidptr {
	f := unsafe { FromType(api.from_type) }
	return f(typ)
}

fn to_type_of(typ int) voidptr {
	f := unsafe { FromType(api.to_type) }
	return f(typ)
}

fn keyed_setter_of(typ int) voidptr {
	f := unsafe { KeyedSetter(api.keyed_setter) }
	return f(typ)
}

fn builtin_method_of(typ int, name voidptr, hash i64) voidptr {
	f := unsafe { BuiltinMethod(api.builtin_method) }
	return f(typ, name, hash)
}

fn string_name(text string) GdString {
	mut name := GdString{}
	f := unsafe { StringNameNew(api.string_name_new) }
	f(voidptr(&name), text.str, 1)
	return name
}

fn destroy_string_name(name &GdString) {
	if name.data == unsafe { nil } {
		return
	}
}

fn method_bind(class_name string, method string, hash i64) voidptr {
	return resolve_method(class_name, method, hash, true)
}

fn resolve_method(class_name string, method string, hash i64, report_missing bool) voidptr {
	class := string_name(class_name)
	name := string_name(method)
	f := unsafe { GetMethod(api.get_method) }
	bind := f(voidptr(&class), voidptr(&name), hash)
	destroy_string_name(&class)
	destroy_string_name(&name)
	if bind == unsafe { nil } && report_missing {
		report('missing method ${class_name}.${method}')
	}
	return bind
}

fn singleton(name string) voidptr {
	sn := string_name(name)
	f := unsafe { Singleton(api.singleton) }
	object := f(voidptr(&sn))
	destroy_string_name(&sn)
	return object
}

// report writes a message to Godot's error output.
pub fn report(message string) {
	report_impl(message)
}

fn report_impl(message string) {
	if api.print_error == unsafe { nil } {
		return
	}
	f := unsafe { PrintError(api.print_error) }
	f(message.str, c'godot_v', c'src/bridge_entry.v', 0, 1)
}

fn (mut s GdString) set_text(text string) {
	s.clear()
	if text == '' {
		return
	}
	f := unsafe { StringNew(api.string_new) }
	f(voidptr(&s), text.str, i64(text.len))
}

fn (s &GdString) text() string {
	if s.data == unsafe { nil } {
		return ''
	}
	return read_gd_string(voidptr(s))
}

fn (mut s GdString) clear() {
	if s.data == unsafe { nil } {
		return
	}
	call := unsafe { TypeCtor(api.string_dtor) }
	call(voidptr(&s), unsafe { nil })
	s.data = unsafe { nil }
}

fn (s &GdString) copy_to(dest voidptr) {
	if s.data == unsafe { nil } {
		zero(dest, 8)
		return
	}
	src := voidptr(s)
	call := unsafe { TypeCtor(api.string_copy) }
	call(dest, voidptr(&src))
}

fn read_name(name voidptr) string {
	if name == unsafe { nil } || api.string_from_name == unsafe { nil } {
		return ''
	}
	mut text := GdString{}
	ctor := unsafe { TypeCtor(api.string_from_name) }
	ctor(voidptr(&text), voidptr(&name))
	value := text.text()
	text.clear()
	return value
}

fn read_gd_string(src voidptr) string {
	len := int(C.godot_call_string_read(api.string_read, src, unsafe { nil }, 0))
	if len <= 0 {
		return ''
	}
	mut out := string{
		str: unsafe { malloc(int(len + 1)) }
		len: len
	}
	C.godot_call_string_read(api.string_read, src, out.str, i64(len))
	unsafe {
		out.str[len] = 0
	}
	return out
}

fn write_string(dest voidptr, text string) {
	if text == '' {
		zero(dest, 8)
		return
	}
	f := unsafe { StringNew(api.string_new) }
	f(dest, text.str, i64(text.len))
}

fn write_string_name(dest voidptr, text string) {
	if text == '' {
		zero(dest, 8)
		return
	}
	f := unsafe { StringNameNew(api.string_name_new) }
	f(dest, text.str, 1)
}

fn write_bool(dest voidptr, value bool) {
	unsafe {
		*(&u8(dest)) = if value { 1 } else { 0 }
	}
}

fn write_number(dest voidptr, value i64) {
	unsafe {
		*(&i64(dest)) = value
	}
}

fn write_pointer(dest voidptr, value voidptr) {
	unsafe {
		*(&voidptr(dest)) = value
	}
}

fn construct_empty(ctor voidptr, dest voidptr) {
	call := unsafe { TypeCtor(ctor) }
	call(dest, unsafe { nil })
}

fn write_dictionary(dest voidptr) {
	construct_empty(api.new_dictionary, dest)
}

fn write_array(dest voidptr) {
	construct_empty(api.new_array, dest)
}

fn write_packed(dest voidptr, values []string) {
	construct_empty(api.new_packed, dest)
	push := unsafe { BuiltinCall(api.packed_push) }
	for value in values {
		mut item := GdString{}
		item.set_text(value)
		item_ptr := voidptr(&item)
		mut added := u8(0)
		push(dest, voidptr(&item_ptr), voidptr(&added), 1)
		item.clear()
	}
}

fn dictionary_bool(dest voidptr, key string, value bool) {
	write_dictionary(dest)
	mut key_string := GdString{}
	key_string.set_text(key)
	mut key_variant := [24]u8{}
	mut value_variant := [24]u8{}
	from_string := unsafe { TypeCtor(api.variant_from_string) }
	from_bool := unsafe { TypeCtor(api.variant_from_bool) }
	flag := u8(if value { 1 } else { 0 })
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_bool(voidptr(&value_variant[0]), voidptr(&flag))
		set := KeyedSet(api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
		destroy(voidptr(&value_variant[0]))
	}
	key_string.clear()
}

fn variant_object(dest voidptr, object voidptr) {
	from_object := unsafe { TypeCtor(api.variant_from_object) }
	from_object(dest, voidptr(&object))
}

fn variant_number(dest voidptr, value i64) {
	from_int := unsafe { TypeCtor(api.variant_from_int) }
	from_int(dest, voidptr(&value))
}

fn zero(ptr voidptr, size int) {
	mut bytes := unsafe { &u8(ptr) }
	for i in 0 .. size {
		unsafe {
			bytes[i] = 0
		}
	}
}

fn alloc(size uint) voidptr {
	f := unsafe { MemAlloc(api.mem_alloc) }
	ptr := f(size)
	zero(ptr, int(size))
	return ptr
}

fn release(ptr voidptr) {
	f := unsafe { MemFree(api.mem_free) }
	f(ptr)
}

fn call_none(bind voidptr, instance voidptr, ret voidptr) {
	f := unsafe { Ptrcall(api.ptrcall) }
	f(bind, instance, unsafe { nil }, ret)
}

fn call_ptr(bind voidptr, instance voidptr, arg voidptr, ret voidptr) {
	f := unsafe { Ptrcall(api.ptrcall) }
	slot := arg
	f(bind, instance, voidptr(&slot), ret)
}

fn call_ptr2(bind voidptr, instance voidptr, first voidptr, second voidptr, ret voidptr) {
	unsafe {
		mut args := [2]voidptr{}
		args[0] = first
		args[1] = second
		f := Ptrcall(api.ptrcall)
		f(bind, instance, voidptr(&args[0]), ret)
	}
}

fn call_list(bind voidptr, instance voidptr, args []voidptr, ret voidptr) {
	mut argv := unsafe { nil }
	if args.len > 0 {
		argv = unsafe { voidptr(&args[0]) }
	}
	f := unsafe { Ptrcall(api.ptrcall) }
	f(bind, instance, argv, ret)
}

fn postinitialize(object voidptr) {
	what := i64(0)
	reversed := u8(0)
	call_ptr2(api.notification, object, voidptr(&what), voidptr(&reversed), unsafe { nil })
}

fn object_class(object voidptr) string {
	mut name := GdString{}
	call_none(api.get_class, object, voidptr(&name))
	text := name.text()
	name.clear()
	return text
}

fn prepare_binding() {
	binding.create_callback = voidptr(binding_create)
	binding.free_callback = voidptr(binding_free)
	binding.reference_callback = voidptr(binding_reference)
}

fn binding_create(_token voidptr, object voidptr) voidptr {
	mut state := unsafe { &ScriptState(alloc(uint(sizeof(ScriptState)))) }
	state.kind = kind_script
	state.object = object
	state.owned = 1
	return voidptr(state)
}

fn binding_free(_token voidptr, _object voidptr, instance voidptr) {
	if instance == unsafe { nil } {
		return
	}
	mut state := unsafe { &ScriptState(instance) }
	if state.kind != kind_script || state.owned == 0 {
		return
	}
	state.source.clear()
	state.base.clear()
	state.path.clear()
	release(instance)
}

fn binding_reference(_token voidptr, _binding voidptr, _reference u8) u8 {
	return 1
}

fn binding_of(object voidptr) voidptr {
	if object == unsafe { nil } || api.get_binding == unsafe { nil } {
		return unsafe { nil }
	}
	f := unsafe { GetBinding(api.get_binding) }
	return f(object, api.library, voidptr(&binding))
}

fn arg(args voidptr, index int) voidptr {
	return unsafe { (&voidptr(args))[index] }
}

fn arg_string(args voidptr, index int) string {
	return read_gd_string(arg(args, index))
}

fn arg_object(args voidptr, index int) voidptr {
	ptr := arg(args, index)
	return unsafe { *&voidptr(ptr) }
}

fn arg_bool(args voidptr, index int) bool {
	ptr := arg(args, index)
	return unsafe { *&u8(ptr) } != 0
}

fn editor_open() bool {
	if api.editor_hint == unsafe { nil } || api.engine == unsafe { nil } {
		return false
	}
	mut hint := u8(0)
	call_none(api.editor_hint, api.engine, voidptr(&hint))
	return hint != 0
}

fn call_string(instance voidptr, class_name string, method string, hash i64, arg string) string {
	bind := method_bind(class_name, method, hash)
	mut result := GdString{}
	if arg == '' {
		call_none(bind, instance, voidptr(&result))
	} else {
		mut input := GdString{}
		input.set_text(arg)
		call_ptr(bind, instance, voidptr(&input), voidptr(&result))
		input.clear()
	}
	text := result.text()
	result.clear()
	return text
}

@[export: 'godot_v_init']
fn godot_v_init(get_proc_address voidptr, library voidptr, initialization voidptr) u8 {
	C._vinit(0, unsafe { nil })
	api.get_proc = get_proc_address
	api.library = library
	load_api()
	mut startup := unsafe { &Initialization(initialization) }
	startup.minimum_level = level_scene
	startup.userdata = unsafe { nil }
	startup.initialize = voidptr(initialize_level)
	startup.deinitialize = voidptr(deinitialize_level)
	return 1
}

fn initialize_level(_userdata voidptr, level u32) {
	if level != level_scene {
		return
	}
	api.editor_hint = method_bind('Engine', 'is_editor_hint', 36873697)
	api.engine = singleton('Engine')
	api.resource_loader = singleton('ResourceLoader')
	api.resource_saver = singleton('ResourceSaver')
	register_classes()
	api.language = construct_class(kind_language)
	api.loader = construct_class(kind_loader)
	api.saver = construct_class(kind_saver)
	mut err := i64(-1)
	call_ptr(api.register_language, api.engine, voidptr(&api.language), voidptr(&err))
	if err != 0 {
		report('register_script_language returned ${err}')
	}
	at_front := u8(1)
	call_ptr2(api.add_loader, api.resource_loader, voidptr(&api.loader), voidptr(&at_front),
		unsafe { nil })
	call_ptr2(api.add_saver, api.resource_saver, voidptr(&api.saver), voidptr(&at_front),
		unsafe { nil })
	if editor_open() == false {
		load_project_scripts()
	}
}

fn deinitialize_level(_userdata voidptr, level u32) {
	if level != level_scene {
		return
	}
	mut err := i64(0)
	if api.language != unsafe { nil } {
		language := api.language
		call_ptr(api.unregister_language, api.engine, voidptr(&api.language), voidptr(&err))
		api.language = unsafe { nil }
		destroy_object(language)
	}
	if api.loader != unsafe { nil } {
		call_ptr(api.remove_loader, api.resource_loader, voidptr(&api.loader), voidptr(&err))
		api.loader = unsafe { nil }
	}
	if api.saver != unsafe { nil } {
		call_ptr(api.remove_saver, api.resource_saver, voidptr(&api.saver), voidptr(&err))
		api.saver = unsafe { nil }
	}
	release_kept_names()
}

fn destroy_object(object voidptr) {
	if object == unsafe { nil } || api.destroy_object == unsafe { nil } {
		return
	}
	f := unsafe { MemFree(api.destroy_object) }
	f(object)
}

fn keep_name(data voidptr) {
	mut node := unsafe { &NameNode(alloc(uint(sizeof(NameNode)))) }
	node.data = data
	node.next = api.names
	api.names = voidptr(node)
}

fn release_kept_names() {
	destroy_string_name(&api.script_name)
	api.script_name = GdString{}
	destroy_string_name(&api.vscript_name)
	api.vscript_name = GdString{}
	for api.names != unsafe { nil } {
		node := unsafe { &NameNode(api.names) }
		mut name := GdString{
			data: node.data
		}
		api.names = node.next
		destroy_string_name(&name)
		release(voidptr(node))
	}
}

fn register_classes() {
	language_methods = []MethodSlot{}
	script_methods = []MethodSlot{}
	loader_methods = []MethodSlot{}
	saver_methods = []MethodSlot{}
	for spec in method_specs() {
		register_method(spec)
	}
	register_class('VLanguage', 'ScriptLanguageExtension', kind_language)
	register_class('VScript', 'ScriptExtension', kind_script)
	register_class('VScriptLoader', 'ResourceFormatLoader', kind_loader)
	register_class('VScriptSaver', 'ResourceFormatSaver', kind_saver)
}

fn register_method(spec Spec) {
	name := string_name(spec.name)
	keep_name(name.data)
	key := u64(uint(name.data))
	mut method := unsafe { &Method(alloc(uint(sizeof(Method)))) }
	method.action = spec.action
	method.ret = spec.ret
	slot := MethodSlot{
		key:    key
		method: method
	}
	match spec.kind {
		kind_language { language_methods << slot }
		kind_script { script_methods << slot }
		kind_loader { loader_methods << slot }
		kind_saver { saver_methods << slot }
		else {}
	}
}

fn find_method(list []MethodSlot, key u64) voidptr {
	for slot in list {
		if slot.key == key {
			return voidptr(slot.method)
		}
	}
	return unsafe { nil }
}

fn register_class(class_name string, parent string, kind int) {
	name := string_name(class_name)
	parent_name := string_name(parent)
	info := ClassInfo{
		is_exposed:                  1
		create_instance_func:        voidptr(create_instance)
		free_instance_func:          voidptr(free_instance)
		get_virtual_call_data_func:  voidptr(virtual_data)
		call_virtual_with_data_func: voidptr(call_virtual)
		class_userdata:              kind_pointer(kind)
	}
	f := unsafe { RegisterClass(api.register_class) }
	f(api.library, voidptr(&name), voidptr(&parent_name), voidptr(&info))
	destroy_string_name(&name)
	destroy_string_name(&parent_name)
}

fn kind_pointer(kind int) voidptr {
	return voidptr(uint(u32(kind + 1)))
}

fn pointer_kind(ptr voidptr) int {
	return int(uint(ptr)) - 1
}

fn construct_class(kind int) voidptr {
	class_name := match kind {
		kind_language { 'VLanguage' }
		kind_script { 'VScript' }
		kind_loader { 'VScriptLoader' }
		kind_saver { 'VScriptSaver' }
		else { '' }
	}
	name := string_name(class_name)
	construct := unsafe { Construct(api.construct) }
	object := construct(voidptr(&name))
	destroy_string_name(&name)
	if object != unsafe { nil } {
		postinitialize(object)
	}
	return object
}

fn create_instance(class_userdata voidptr, notify u8) voidptr {
	kind := pointer_kind(class_userdata)
	parent := match kind {
		kind_language { 'ScriptLanguageExtension' }
		kind_script { 'ScriptExtension' }
		kind_loader { 'ResourceFormatLoader' }
		kind_saver { 'ResourceFormatSaver' }
		else { '' }
	}
	class_name := match kind {
		kind_language { 'VLanguage' }
		kind_script { 'VScript' }
		kind_loader { 'VScriptLoader' }
		kind_saver { 'VScriptSaver' }
		else { '' }
	}
	parent_name := string_name(parent)
	construct := unsafe { Construct(api.construct) }
	object := construct(voidptr(&parent_name))
	destroy_string_name(&parent_name)
	instance := new_instance(kind, object)
	name := string_name(class_name)
	set_instance := unsafe { SetInstance(api.set_instance) }
	set_instance(object, voidptr(&name), instance)
	set_binding := unsafe { SetBinding(api.set_binding) }
	set_binding(object, api.library, instance, voidptr(&binding))
	destroy_string_name(&name)
	if notify != 0 {
		postinitialize(object)
	}
	return object
}

fn new_instance(kind int, object voidptr) voidptr {
	if kind == kind_script {
		mut state := unsafe { &ScriptState(alloc(uint(sizeof(ScriptState)))) }
		state.kind = kind
		state.object = object
		return voidptr(state)
	}
	mut plain := unsafe { &PlainObject(alloc(uint(sizeof(PlainObject)))) }
	plain.kind = kind
	plain.object = object
	return voidptr(plain)
}

fn free_instance(class_userdata voidptr, instance voidptr) {
	if instance == unsafe { nil } {
		return
	}
	kind := pointer_kind(class_userdata)
	if kind == kind_script {
		if script_is_remembered(instance) {
			return
		}
		mut state := unsafe { &ScriptState(instance) }
		state.source.clear()
		state.base.clear()
		state.path.clear()
	}
	release(instance)
}

fn script_is_remembered(state voidptr) bool {
	for item in script_resources {
		if item == state {
			return true
		}
	}
	return false
}

fn virtual_data(class_userdata voidptr, name voidptr, _hash u32) voidptr {
	key := u64(uint(unsafe { *&voidptr(name) }))
	kind := pointer_kind(class_userdata)
	return match kind {
		kind_language { find_method(language_methods, key) }
		kind_script { find_method(script_methods, key) }
		kind_loader { find_method(loader_methods, key) }
		kind_saver { find_method(saver_methods, key) }
		else { unsafe { nil } }
	}
}

fn call_virtual(instance voidptr, _name voidptr, method_data voidptr, args voidptr, ret voidptr) {
	method := unsafe { &Method(method_data) }
	if method.action == action_stub {
		write_stub(ret, method.ret)
		return
	}
	dispatch(method.action, instance, args, ret)
}

fn write_stub(ret voidptr, kind int) {
	if ret == unsafe { nil } {
		return
	}
	match kind {
		ret_bool { write_bool(ret, false) }
		ret_number { write_number(ret, 0) }
		ret_pointer { write_pointer(ret, unsafe { nil }) }
		ret_string { zero(ret, 8) }
		ret_string_name { zero(ret, 8) }
		ret_dictionary { write_dictionary(ret) }
		ret_array { write_array(ret) }
		ret_packed_string { write_packed(ret, []string{}) }
		ret_variant { zero(ret, 24) }
		else {}
	}
}

fn method_specs() []Spec {
	return [
		Spec{kind_language, '_get_name', action_lang_name, ret_string},
		Spec{kind_language, '_init', action_stub, ret_none},
		Spec{kind_language, '_get_type', action_lang_type, ret_string},
		Spec{kind_language, '_get_extension', action_lang_extension, ret_string},
		Spec{kind_language, '_finish', action_stub, ret_none},
		Spec{kind_language, '_get_reserved_words', action_stub, ret_packed_string},
		Spec{kind_language, '_is_control_flow_keyword', action_stub, ret_bool},
		Spec{kind_language, '_get_comment_delimiters', action_lang_comments, ret_packed_string},
		Spec{kind_language, '_get_string_delimiters', action_lang_strings, ret_packed_string},
		Spec{kind_language, '_make_template', action_lang_template, ret_pointer},
		Spec{kind_language, '_get_built_in_templates', action_stub, ret_array},
		Spec{kind_language, '_is_using_templates', action_lang_templates, ret_bool},
		Spec{kind_language, '_validate', action_lang_validate, ret_dictionary},
		Spec{kind_language, '_validate_path', action_stub, ret_string},
		Spec{kind_language, '_create_script', action_lang_create, ret_pointer},
		Spec{kind_language, '_has_named_classes', action_stub, ret_bool},
		Spec{kind_language, '_supports_builtin_mode', action_stub, ret_bool},
		Spec{kind_language, '_supports_documentation', action_stub, ret_bool},
		Spec{kind_language, '_can_inherit_from_file', action_stub, ret_bool},
		Spec{kind_language, '_find_function', action_stub, ret_number},
		Spec{kind_language, '_make_function', action_stub, ret_string},
		Spec{kind_language, '_can_make_function', action_stub, ret_bool},
		Spec{kind_language, '_open_in_external_editor', action_stub, ret_number},
		Spec{kind_language, '_overrides_external_editor', action_stub, ret_bool},
		Spec{kind_language, '_complete_code', action_stub, ret_dictionary},
		Spec{kind_language, '_lookup_code', action_stub, ret_dictionary},
		Spec{kind_language, '_auto_indent_code', action_stub, ret_string},
		Spec{kind_language, '_add_global_constant', action_stub, ret_none},
		Spec{kind_language, '_add_named_global_constant', action_stub, ret_none},
		Spec{kind_language, '_remove_named_global_constant', action_stub, ret_none},
		Spec{kind_language, '_thread_enter', action_stub, ret_none},
		Spec{kind_language, '_thread_exit', action_stub, ret_none},
		Spec{kind_language, '_debug_get_error', action_stub, ret_string},
		Spec{kind_language, '_debug_get_stack_level_count', action_stub, ret_number},
		Spec{kind_language, '_debug_get_stack_level_line', action_stub, ret_number},
		Spec{kind_language, '_debug_get_stack_level_function', action_stub, ret_string},
		Spec{kind_language, '_debug_get_stack_level_source', action_stub, ret_string},
		Spec{kind_language, '_debug_get_stack_level_locals', action_stub, ret_dictionary},
		Spec{kind_language, '_debug_get_stack_level_members', action_stub, ret_dictionary},
		Spec{kind_language, '_debug_get_stack_level_instance', action_stub, ret_pointer},
		Spec{kind_language, '_debug_get_globals', action_stub, ret_dictionary},
		Spec{kind_language, '_debug_parse_stack_level_expression', action_stub, ret_string},
		Spec{kind_language, '_debug_get_current_stack_info', action_stub, ret_array},
		Spec{kind_language, '_reload_all_scripts', action_scripts_refresh, ret_none},
		Spec{kind_language, '_reload_scripts', action_scripts_refresh, ret_none},
		Spec{kind_language, '_reload_tool_script', action_scripts_refresh, ret_none},
		Spec{kind_language, '_get_recognized_extensions', action_lang_extensions, ret_packed_string},
		Spec{kind_language, '_get_public_functions', action_stub, ret_array},
		Spec{kind_language, '_get_public_constants', action_stub, ret_dictionary},
		Spec{kind_language, '_get_public_annotations', action_stub, ret_array},
		Spec{kind_language, '_profiling_start', action_stub, ret_none},
		Spec{kind_language, '_profiling_stop', action_stub, ret_none},
		Spec{kind_language, '_profiling_set_save_native_calls', action_stub, ret_none},
		Spec{kind_language, '_profiling_get_accumulated_data', action_stub, ret_number},
		Spec{kind_language, '_profiling_get_frame_data', action_stub, ret_number},
		Spec{kind_language, '_frame', action_scripts_refresh, ret_none},
		Spec{kind_language, '_handles_global_class_type', action_stub, ret_bool},
		Spec{kind_language, '_get_global_class_name', action_stub, ret_dictionary},
		Spec{kind_script, '_editor_can_reload_from_file', action_script_reload_file, ret_bool},
		Spec{kind_script, '_can_instantiate', action_script_can_instantiate, ret_bool},
		Spec{kind_script, '_get_base_script', action_stub, ret_pointer},
		Spec{kind_script, '_get_global_name', action_stub, ret_string_name},
		Spec{kind_script, '_inherits_script', action_stub, ret_bool},
		Spec{kind_script, '_get_instance_base_type', action_script_base, ret_string_name},
		Spec{kind_script, '_instance_create', action_script_instance, ret_pointer},
		Spec{kind_script, '_placeholder_instance_create', action_script_placeholder, ret_pointer},
		Spec{kind_script, '_instance_has', action_stub, ret_bool},
		Spec{kind_script, '_has_source_code', action_script_has_source, ret_bool},
		Spec{kind_script, '_get_source_code', action_script_get_source, ret_string},
		Spec{kind_script, '_set_source_code', action_script_set_source, ret_none},
		Spec{kind_script, '_reload', action_script_reload, ret_number},
		Spec{kind_script, '_get_doc_class_name', action_stub, ret_string_name},
		Spec{kind_script, '_get_documentation', action_stub, ret_array},
		Spec{kind_script, '_has_method', action_script_has_method, ret_bool},
		Spec{kind_script, '_has_static_method', action_stub, ret_bool},
		Spec{kind_script, '_get_method_info', action_stub, ret_dictionary},
		Spec{kind_script, '_is_tool', action_stub, ret_bool},
		Spec{kind_script, '_is_valid', action_script_valid, ret_bool},
		Spec{kind_script, '_get_language', action_script_language, ret_pointer},
		Spec{kind_script, '_has_script_signal', action_stub, ret_bool},
		Spec{kind_script, '_get_script_signal_list', action_stub, ret_array},
		Spec{kind_script, '_has_property_default_value', action_stub, ret_bool},
		Spec{kind_script, '_get_property_default_value', action_stub, ret_variant},
		Spec{kind_script, '_update_exports', action_stub, ret_none},
		Spec{kind_script, '_get_script_method_list', action_stub, ret_array},
		Spec{kind_script, '_get_script_property_list', action_stub, ret_array},
		Spec{kind_script, '_get_member_line', action_stub, ret_number},
		Spec{kind_script, '_get_constants', action_stub, ret_dictionary},
		Spec{kind_script, '_get_members', action_stub, ret_array},
		Spec{kind_script, '_is_placeholder_fallback_enabled', action_stub, ret_bool},
		Spec{kind_script, '_get_rpc_config', action_stub, ret_variant},
		Spec{kind_loader, '_get_recognized_extensions', action_loader_extensions, ret_packed_string},
		Spec{kind_loader, '_handles_type', action_loader_handles, ret_bool},
		Spec{kind_loader, '_get_resource_type', action_loader_type, ret_string},
		Spec{kind_loader, '_recognize_path', action_loader_recognize, ret_bool},
		Spec{kind_loader, '_load', action_loader_load, ret_variant},
		Spec{kind_saver, '_recognize', action_saver_recognize, ret_bool},
		Spec{kind_saver, '_get_recognized_extensions', action_saver_extensions, ret_packed_string},
		Spec{kind_saver, '_recognize_path', action_saver_path, ret_bool},
		Spec{kind_saver, '_save', action_saver_save, ret_number},
	]
}
