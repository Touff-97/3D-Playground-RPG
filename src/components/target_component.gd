# Look at whatever target you specify
extends Component
class_name TargetComponent

@export var origin : Node3D:
	set(new_value):
		origin = new_value

@export var mirror : bool = false:
	set(new_value):
		mirror = new_value
		
		self.position.x *= -1


func _process(delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		origin.look_at(self.position, Vector3.UP)
