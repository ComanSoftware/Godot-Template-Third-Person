extends RigidBody3D


const SPEED = 50
var direction: Vector3
@onready var audio_start = $"AudioStart"
@onready var audio_hit = $"AudioHit"


# Called when the node enters the scene tree for the first time.
func _ready():
	audio_start.play()
	var velocity = SPEED * direction
	apply_impulse(velocity)
	look_at(position + direction)


func _physics_process(_delta):
	# If slowed down, delete
	if linear_velocity.length() > 0 and linear_velocity.length() < 5:
		queue_free()
	
	# If lot of distance to camera, delete
	var distance_to_camera = (self.position - get_viewport().get_camera_3d().global_position).length()
	if distance_to_camera > 2000:
		queue_free()


func _on_area_body_entered(body):
	print(body)
	if body.get_name() != "Player":
		# Freeze physics
		set_deferred("freeze", true)
		# Check if it is currently already processed and skip
		if !get_node_or_null("Collision") or !get_node_or_null("Mesh"):
			return
		# Play explosion sound
		audio_hit.play()
		# Remove collision shape 
		remove_child($Collision)
		# Remove missile asset 
		remove_child($Mesh)
		# Wait for 2 seconds, so that later we could 
		# add some animations in the meantime
		await get_tree().create_timer(2).timeout
		queue_free()
