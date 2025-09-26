extends CanvasLayer

@onready var crosshair: TextureRect = $Crosshair
@onready var prompt_label: Label = $PromptLabel
@onready var thought_label: Label = $ThoughtLabel

func _ready() -> void:
	crosshair.visible = false
	prompt_label.visible = false
	thought_label.visible = false

# --- Prompt (Press E) ---
func show_prompt(text: String) -> void:
	crosshair.visible = true
	prompt_label.text = text
	prompt_label.visible = true

func hide_prompt() -> void:
	crosshair.visible = false
	prompt_label.visible = false

# --- Thought (inner monologue) ---
func show_thought(text: String, duration: float = 3.0) -> void:
	thought_label.text = text
	thought_label.visible = true
	var t := get_tree().create_timer(duration)
	await t.timeout
	thought_label.visible = false
