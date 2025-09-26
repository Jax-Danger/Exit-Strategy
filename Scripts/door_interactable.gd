extends InteractableObject
class_name DoorInteractable

@export var anim_player: AnimationPlayer
@export var open_animation: String = "open"
@export var open_speed: float = 1.0
@export var close_animation: String = "close"
@export var close_speed: float = 1.0
@export var locked: bool = false
@onready var digital_clock = $"../digital clock"
@export var optional_unlock_audio: AudioStreamPlayer3D
var is_open: bool = false


func _ready() -> void:
	super._ready()
	digital_clock.puzzle_solved.connect(self.unlock)


func interact():
	print("Checking if door is unlocked.")
	if locked or is_open: return
	print("Unlocked! Opening the door.")
	anim_player.play(open_animation, -1, open_speed, false)
	optional_audio.play()
	is_open = true

func unlock() -> void:
	locked = false
	optional_unlock_audio.play()
	
