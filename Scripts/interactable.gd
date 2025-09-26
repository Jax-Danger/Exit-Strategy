extends Node3D
class_name InteractableObject

signal show_thought(text:String)
signal interacted(node :InteractableObject)

@export_category("General Settings")
@export var action_name: StringName = &"interact"
@export var interact_label: String = ""
@export_category("Events")
@export_group("Events", "events")
enum events_RepeatMode { REPEATABLE, ONCE_ONLY }
@export var events_repeat_mode: events_RepeatMode = events_RepeatMode.REPEATABLE
@export_multiline var events_first_thought: String = ""
@export_multiline var events_repeat_thought: String = ""
# --- Events system ---
@export var events: Array[EventResource]

@export_category("More")
@export_group("Inspection Settings", "inspect_")
@export var inspect_enabled:bool = false
@export var inspect_action: StringName = &"inspect"
@export var inspect_label: String = ""

@export var inspect_spawn_distance: float = 0.75
@export var inspect_zoom_step: float = 0.1
@export var inspect_min_zoom: float = 0.3
@export var inspect_max_zoom: float = 2.0
@export var inspect_scale: float = 2.5

@export_multiline var inspect_description: String = ""

@export_group("Optional", "optional") # optional_audio and animation
@export var optional_audio: AudioStreamPlayer3D
@export var optional_audio_delay: float = 0.0 # wait before playing sound
@export var optional_outer_area: Area3D
@export var optional_outer_icon: Sprite3D
@export var optional_inner_area: Area3D
@export var optional_inner_icon: Sprite3D


var has_interacted: bool = false
var has_played: bool = false

func can_inspect() -> bool:
	return inspect_enabled

func _ready() -> void:
	# Start hidden
	if optional_outer_icon:
		optional_outer_icon.visible = false
	if optional_inner_icon:
		optional_inner_icon.visible = false
	
	
	# Connect area signals
	if optional_outer_area:
		optional_outer_area.body_entered.connect(_on_outer_enter)
		optional_outer_area.body_exited.connect(_on_outer_exit)

	if optional_inner_area:
		optional_inner_area.body_entered.connect(_on_inner_enter)
		optional_inner_area.body_exited.connect(_on_inner_exit)


# Trigger Areas
func _on_outer_enter(body: Node) -> void:
	if body.is_in_group("player"):
		optional_outer_icon.visible = true

func _on_outer_exit(body: Node) -> void:
	if body.is_in_group("player"):
		optional_outer_icon.visible = false

func _on_inner_enter(body: Node) -> void:
	if body.is_in_group("player"):
		# Hide outer, show inner
		optional_outer_icon.visible = false
		optional_inner_icon.visible = true

func _on_inner_exit(body: Node) -> void:
	if body.is_in_group("player"):
		# Back to outer, hide inner
		optional_inner_icon.visible = false
		optional_outer_icon.visible = true

func interact() -> void:
	# Thinking text
	if events_repeat_mode == events_RepeatMode.ONCE_ONLY and has_interacted:
		if events_repeat_thought.strip_edges() != "":
			emit_signal("show_thought", events_repeat_thought)
	else:
		if events_first_thought.strip_edges() != "":
			emit_signal("show_thought", events_first_thought)

	has_interacted = true
		
	if optional_audio and optional_audio.stream:
		if optional_audio_delay > 0.0:
			get_tree().create_timer(optional_audio_delay).timeout.connect(func():
				optional_audio.stop()
				optional_audio.play()
			)
		else:
			var temp := AudioStreamPlayer3D.new()
			temp.max_db = -4
			temp.stream = optional_audio.stream
			temp.transform = optional_audio.global_transform
			get_tree().current_scene.add_child(temp)
			temp.finished.connect(temp.queue_free)
			temp.play()


	# Events
	for e in events:
		var node = get_node_or_null(e.target)
		if node and node.has_method(e.method):
			if e.delay > 0.0:
				get_tree().create_timer(e.delay).timeout.connect(func():
					node.callv(e.method, e.args)
				)
			else:
				node.callv(e.method, e.args)

	# Emit signal (alternative hook for puzzles)
	emit_signal("interacted", self)

func get_prompt_text() -> String:
	if inspect_enabled:
		if inspect_label != "":
			return inspect_label
		else:
			return "Press E to interact / F to inspect"
	else:
		if interact_label != "":
			return interact_label
		else: 
			return "Press E to interact"
