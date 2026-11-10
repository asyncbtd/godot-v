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

#include <stdint.h>

void godot_v_report(uint8_t *ptr, int len);
void godot_v_register_main(void *enter, void *handler);
void godot_v_register_player(void *enter, void *frame, void *handler);
void godot_v_register_mob(void *enter);
void *godot_v_live(void);
void *godot_v_owner(void);
void godot_v_call_group(void *object, uint8_t *group, int group_len, uint8_t *method, int method_len);
void godot_v_call_method(void *object, uint8_t *method, int len);
void *godot_v_node_at(void *object, uint8_t *path, int len);
void godot_v_timer_start(void *object);
void godot_v_timer_stop(void *object);
void godot_v_hide_node(void *object);
void godot_v_show_node(void *object);
void godot_v_audio_play(void *object);
void godot_v_audio_stop(void *object);
void *godot_v_load_resource(uint8_t *path, int len);
uint8_t godot_v_feature(uint8_t *name, int len);
void godot_v_set_text_prop(void *object, uint8_t *prop, int prop_len, uint8_t *value, int value_len);
void godot_v_set_flag_prop(void *object, uint8_t *prop, int prop_len, uint8_t value);
void *godot_v_instance_scene(void *scene);
void godot_v_set_progress_ratio(void *object, double ratio);
void godot_v_position_of(void *object, float *x, float *y);
double godot_v_rotation_of(void *object);
void godot_v_move_to(void *object, float x, float y);
void godot_v_set_rotation(void *object, double angle);
void godot_v_push_velocity(void *object, float x, float y);
void godot_v_add_child(void *parent, void *child);
void godot_v_play_anim(void *object, uint8_t *name, int len);
void godot_v_stop_anim(void *object);
void godot_v_viewport_size(void *object, float *x, float *y);
void godot_v_set_disabled(void *object, uint8_t disabled);
void *godot_v_parent_of(void *object);
void godot_v_set_deferred_flag(void *object, uint8_t *prop, int len, uint8_t value);
uint8_t godot_v_action_down(uint8_t *name, int len);
double godot_v_delta_of(void *object);
