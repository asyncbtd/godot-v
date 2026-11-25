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

/*
 * Godot calls into V on its own threads (editor workers, resource loaders,
 * the thread pool). Those threads are created by Godot, not by V, so the
 * Boehm GC does not know about them. The first time such a thread allocates
 * V memory and triggers a collection, the GC aborts with
 * "Collecting from unknown thread" (SIGABRT).
 *
 * godot_v_attach_thread() registers the calling thread with the GC before it
 * runs any V code. It is cheap and idempotent: once a thread is registered the
 * fast path is a single thread-local check. A per-thread destructor
 * unregisters the thread when Godot tears it down, so transient worker threads
 * do not leak GC thread entries.
 *
 * The GC is shared between the language library and the game library (the host
 * is promoted to RTLD_GLOBAL), and _vinit already calls
 * GC_allow_register_threads(), so explicit registration is permitted.
 */

#ifndef GODOT_V_GC_THREAD_H
#define GODOT_V_GC_THREAD_H

#include <gc/gc.h>

#ifndef _WIN32

#include <pthread.h>

static pthread_key_t godot_v_gc_thread_key;
static pthread_once_t godot_v_gc_key_once = PTHREAD_ONCE_INIT;
static _Thread_local int godot_v_gc_attached = 0;

/* Runs when a thread we registered exits. */
static void godot_v_gc_thread_detach(void *value) {
	(void)value;
	GC_unregister_my_thread();
}

static void godot_v_gc_create_key(void) {
	pthread_key_create(&godot_v_gc_thread_key, godot_v_gc_thread_detach);
}

static void godot_v_attach_thread(void) {
	if (godot_v_gc_attached) {
		return;
	}
	if (GC_thread_is_registered()) {
		/* Already known to the GC (e.g. a V-spawned thread). */
		godot_v_gc_attached = 1;
		return;
	}
	struct GC_stack_base sb;
	if (GC_get_stack_base(&sb) != GC_SUCCESS) {
		return;
	}
	if (GC_register_my_thread(&sb) != GC_SUCCESS) {
		/* GC_DUPLICATE: another path registered it; leave cleanup to it. */
		return;
	}
	godot_v_gc_attached = 1;
	pthread_once(&godot_v_gc_key_once, godot_v_gc_create_key);
	pthread_setspecific(godot_v_gc_thread_key, (void *)1);
}

#else /* _WIN32 */

#include <windows.h>

static DWORD godot_v_gc_fls_index = FLS_OUT_OF_INDEXES;
static LONG godot_v_gc_fls_once = 0;
static __declspec(thread) int godot_v_gc_attached = 0;

static void WINAPI godot_v_gc_fls_detach(void *value) {
	(void)value;
	GC_unregister_my_thread();
}

static void godot_v_attach_thread(void) {
	if (godot_v_gc_attached) {
		return;
	}
	if (GC_thread_is_registered()) {
		godot_v_gc_attached = 1;
		return;
	}
	struct GC_stack_base sb;
	if (GC_get_stack_base(&sb) != GC_SUCCESS) {
		return;
	}
	if (GC_register_my_thread(&sb) != GC_SUCCESS) {
		return;
	}
	godot_v_gc_attached = 1;
	if (InterlockedCompareExchange(&godot_v_gc_fls_once, 1, 0) == 0) {
		godot_v_gc_fls_index = FlsAlloc(godot_v_gc_fls_detach);
	}
	if (godot_v_gc_fls_index != FLS_OUT_OF_INDEXES) {
		FlsSetValue(godot_v_gc_fls_index, (void *)1);
	}
}

#endif /* _WIN32 */

#endif /* GODOT_V_GC_THREAD_H */
