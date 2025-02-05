#!/bin/bash

# Dynasty Project Setup Script
echo "Setting up Dynasty workspace..."

# Create project directory and enter it
mkdir dynasty-workspace
cd dynasty-workspace

# Initialize git
git init
git branch -M main

# Create workspace structure
mkdir -p dynasty/src dynasty-macros/src
touch dynasty/src/lib.rs dynasty-macros/src/lib.rs

# Create root Cargo.toml (workspace)
cat > Cargo.toml << EOL
[workspace]
members = [
    "dynasty",
    "dynasty-macros"
]

resolver = "2"
EOL

# Create dynasty-macros/Cargo.toml
cat > dynasty-macros/Cargo.toml << EOL
[package]
name = "dynasty-macros"
version = "0.1.0"
edition = "2021"
authors = ["Tristan J. Poland"]
description = "Procedural macros for the Dynasty class system"
license = "MIT OR Apache-2.0"
repository = "https://github.com/tristanpoland/dynasty"

[lib]
proc-macro = true

[dependencies]
syn = { version = "2.0", features = ["full", "extra-traits"] }
quote = "1.0"
proc-macro2 = "1.0"
EOL

# Create dynasty/Cargo.toml
cat > dynasty/Cargo.toml << EOL
[package]
name = "dynasty"
version = "0.1.0"
edition = "2021"
authors = ["Tristan J. Poland"]
description = "A powerful class inheritance system for Rust game engines"
license = "MIT OR Apache-2.0"
repository = "https://github.com/tristanpoland/dynasty"
documentation = "https://docs.rs/dynasty"
readme = "../README.md"
keywords = ["gamedev", "inheritance", "class", "hierarchy", "engine"]
categories = ["game-engines", "game-development"]

[dependencies]
dynasty-macros = { path = "../dynasty-macros", version = "0.1.0" }
once_cell = "1.18"
thiserror = "1.0"
inventory = "0.3"
serde = { version = "1.0", features = ["derive"], optional = true }
uuid = { version = "1.6", features = ["v4"] }

[features]
default = ["reflection"]
reflection = []
serialization = ["serde"]
EOL

# Create core module files in dynasty crate
mkdir -p dynasty/src/{registry,error,reflection,traits}
touch dynasty/src/{registry,error,reflection,traits}/mod.rs

# Create README.md in root
cat > README.md << EOL
# Dynasty

A powerful class inheritance system for Rust game engines.

## Features

- Compile-time class registration
- Runtime type information and reflection
- Safe downcasting and type checking
- Serialization support (optional)
- Method inheritance through traits
- Component-based composition

## Structure

This workspace contains two crates:
- \`dynasty\`: The main crate providing the runtime functionality
- \`dynasty-macros\`: The procedural macros for class definition

## Installation

Add this to your \`Cargo.toml\`:

\`\`\`toml
[dependencies]
dynasty = "0.1.0"
\`\`\`

## Usage

\`\`\`rust
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
\`\`\`

## License

Licensed under either of:

 * Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
EOL

# Create license files in root
cat > LICENSE-MIT << EOL
MIT License

Copyright (c) 2024 Tristan J. Poland

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOL

# Create initial dynasty-macros/src/lib.rs
cat > dynasty-macros/src/lib.rs << EOL
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput};

#[proc_macro_derive(Class, attributes(inherit))]
pub fn derive_class(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = &input.ident;

    let expanded = quote! {
        impl Class for #name {
            fn class_info() -> &'static ClassInfo {
                static INFO: once_cell::sync::Lazy<ClassInfo> = once_cell::sync::Lazy::new(|| {
                    ClassInfo {
                        id: uuid::Uuid::new_v4(),
                        name: stringify!(#name),
                        parent: None,
                        type_id: std::any::TypeId::of::<#name>(),
                        #[cfg(feature = "reflection")]
                        reflection_data: ReflectionData::new::<#name>(),
                    }
                });
                &INFO
            }

            fn as_any(&self) -> &dyn std::any::Any {
                self
            }

            fn as_any_mut(&mut self) -> &mut dyn std::any::Any {
                self
            }
        }
    };

    TokenStream::from(expanded)
}

#[proc_macro_attribute]
pub fn inherit(attr: TokenStream, item: TokenStream) -> TokenStream {
    let parent_type = attr.to_string();
    let input = parse_macro_input!(item as DeriveInput);
    let name = &input.ident;

    let expanded = quote! {
        #[derive(Class)]
        #input

        impl Inherits<#parent_type> for #name {
            fn as_parent(&self) -> &#parent_type {
                &self.base
            }

            fn as_parent_mut(&mut self) -> &mut #parent_type {
                &mut self.base
            }
        }
    };

    TokenStream::from(expanded)
}
EOL

# Create initial dynasty/src/lib.rs
cat > dynasty/src/lib.rs << EOL
//! Dynasty: A powerful class inheritance system for Rust game engines

pub mod error;
pub mod registry;
pub mod reflection;
pub mod traits;

pub use dynasty_macros::{Class, inherit};

pub mod prelude {
    pub use crate::{Class, inherit};
    pub use crate::traits::{Inherits, SafeDowncast};
    pub use crate::registry::Registry;
    
    #[cfg(feature = "reflection")]
    pub use crate::reflection::Reflect;
}
EOL

# Create .gitignore
cat > .gitignore << EOL
/target
Cargo.lock
**/*.rs.bk
.DS_Store
.idea
.vscode
EOL

# Initialize git repository
git add .
git commit -m "Initial commit: Dynasty workspace setup"

echo "Project setup complete! Directory structure:"
tree

echo "Next steps:"
echo "1. Create a new repository at https://github.com/tristanpoland/dynasty"
echo "2. Run these commands to push to GitHub:"
echo "   git remote add origin https://github.com/tristanpoland/dynasty.git"
echo "   git push -u origin main"
echo "3. Implement the remaining module files in dynasty/src/"
echo "4. Add tests"
echo "5. Set up CI/CD"