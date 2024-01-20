extends CharacterBody3D
class_name Player

@onready var name_label: Label3D = $NameLabel
@onready var state_label: Label3D = $StateLabel
@onready var camera: Camera3D = $CameraArm/Camera3D
@onready var camera_arm: SpringArm3D = $CameraArm
@onready var animations: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@export_group("Settings")
@export var move_speed : float = 1.5
@export var sensitivity : int = 5

@export_group("Components")
@export var input_component : InputComponent
@export var move_machine: StateMachineComponent
@export var action_machine: StateMachineComponent

var move_direction : Vector2 = Vector2.ZERO
var direction : Vector3 = Vector3.ZERO
var last_direction : float = 0.0
var last_animation : Vector2 = Vector2.ZERO
var boost : float = 1.0
# Sync multiplayer
var sync_trans : Transform3D = Transform3D.IDENTITY
var sync_anim : Vector2 = Vector2.ZERO


func _ready() -> void:
	set_multiplayer_authority(name.to_int())
	multiplayer_synchronizer.set_multiplayer_authority(name.to_int())
	camera.set_current(get_multiplayer_authority() == multiplayer.get_unique_id())
	name_label.set_visible(get_multiplayer_authority() != multiplayer.get_unique_id())
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	move_machine.init(self, animations, input_component)
	#action_machine.init(self, animations, input_component)
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		animations.active = false


func _unhandled_input(event: InputEvent) -> void:
	move_machine.process_input(event)
	#action_machine.process_input(event)


func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		direction = (transform.basis * Vector3(move_direction.x, 0, move_direction.y)).normalized()
		
		move_machine.process_physics(delta)
		#action_machine.process_physics(delta)
		
		if direction:
			camera_arm.rotation.y = lerp(camera_arm.rotation.y, 0.0, 0.05)
		
		# Ensure smooth transition between movement animations of different states
		var lerp_animation = clamp(lerp(last_animation, move_direction, 0.2), Vector2(-1, -1), Vector2(1, 1))
		last_animation = lerp_animation
		
		animate(lerp_animation)
		
		sync_trans = transform
		sync_anim = lerp_animation
	else:
		transform = transform.interpolate_with(sync_trans, 0.2)
		animate(sync_anim)


func _process(delta: float) -> void:
	move_machine.process_frame(delta)
	#action_machine.process_frame(delta)


func apply_rotation(event: InputEvent) -> void:
	var rotation_dir = (event.relative / 1000) * sensitivity
	# Handle character rotation
	var clamped_rot = camera_arm.rotation.x - rotation_dir.y
	clamped_rot = clamp(clamped_rot, -0.3334 * PI, 0.0778 * PI)
	camera_arm.rotation.x = clamped_rot
	
	if direction:
		var lerp_direction = lerp(last_direction, -rotation_dir.x, 0.05)
		rotate_y(lerp_direction)
		last_direction = lerp_direction
	
	var lerp_direction = lerp(last_direction, -rotation_dir.x, 0.075)
	camera_arm.rotate_y(lerp_direction)
	last_direction = lerp_direction


func animate(anim_vector: Vector2) -> void:
	# Set walking animations' blend_positions
	animations.set("parameters/Walk/blend_position", anim_vector)
	animations.set("parameters/Walking Jump/blend_position", anim_vector.y)
	
	animations.set("parameters/Run/blend_position", anim_vector)
	animations.set("parameters/Running Jump/blend_position", anim_vector.y)
	
	## BUG: Animation conditions are not synced
