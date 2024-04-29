
use godot::builtin::meta::GodotConvert;
use godot::obj::cap::GodotDefault;
use godot::prelude::*;
use godot::engine::CharacterBody3D;


#[derive(GodotClass)]
#[class(base=CharacterBody3D)]
pub struct Player {
    speed: f64,
    angular_speed: f64,

    base: Base<CharacterBody3D>
}

#[godot_api]
impl Player {
    #[signal]
    fn hit();
}

impl GodotDefault for Player {}