extends CharacterBody3D
class_name PlayerDummy

@onready var name_label: Label3D = $NameLabel
@onready var state_label: Label3D = $StateLabel
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer


var move_direction : Vector2 = Vector2.ZERO
var direction : Vector3 = Vector3.ZERO
var last_direction : float = 0.0
var boost : float = 1.0
# Sync multiplayer
var sync_trans : Transform3D = Transform3D.IDENTITY
var sync_move_anim : String = ""


func _ready() -> void:
	set_multiplayer_authority(name.to_int())
	multiplayer_synchronizer.set_multiplayer_authority(name.to_int())
	name_label.set_visible(get_multiplayer_authority() != multiplayer.get_unique_id())
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		sync_trans = transform
		sync_move_anim = anim_player.get_current_animation()
	else:
		transform = transform.interpolate_with(sync_trans, 0.2)
		anim_player.play(sync_move_anim)
