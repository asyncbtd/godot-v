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
 * Crash and error logging for the V language extension.
 *
 * Godot only shows a system coredump when the extension aborts, which is not
 * actionable. This helper keeps a small in-memory ring of recent messages and
 * appends them to a log file next to the project. On a fatal signal (or a Boehm
 * GC abort) it writes the signal, the GC reason if any, the recent messages and
 * a native backtrace to that log file and to stderr, then hands control back to
 * whatever handler was installed before (Godot / Mono / the default), so normal
 * engine and managed-exception behaviour is preserved.
 *
 * The crash path uses only async-signal-safe calls (open / write / close /
 * backtrace_symbols_fd); it never allocates V or libc heap memory.
 */

#ifndef GODOT_V_CRASH_H
#define GODOT_V_CRASH_H

#define GODOT_V_RING_SLOTS 64
#define GODOT_V_RING_MSG 256
#define GODOT_V_PATH_MAX 4096

static char godot_v_log_path[GODOT_V_PATH_MAX];
static int godot_v_log_path_set = 0;
static char godot_v_ring[GODOT_V_RING_SLOTS][GODOT_V_RING_MSG];
static volatile int godot_v_ring_head = 0;
static volatile int godot_v_ring_count = 0;

/* Set the destination log file. Copies the path; safe to call again to move it. */
static void godot_v_set_log_path(const char *path) {
	if (path == 0) {
		return;
	}
	int i = 0;
	for (; path[i] != 0 && i < GODOT_V_PATH_MAX - 1; i++) {
		godot_v_log_path[i] = path[i];
	}
	godot_v_log_path[i] = 0;
	godot_v_log_path_set = (i > 0);
}

/* Record a message in the ring buffer (best effort, lock free). */
static void godot_v_ring_push(const char *msg) {
	if (msg == 0) {
		return;
	}
	int slot = godot_v_ring_head;
	int i = 0;
	for (; msg[i] != 0 && i < GODOT_V_RING_MSG - 1; i++) {
		godot_v_ring[slot][i] = msg[i];
	}
	godot_v_ring[slot][i] = 0;
	godot_v_ring_head = (slot + 1) % GODOT_V_RING_SLOTS;
	if (godot_v_ring_count < GODOT_V_RING_SLOTS) {
		godot_v_ring_count++;
	}
}

#ifndef _WIN32

#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <execinfo.h>
#include <sys/syscall.h>
#include <gc/gc.h>

static int godot_v_open_log(void) {
	if (!godot_v_log_path_set) {
		return -1;
	}
	return open(godot_v_log_path, O_WRONLY | O_CREAT | O_APPEND, 0644);
}

static void godot_v_write_fd(int fd, const char *s) {
	if (fd < 0 || s == 0) {
		return;
	}
	unsigned long n = 0;
	while (s[n] != 0) {
		n++;
	}
	unsigned long off = 0;
	while (off < n) {
		long w = write(fd, s + off, n - off);
		if (w <= 0) {
			break;
		}
		off += (unsigned long)w;
	}
}

/* Write to the log file (if open) and to stderr. */
static void godot_v_emit(int fd, const char *s) {
	godot_v_write_fd(fd, s);
	godot_v_write_fd(STDERR_FILENO, s);
}

static void godot_v_emit_num(int fd, long v) {
	char buf[32];
	int i = 31;
	buf[i] = 0;
	int neg = (v < 0);
	unsigned long u = neg ? (unsigned long)(-(v + 1)) + 1UL : (unsigned long)v;
	if (u == 0) {
		buf[--i] = '0';
	}
	while (u != 0) {
		buf[--i] = (char)('0' + (u % 10));
		u /= 10;
	}
	if (neg) {
		buf[--i] = '-';
	}
	godot_v_emit(fd, buf + i);
}

/* Append one line to the log file and the ring. Normal (non-signal) context. */
static void godot_v_log_write(const char *line) {
	godot_v_ring_push(line);
	int fd = godot_v_open_log();
	if (fd >= 0) {
		godot_v_write_fd(fd, line);
		godot_v_write_fd(fd, "\n");
		close(fd);
	}
}

