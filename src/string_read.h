/*
 * Copyright 2026 Timofey Brukhanchik
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

static inline int64_t godot_call_string_read(void *f, void *src, void *buf, int64_t n) {
	typedef int64_t (*ReadFn)(void *, void *, int64_t);
	return ((ReadFn)f)(src, buf, n);
}
