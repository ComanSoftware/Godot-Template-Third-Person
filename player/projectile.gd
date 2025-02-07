extends RigidBody3D


const SPEED = 1200.0
var direction: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	var velocity = SPEED * direction
	apply_impulse(velocity)


func _physics_process(_delta):
	# If slowed down, delete
	if linear_velocity.length() < 80:
		queue_free()
	
	# If lot of distance to camera, delete
	var distance_to_camera = (self.position - get_viewport().get_camera_3d().global_position).length()
	if distance_to_camera > 2000:
		queue_free()
