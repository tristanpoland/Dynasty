# Dynasty

A powerful class inheritance system for Rust initially designed for the Pulsar game engine.

## Features

- Compile-time class registration
- Runtime type information and reflection
- Safe downcasting and type checking
- Serialization support (optional)
- Method inheritance through traits
- Component-based composition

## Structure

This workspace contains two crates:
- `dynasty`: The main crate providing the runtime functionality
- `dynasty-macros`: The procedural macros for class definition

## Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
dynasty = "0.1.0"
```

## Usage

```rust
use dynasty::prelude::*;

#[derive(Class)]
pub struct Entity {
    id: u64,
    name: String,
}

#[inherit(Entity)]
pub struct Character {
    #[parent]
    base: Entity,
    health: f32,
    level: u32,
}
```

## License

Licensed under either of:

 * Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
