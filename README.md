# Godot V

V as a script language for Godot 4.5 and newer

## Build

The built-in tcc does not set the non-executable stack flag, and Godot fails to load such a library when running on glibc 2.44.

clang:

```bash
v -cc clang -shared -enable-globals -o libgodotv.so .
```
