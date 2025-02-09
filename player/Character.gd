extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera = $"Camera View/Y Rotation/X Rotation/CameraArm/Camera"
@onready var camera_x = $"Camera View/Y Rotation/X Rotation"
@onready var camera_y = $"Camera View/Y Rotation"
@onready var body = $"Body"
@onready var weapon = $"Body/Weapon"

var projectile_scene = load("res://player/Projectile.tscn")
@onready var attack_nodes = get_tree().get_current_scene().get_node("AttackNodes")

var tween_body: Tween


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# Rotate movement to direction of the camera
		direction = direction.rotated(Vector3(0,1,0), camera.global_rotation.y)
		# Rotate body of character in the direction of the camera
		# If the player is currently still, rotate with an animation
		if velocity.x == 0 and velocity.z == 0:
			rotate_player(camera.global_rotation.y, 0.3)
		# Otherwise rotate instantly
		else:
			body.rotation.y = camera.global_rotation.y
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()


func _unhandled_input(event):
	# Handle attacks
	if event.is_action_pressed("click"):
		# Get direction
		var direction = -1 * camera.global_transform.basis.z
		# Rotate Player in direction of shot
		rotate_player(camera.global_rotation.y, 0)
		await tween_body.finished
		# Find nearest point to the weapon on the direction of the shot
		var vector_to_weapon = weapon.global_position - camera.global_position
		var distance = direction.dot(vector_to_weapon)
		var closest_point = camera.global_position + distance * direction
		# Create the projectile instance
		var projectile = projectile_scene.instantiate()
		projectile.position = closest_point
		projectile.direction = direction
		attack_nodes.add_child(projectile)


func rotate_player(rotation_value:float, time:float):
	tween_body = get_tree().create_tween()
	tween_body.tween_property(
		body,
		"quaternion",
		Quaternion(Vector3(0,1,0), rotation_value),
		time,
	)
