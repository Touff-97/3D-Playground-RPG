extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_group("Components", "component_")
@export var component_target : TargetComponent

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera: Camera3D = $CameraArm/Camera3D
@onready var name_label: Label3D = $NameLabel

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var sync_trans := Transform3D.IDENTITY


func _ready() -> void:
	set_multiplayer_authority(name.to_int())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	camera.set_current(get_multiplayer_authority() == multiplayer.get_unique_id())
	name_label.set_visible(get_multiplayer_authority() != multiplayer.get_unique_id())
	multiplayer_synchronizer.set_multiplayer_authority(name.to_int())


func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# Handle character rotation
		component_target.target = Vector3(get_viewport().get_mouse_position().x, \
											get_viewport().get_mouse_position().y, \
											0)

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()
		sync_trans = transform
	else:
		transform = transform.interpolate_with(sync_trans, 0.2)
