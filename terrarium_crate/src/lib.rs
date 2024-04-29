use godot::prelude::*;
mod player;
use crate::player::Player;
struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}