static const char *godot_v_sig_name(int sig) {
	switch (sig) {
	case SIGSEGV: return "SIGSEGV";
	case SIGBUS: return "SIGBUS";
	case SIGFPE: return "SIGFPE";
	case SIGILL: return "SIGILL";
	case SIGABRT: return "SIGABRT";
	case SIGTRAP: return "SIGTRAP";
	default: return "signal";
	}
}

static volatile sig_atomic_t godot_v_crashed = 0;

static void godot_v_dump_backtrace(int fd) {
	void *frames[128];
	int n = backtrace(frames, 128);
	godot_v_emit(fd, "--- backtrace ---\n");
	if (fd >= 0) {
		backtrace_symbols_fd(frames, n, fd);
	}
	backtrace_symbols_fd(frames, n, STDERR_FILENO);
}

/* Write the crash report once. `reason` carries the GC abort message, if any. */
static void godot_v_crash_dump(int sig, const char *reason) {
	if (godot_v_crashed) {
		return;
	}
	godot_v_crashed = 1;
	int fd = godot_v_open_log();
	godot_v_emit(fd, "\n=== godot-v crash ===\n");
	godot_v_emit(fd, "signal: ");
	godot_v_emit_num(fd, sig);
	godot_v_emit(fd, " (");
	godot_v_emit(fd, godot_v_sig_name(sig));
	godot_v_emit(fd, ")\n");
	if (reason != 0) {
		godot_v_emit(fd, "reason: ");
		godot_v_emit(fd, reason);
		godot_v_emit(fd, "\n");
	}
	godot_v_emit(fd, "pid: ");
	godot_v_emit_num(fd, (long)getpid());
	godot_v_emit(fd, "  tid: ");
	godot_v_emit_num(fd, (long)syscall(SYS_gettid));
	godot_v_emit(fd, "\n");
	godot_v_emit(fd, "log: ");
	godot_v_emit(fd, godot_v_log_path_set ? godot_v_log_path : "(stderr only)");
	godot_v_emit(fd, "\n");
	godot_v_emit(fd, "--- recent messages ---\n");
	int count = godot_v_ring_count;
	int oldest = (godot_v_ring_head - count + GODOT_V_RING_SLOTS) % GODOT_V_RING_SLOTS;
	for (int k = 0; k < count; k++) {
		int slot = (oldest + k) % GODOT_V_RING_SLOTS;
		godot_v_emit(fd, godot_v_ring[slot]);
		godot_v_emit(fd, "\n");
	}
	godot_v_dump_backtrace(fd);
	godot_v_emit(fd, "note: V frames show libgodotv.so+0xOFFSET; name them with: addr2line -e libgodotv.so -f 0xOFFSET\n");
	godot_v_emit(fd, "=== end godot-v crash ===\n");
	if (fd >= 0) {
		close(fd);
	}
}

static struct sigaction godot_v_old_actions[NSIG];
static volatile sig_atomic_t godot_v_installed = 0;
static char godot_v_alt_stack[65536];
static GC_abort_func godot_v_prev_gc_abort = 0;

/* Run the previous handler (Godot / Mono / default) after our report. */
static void godot_v_chain(int sig, siginfo_t *info, void *ucontext) {
	struct sigaction *old = &godot_v_old_actions[sig];
	/* Put the previous handler back so a re-raise does not loop into ours. */
	sigaction(sig, old, 0);
	if ((old->sa_flags & SA_SIGINFO) != 0) {
		if (old->sa_sigaction != 0) {
			old->sa_sigaction(sig, info, ucontext);
			return;
		}
	} else {
		if (old->sa_handler == SIG_IGN) {
			return;
		}
		if (old->sa_handler != SIG_DFL && old->sa_handler != 0) {
			old->sa_handler(sig);
			return;
		}
	}
	raise(sig);
}

static void godot_v_signal_handler(int sig, siginfo_t *info, void *ucontext) {
	godot_v_crash_dump(sig, 0);
	godot_v_chain(sig, info, ucontext);
}

