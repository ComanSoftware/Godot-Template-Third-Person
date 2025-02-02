extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera_y = $"Camera View/Y Rotation"
@onready var body = $"Body"

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
		direction = direction.rotated(Vector3(0,1,0), camera_y.rotation.y)
		# Rotate body of character in the direction of the camera
		# If the player is currently still, rotate with an animation
		if velocity.x == 0 and velocity.z == 0:
			tween_body = get_tree().create_tween()
			tween_body.tween_property(
				body,
				"rotation",
				Vector3(0, camera_y.rotation.y, 0),
				0.3,
			)
		# Otherwise rotate instantly
		else:
			body.rotation.y = camera_y.rotation.y
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
