# Rune Engine
An experimental game engine focusing on modularity.

# About

Something I've always wanted is a tool that I could use to quickly prototype projects, but did not rely on a complex setup or toolset. Oftentimes when working on demos or small projects, all I need is an interface + renderer, so large game engines tended to be far more complex than needed, while smaller platform layers like SDL2 or Raylib were not enough.

It is my hopes to build a small, modular engine that is easy and straightforward to use. It remains yet to be seen if this will grow into a tool that others will want to use, but if you are curious about the roadmap, see the Roadmap Section.

Please be aware the Engine API is *very* early in development and should be considered highly unstable.

# Getting Started

Rune has two dependencies: Zig and Vulkan.

The engine is written in [Zig](https://ziglang.org/) and is needed to compile the engine.

Vulkan is the chosen graphics API for the builtin renderers. Maintaining multiple graphics backend for each platform is a monumental effort, so using Vulkan as a cross platform API seems the natural choice. 

Clone the repository `https://github.com/Mapledv/rune-engine.git`

Build the engine
```c
zig build
```

Run the testbed project
```c
zig build driver-run
```

# Roadmap

## Short Term Goals

Checkout the [Trello board](https://trello.com/b/DNQBZCqL/rune-engine) to see the immediate tasks being worked on.

## Long Term Goals and Features
- Builtin 2D and 3D Renderer using Vulkan
- Linux (XCB and Wayland) and Windows Platform Layer
- Editor using custom scripting language (TBD)
- Entity Component System Architecture
- Physics
- Artificial Inteliigence 
