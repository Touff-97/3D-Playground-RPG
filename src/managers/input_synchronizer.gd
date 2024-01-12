extends MultiplayerSynchronizer

@export var move_direction := Vector2.ZERO
@export var rotation_direction := Vector2.ZERO
@export var jumping : bool = false
@export var running : bool = false

@export var sensitivity : int = 5

signal mouse_moved


func _process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		move_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump.rpc()
	
	if event.is_action_pressed("run"):
		run.rpc()
	
	if event.is_action_released("run"):
		run.rpc()
	
	if event is InputEventMouseMotion:
		rotation_direction = (event.relative / 1000) * sensitivity
		emit_signal("mouse_moved")


@rpc("call_local")
func jump() -> void:
	jumping = true


@rpc("call_local")
func run() -> void:
	running = !running
