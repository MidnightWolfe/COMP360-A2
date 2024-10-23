#From ChatGPT To allow camera moving and testing for debug purposes
extends Camera3D

# Sensitivity for mouse movement
var mouse_sensitivity := 0.3
var movement_speed := 5.0
var mouse_look_enabled := true

# Variables to track mouse movement
var pitch := 0.0
var yaw := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and mouse_look_enabled:
		_process_mouse_look(event)

	if Input.is_action_just_pressed("ui_cancel"):
		mouse_look_enabled = not mouse_look_enabled
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if not mouse_look_enabled else Input.MOUSE_MODE_CAPTURED)

func _process(delta: float):
	_process_keyboard_movement(delta)

func _process_mouse_look(event: InputEventMouseMotion):
	yaw -= event.relative.x * mouse_sensitivity
	pitch -= event.relative.y * mouse_sensitivity

	pitch = clamp(pitch, -89, 89)
	rotation_degrees = Vector3(pitch, yaw, 0)

func _process_keyboard_movement(delta: float):
	var direction := Vector3()

	if Input.is_action_pressed("ui_up"):   # W key
		direction -= transform.basis.z
	if Input.is_action_pressed("ui_down"): # S key
		direction += transform.basis.z
	if Input.is_action_pressed("ui_left"): # A key
		direction -= transform.basis.x
	if Input.is_action_pressed("ui_right"): # D key
		direction += transform.basis.x

	direction = direction.normalized()
	position += direction * movement_speed * delta
