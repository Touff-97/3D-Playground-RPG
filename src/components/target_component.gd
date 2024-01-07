# Look at whatever target you specify
extends Component
class_name TargetComponent

@export var origin : Node3D
# Create and set the target position
@export var target : Vector3 = Vector3.ZERO:
	set(new_value):
		target = new_value
		
		origin.look_at(target, Vector3.UP)