/* Boehm GC calls this instead of aborting silently; log the reason first. */
static void GC_CALLBACK godot_v_gc_abort(const char *msg) {
	godot_v_crash_dump(SIGABRT, msg != 0 ? msg : "GC abort");
	if (godot_v_prev_gc_abort != 0) {
		godot_v_prev_gc_abort(msg);
	} else {
		abort();
	}
}

static void godot_v_install_crash_handlers(void) {
	if (godot_v_installed) {
		return;
	}
	godot_v_installed = 1;

	stack_t ss;
	memset(&ss, 0, sizeof(ss));
	ss.ss_sp = godot_v_alt_stack;
	ss.ss_size = sizeof(godot_v_alt_stack);
	ss.ss_flags = 0;
	sigaltstack(&ss, 0);

	/* Warm up backtrace so it does not allocate during a crash. */
	void *warm[8];
	backtrace(warm, 8);

	godot_v_prev_gc_abort = GC_get_abort_func();
	GC_set_abort_func(godot_v_gc_abort);

	int sigs[] = {SIGSEGV, SIGBUS, SIGFPE, SIGILL, SIGABRT, SIGTRAP};
	struct sigaction sa;
	memset(&sa, 0, sizeof(sa));
	sa.sa_sigaction = godot_v_signal_handler;
	sa.sa_flags = SA_ONSTACK | SA_SIGINFO;
	sigfillset(&sa.sa_mask);
	for (int i = 0; i < (int)(sizeof(sigs) / sizeof(sigs[0])); i++) {
		sigaction(sigs[i], &sa, &godot_v_old_actions[sigs[i]]);
	}
}

#else /* _WIN32 */

#include <stdio.h>
#include <stdlib.h>
#include <gc/gc.h>

static void godot_v_log_write(const char *line) {
	godot_v_ring_push(line);
	if (!godot_v_log_path_set) {
		return;
	}
	FILE *f = fopen(godot_v_log_path, "a");
	if (f != 0) {
		fprintf(f, "%s\n", line);
		fclose(f);
	}
}

static volatile int godot_v_crashed = 0;
static GC_abort_func godot_v_prev_gc_abort = 0;

/* On Windows we log GC aborts (the common native crash); fatal-signal handlers
 * are POSIX-only for now. Called from the GC hook, not a signal handler. */
static void godot_v_crash_dump(int sig, const char *reason) {
	if (godot_v_crashed) {
		return;
	}
	godot_v_crashed = 1;
	FILE *f = godot_v_log_path_set ? fopen(godot_v_log_path, "a") : 0;
	fprintf(stderr, "\n=== godot-v crash ===\nsignal: %d\n", sig);
	if (reason != 0) {
		fprintf(stderr, "reason: %s\n", reason);
	}
	if (f != 0) {
		fprintf(f, "\n=== godot-v crash ===\nsignal: %d\n", sig);
		if (reason != 0) {
			fprintf(f, "reason: %s\n", reason);
		}
	}
	int count = godot_v_ring_count;
	int oldest = (godot_v_ring_head - count + GODOT_V_RING_SLOTS) % GODOT_V_RING_SLOTS;
	for (int k = 0; k < count; k++) {
		int slot = (oldest + k) % GODOT_V_RING_SLOTS;
		fprintf(stderr, "%s\n", godot_v_ring[slot]);
		if (f != 0) {
			fprintf(f, "%s\n", godot_v_ring[slot]);
		}
	}
	fprintf(stderr, "=== end godot-v crash ===\n");
	if (f != 0) {
		fprintf(f, "=== end godot-v crash ===\n");
		fclose(f);
	}
}

static void GC_CALLBACK godot_v_gc_abort(const char *msg) {
	godot_v_crash_dump(6, msg != 0 ? msg : "GC abort");
	if (godot_v_prev_gc_abort != 0) {
		godot_v_prev_gc_abort(msg);
	} else {
		abort();
	}
}

static void godot_v_install_crash_handlers(void) {
	godot_v_prev_gc_abort = GC_get_abort_func();
	GC_set_abort_func(godot_v_gc_abort);
}

#endif /* _WIN32 */

#endif /* GODOT_V_CRASH_H */
