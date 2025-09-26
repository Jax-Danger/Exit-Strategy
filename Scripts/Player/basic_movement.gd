extends CharacterBody3D
class_name Movement

#Camera
@onready var head: Node3D = $Head
@onready var cam: Camera3D = $Head/Camera3D

# sensitivity for looking around
@export var mouse_sensitivity := 0.12
var pitch := 0.0

@export var SPEED = 3
@export var JUMP_VELOCITY = 3

var input_enabled:bool = true
# inspection
var is_inspecting: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Movement ready forced →", Input.get_mouse_mode())

func _unhandled_input(event):
	if not input_enabled: return #blcok all input when disabled
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate body (yaw)
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		# Rotate head (pitch, clamped)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -89, 89)
		head.rotation_degrees.x = pitch
		
	# Escape (ui_cancel) → release mouse
	if event.is_action_pressed("ui_cancel") and not is_inspecting:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Settings.show()
	# Left click → recapture mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if not input_enabled: return #blcok all input when disabled
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func set_input_enabled(enabled:bool)->void: input_enabled = enabled
