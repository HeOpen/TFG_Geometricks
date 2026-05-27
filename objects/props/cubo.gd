extends CSGBox3D

@export var x_speed:float = 1.5
@export var y_speed:float = 2
@export var z_speed:float = 2


func _process(delta):
	rotate_x(x_speed * delta)
	rotate_y(y_speed * delta)
	rotate_z(z_speed * delta)
	
