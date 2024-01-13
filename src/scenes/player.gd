extends CharacterBody3D
class_name Player

@onready var name_label: Label3D = $NameLabel
@onready var camera: Camera3D = $CameraArm/Camera3D
@onready var camera_arm: SpringArm3D = $CameraArm
@onready var animations: AnimationTree = $AnimationTree
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@export_group("Settings")
@export var move_speed : float = 1.5
@export var sensitivity : int = 5

@export_group("Components")
@export var input_component : InputComponent
@export var state_machine: StateMachineComponent

var direction : Vector3 = Vector3.ZERO
var last_direction : float = 0.0
var rotation_direction : Vector2 = Vector2.ZERO
var boost : float = 1.0
var move_animation : Vector2 = Vector2.ZERO 
# Sync multiplayer
var sync_trans : Transform3D = Transform3D.IDENTITY
var sync_move_anim : Vector2= Vector2.ZERO


func _ready() -> void:
	set_multiplayer_authority(name.to_int())
	multiplayer_synchronizer.set_multiplayer_authority(name.to_int())
	camera.set_current(get_multiplayer_authority() == multiplayer.get_unique_id())
	name_label.set_visible(get_multiplayer_authority() != multiplayer.get_unique_id())
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	state_machine = get_node("StateMachine")
	state_machine.init(self, animations, input_component)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_direction = (event.relative / 1000) * sensitivity
		apply_rotation(rotation_direction)


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		var move_direction = input_component.get_movement_direction()
		direction = (transform.basis * Vector3(move_direction.x, 0, move_direction.y)).normalized()
	
		state_machine.process_physics(delta)
		
		if direction:
			camera_arm.rotation.y = lerp(camera_arm.rotation.y, 0.0, 0.05)

		sync_trans = transform
		sync_move_anim = move_animation
	else:
		transform = transform.interpolate_with(sync_trans, 0.2)
		animations.set("parameters/Movement/blend_position", sync_move_anim)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)


func apply_rotation(rotation_dir) -> void:
	# Handle character rotation
	var clamped_rot = camera_arm.rotation.x - rotation_dir.y
	clamped_rot = clamp(clamped_rot, -0.3334 * PI, 0.0778 * PI)
	camera_arm.rotation.x = clamped_rot
	
	if direction:
		var lerp_direction = lerp(last_direction, -rotation_dir.x, 0.05)
		rotate_y(lerp_direction)
		last_direction = lerp_direction
	
	camera_arm.rotate_y(-rotation_dir.x)
