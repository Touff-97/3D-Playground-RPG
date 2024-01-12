extends CharacterBody3D
class_name Player

const SPEED = 1.5
const JUMP_VELOCITY = 4.5

@onready var camera_arm: SpringArm3D = $CameraArm
@onready var camera: Camera3D = $CameraArm/Camera3D
@onready var name_label: Label3D = $NameLabel
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var armature: Node3D = $Armature

@export_group("Components", "component_")
@export var component_target : TargetComponent

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var sync_trans := Transform3D.IDENTITY
var sync_anim := Vector2.ZERO
var direction := Vector3.ZERO
var last_direction := 0.0
var last_animation := Vector2.ZERO
var boost : int = 1
var last_boost : int = 1


func _ready() -> void:
	set_multiplayer_authority(name.to_int())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	camera.set_current(get_multiplayer_authority() == multiplayer.get_unique_id())
	name_label.set_visible(get_multiplayer_authority() != multiplayer.get_unique_id())
	multiplayer_synchronizer.set_multiplayer_authority(name.to_int())
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		# Handle jump.
		if input_synchronizer.jumping and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		input_synchronizer.jumping = false
		
		if input_synchronizer.running:
			boost = 2
		else:
			boost = 1
		
		# Get the input direction and handle the movement/deceleration.
		direction = (transform.basis * Vector3(input_synchronizer.move_direction.x, 0, input_synchronizer.move_direction.y)).normalized()
		
		var lerp_animation = clamp(lerp(last_animation, input_synchronizer.move_direction * boost, 0.2), Vector2(-2, -2), Vector2(2, 2))
		animation_tree.set("parameters/Movement/blend_position", lerp_animation)
		last_animation = lerp_animation
		
		if direction:
			camera_arm.rotation.y = lerp(camera_arm.rotation.y, 0.0, 0.05)
			velocity.x = direction.x * SPEED * boost
			velocity.z = direction.z * SPEED * boost
			

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()
		sync_trans = transform
		sync_anim = lerp_animation
	else:
		transform = transform.interpolate_with(sync_trans, 0.2)
		animation_tree.set("parameters/Movement/blend_position", sync_anim)


func apply_rotation() -> void:
	# Handle character rotation
	var clamped_rot = camera_arm.rotation.x - input_synchronizer.rotation_direction.y
	clamped_rot = clamp(clamped_rot, -0.3334 * PI, 0.0778 * PI)
	camera_arm.rotation.x = clamped_rot
	
	if direction:
		var lerp_direction = lerp(last_direction, -input_synchronizer.rotation_direction.x, 0.05)
		rotate_y(lerp_direction)
		last_direction = lerp_direction
	
	camera_arm.rotate_y(-input_synchronizer.rotation_direction.x)
