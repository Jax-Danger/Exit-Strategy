extends Node3D

var cam: Camera3D
var inspected_instance: Node3D
var original_instance: Node3D
var player: Movement

@onready var overlay: ColorRect = $CanvasLayer/Background
@onready var desc: Label = $CanvasLayer/DescriptionLabel

# live zoom config (filled from the Interactable)
var _zoom_step := 0.1
var _min_zoom := 0.3
var _max_zoom := 2.0

func _ready() -> void:
	# start hidden
	overlay.visible = false
	overlay.modulate.a = 0.0
	desc.visible = false

	# make sure UI never steals mouse input
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE

func open_from_node(source: Node3D, player_ref: Movement) -> void:
	player = player_ref
	cam = player.cam
	player.is_inspecting = true
	player.set_input_enabled(false)

	# clean any previous copy
	if inspected_instance:
		inspected_instance.queue_free()

	# hide original in the world
	original_instance = source
	original_instance.visible = false

	# duplicate & strip and attach to camera (so it sits "in front of the UI")
	inspected_instance = source.duplicate()
	inspected_instance.visible = true
	_strip_for_inspection(inspected_instance)
	inspected_instance.transform = Transform3D.IDENTITY
	cam.add_child(inspected_instance)

	# pull per-object config
	var spawn_distance := 0.75
	var inspect_scale := 1.0
	if source is InteractableObject and source.can_inspect():
		spawn_distance = source.inspect_spawn_distance
		_zoom_step = source.inspect_zoom_step
		_min_zoom = source.inspect_min_zoom
		_max_zoom = source.inspect_max_zoom
		inspect_scale = source.inspect_scale
	else:
		_zoom_step = 0.1; _min_zoom = 0.3; _max_zoom = 2.0

	# center, scale, then place in front of camera
	_center_to_origin(inspected_instance)
	inspected_instance.scale *= inspect_scale
	inspected_instance.position = Vector3(0, 0, -spawn_distance)

	# overlay + description
	desc.text = (source.inspect_description if source is InteractableObject else "")
	overlay.visible = true
	desc.visible = true
	create_tween().tween_property(overlay, "modulate:a", 0.5, 0.2)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close() -> void:
	if inspected_instance:
		inspected_instance.queue_free()
		inspected_instance = null

	if original_instance:
		original_instance.visible = true
		original_instance = null

	if player:
		player.is_inspecting = false
		player.set_input_enabled(true)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var t = create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, 0.2)
	t.finished.connect(func(): overlay.visible = false)
	desc.visible = false
	desc.text = ""

# ---- Input while inspecting ----
func _unhandled_input(event: InputEvent) -> void:
	if not inspected_instance: return

	if event.is_action_pressed("exit_inspect"):
		close()
		get_viewport().set_input_as_handled()  # stop Movement from freeing mouse

	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# rotate the held object
		inspected_instance.rotate_y(-event.relative.x * 0.01)
		inspected_instance.rotate_x(-event.relative.y * 0.01)

	elif event is InputEventMouseButton and event.pressed:
		# zoom = move along local -Z, clamped
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var z := inspected_instance.position.z + _zoom_step
			if z > -_min_zoom: z = -_min_zoom
			inspected_instance.position.z = z
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var z := inspected_instance.position.z - _zoom_step
			if z < -_max_zoom: z = -_max_zoom
			inspected_instance.position.z = z

# ---- Helpers ----
func _strip_for_inspection(node: Node) -> void:
	if node is CollisionShape3D or node is Area3D or node is StaticBody3D or node is CharacterBody3D:
		node.queue_free()
		return
	if node.get_script() != null:
		node.set_script(null)
	for c in node.get_children():
		_strip_for_inspection(c)

func _center_to_origin(node: Node3D) -> void:
	var aabb := _get_combined_aabb(node)
	if aabb.size == Vector3.ZERO: return
	var offset := -aabb.position - (aabb.size * 0.5)
	node.translate(offset)

func _get_combined_aabb(node: Node) -> AABB:
	var aabb = AABB(); var first = true
	if node is MeshInstance3D:
		aabb = node.get_aabb(); first = false
	for c in node.get_children():
		var ca := _get_combined_aabb(c)
		if ca.size != Vector3.ZERO:
			if first: aabb = ca; first = false
			else: aabb = aabb.merge(ca)
	return aabb
