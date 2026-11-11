# Godot V

**V as a script language for Godot 4.5 and newer**

<p>
  <img alt="License" src="https://img.shields.io/badge/license-Apache%202.0-blue.svg" />
  <img alt="Godot" src="https://img.shields.io/badge/engine-Godot%204.5%2B-478cbf.svg" />
  <img alt="V" src="https://img.shields.io/badge/language-V-5d87bf.svg" />
</p>

- [How It Works](#how-it-works)
- [Supported Versions](#supported-versions)
- [Usage](#usage)
- [Getting Started](#getting-started)
- [License](#license)
- [Contact Us](#contact-us)

## How It Works

`libgodotv.so` is the `asyncbtd.godot` module. Godot loads it and calls `godot_v_init`. That registers V as a script language and opens the game library.

- The registration lives in `bridge/*.v`, in the same `godot` module as `godot.Node` and the `godot.NodeClass` and `godot.SignalOn` attributes.
- Sources are split with `subdirs` in `v.mod`:
  - `bridge`: GDExtension script language;
  - `extension`: bindings and runtime.

The game imports `asyncbtd.godot` and gets its attributes from that same module. It does not register the language a second time.

## Supported Versions

Each column after `Godot Support` is a Godot V release line and shows how it supports that Godot version.

| Godot | Godot Support | Godot V 0.1.x |
|-------|---------------|---------------|
| 4.7.x | Full          | Full          |
| 4.6.x | Full          | Full          |
| 4.5.x | Security only | Full          |

## Usage

### Call the engine from V

```v
import asyncbtd.godot

@[godot.NodeClass('Area2D')]
pub struct Player {}

pub fn (mut self Player) ready() {
	// runs when the node enters the scene tree
}

@[godot.SignalOn('.', 'body_entered')]
pub fn (mut self Player) on_body_entered() {
	// connected to the `body_entered` signal of this node
}
```

- `godot.Node` and the other engine classes come from the generated files.
- Registration is done by attributes, no `init` function is needed:
  - `@[godot.NodeClass('Area2D')]` sets the native base class of the script;
  - `@[godot.SignalOn(node, signal)]` connects a method to a signal.

### Compile the game scripts

The game `v.mod` depends on `asyncbtd.godot`. Its `name` is the library file name. From the game directory:

```bash
v -cc clang -shared -enable-globals -o game.so .
```

- `game` is the `name` from the game `v.mod`;
- `.so` is `.dylib` on macOS and `.dll` on Windows.

Put the library in the game root or in one of `bin`, `bins`, `build`, `builds`, `lib`, `libs`, `target`, `targets`.
One copy only. If several are found, the language library stops.

Rebuild it and start Godot again after script changes. Godot does not load this file as a second GDExtension.

## Getting Started

### 1. Install this module

```bash
v install asyncbtd.godot
```

### 3. Dump the engine API

Run this with the Godot editor you ship the game on. It writes `extension_api.json` in the current directory.

```bash
godot --headless --quit --dump-extension-api-with-docs
```

With [godots](https://github.com/MakovWait/godots), from a directory that contains `project.godot` or `.godot-version`:

```bash
godots exec -- --headless --quit --dump-extension-api-with-docs
```

### 4. Generate the V bindings

The generator reads `extension_api.json` from the current directory, or the path you pass. It writes `extension/_*.v` into this module and deletes only those files before writing. The generated files stay on disk and are not committed.

```bash
v run generator/generation.vsh
v run generator/generation.vsh /absolute/path/to/extension_api.json
```

### 5. Build the language library

`godot_v_init` is compiled into this library. The built-in tcc does not set the non-executable stack flag, and Godot fails to load such a library on glibc 2.44. Use clang or gcc.

```bash
v -cc clang -shared -enable-globals -o libgodotv.so .
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

## License

See [Apache License, Version 2.0](https://github.com/asyncbtd/godot-v/blob/develop/LICENSE).

## Contact Us

Issues and questions: [GitHub Issues](https://github.com/asyncbtd/godot-v/issues).
