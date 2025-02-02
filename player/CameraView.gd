extends Node3D

## Mouse sensitivity when moving the camera around
@export var MOUSE_SENSITIVITY := 0.05
## Minimum zoom in meters away from the players back.
@export var min_zoom := 4.0
## Maximum zoom in meters away from the players back.
@export var max_zoom := 12.0
## The zoom in meters when using 
@export var zoom_factor := 0.5
## The duration of the zoom animation
@export var zoom_duration := 0.1

@onready var y_rotation = $"Y Rotation"
@onready var x_rotation = $"Y Rotation/X Rotation"
@onready var camera = $"Y Rotation/X Rotation/Camera"

# Tween for zoom
var tween: Tween
# Target zoom level 
var _zoom_level := 4.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		x_rotation.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		y_rotation.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = x_rotation.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -40, 40)
		x_rotation.rotation_degrees = camera_rot
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)
	if event.is_action_pressed("right_click"):
		if Input.is_action_just_pressed("right_click"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_released("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _set_zoom_level(value: float):
	tween = get_tree().create_tween()
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.tween_property(
		camera,
		"position",
		Vector3(0, 0, _zoom_level),
		zoom_duration,
	)
