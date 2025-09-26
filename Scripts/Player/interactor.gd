extends Movement

@export var current_level:int = 1
@export var ray: RayCast3D
@export var max_distance: float = 3.0
@export var ui_path: NodePath # assign crosshair ui in the editor
@onready var ui = get_node(ui_path)

@export var inspection_ui_path: NodePath
@onready var inspection_ui = get_node(inspection_ui_path)

var hovered: Node = null

func _ready() -> void:
	super._ready()
	ray.enabled = true
	ray.target_position = Vector3(0, 0, -max_distance)

func _physics_process(dt: float) -> void:
	super._physics_process(dt)
	
	# Hide crosshair prompt if inspecting
	if inspection_ui.inspected_instance:
		ui.hide_prompt()
		return
	
	ray.force_raycast_update()

	var target: Node = _get_target()
	
	if target != hovered:
		# hide prompt if no target
		if not target: 
			print("no target. Hiding prompt for ", hovered)
			ui.hide_prompt()
		
		# show prompt if valid target
		if target and target.has_method("get_prompt_text"):
			ui.show_prompt(target.get_prompt_text())
		
		#auto-connect thougth signals
		if target and target.has_signal("show_thought"):
			var cb := Callable(ui, "show_thought")
			if not target.is_connected("show_thought", cb):
				target.connect("show_thought", cb)
		
		hovered = target
	# perform interaction
	if hovered and Input.is_action_just_pressed("interact"):
		hovered.interact()
	
	# Inspect if object supports it
	if hovered and Input.is_action_just_pressed("inspect"):
		if hovered is InteractableObject and hovered.can_inspect():
			inspection_ui.open_from_node(hovered, self)  # self = Player

func _get_target() -> Node:
	var hit = ray.get_collider()
	if hit:
		var n = hit as Node
		while n:
			if n.has_method("interact"):
				return n
			n = n.get_parent()
	#print("didn't hit anything")
	return null
