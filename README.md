# Godot V

V as a script language for Godot 4.5 and newer.

There are two libraries.

`libgodotv.so` is `asyncbtd.godot.bridge`. Godot loads it and calls `godot_v_init`. That registers V as a script language and opens the game library.

`script/script.so` is the game. Its code imports `asyncbtd.godot` and does not register the language. Calls such as `godot.register_player` and `godot.Node` go through the already loaded `libgodotv.so`.

## 1. Install V

Install V from [https://github.com/vlang/v](https://github.com/vlang/v). The `v` command must be on `PATH`.

## 2. Install this module

```bash
v install asyncbtd.godot
```

The checkout is usually `~/.vmodules/asyncbtd/godot`. The commands below run from that directory.

## 3. Dump the engine API

Run this with the Godot editor you ship the game on. It writes `extension_api.json` in the current directory.

```bash
godot --headless --quit --dump-extension-api
```

With [godots](https://github.com/MakovWait/godots), from a directory that contains `project.godot` or `.godot-version`:

```bash
godots exec -- --headless --quit --dump-extension-api
```

## 4. Generate the V bindings

The generator reads `extension_api.json` from the current directory, or the path you pass. It writes `src/_*.v` into this module and deletes only those files before writing. The generated files stay on disk and are not committed.

```bash
v run generator/generation.vsh
v run generator/generation.vsh /absolute/path/to/extension_api.json
```

## 5. Build the language library

`godot_v_init` is compiled into this library. The built-in tcc does not set the non-executable stack flag, and Godot fails to load such a library on glibc 2.44. Use clang or gcc.

```bash
v -cc clang -shared -enable-globals -o libgodotv.so src/bridge
```

Copy `libgodotv.so` into the Godot project and add `godot.gdextension` next to `project.godot`:

```ini
[configuration]

entry_symbol = "godot_v_init"
compatibility_minimum = "4.5"

[libraries]

linux.debug.x86_64 = "res://lib/libgodotv.so"
linux.release.x86_64 = "res://lib/libgodotv.so"
linux.editor.x86_64 = "res://lib/libgodotv.so"
linux.editor.debug.x86_64 = "res://lib/libgodotv.so"
linux.editor.release.x86_64 = "res://lib/libgodotv.so"
```

## 6. Call the engine from V

```v
import asyncbtd.godot

fn rename(node godot.Node) {
	node.set_name('player')
}

fn init() {
	godot.register_player(player_enter, player_frame, player_signal)
}
```

`godot.Node` comes from the generated files. `godot.register_player` is the hand-written call into `libgodotv.so`.

## 7. Compile the game scripts

Put the game modules under `script/`. The game `v.mod` depends on `asyncbtd.godot`. From `script/`:

```bash
v -cc clang -shared -enable-globals .
```

V writes `script/script.so`. Rebuild it and start Godot again after script changes. Godot does not load this file as a second GDExtension.
