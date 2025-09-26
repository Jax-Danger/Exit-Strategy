extends Node3D

@onready var digital_clock = $"../digital clock"

@export var level_start_audio: AudioStreamPlayer3D
@export var level_halfway_audio: AudioStreamPlayer3D
@export var level_finished_audio:AudioStreamPlayer3D

func _ready() -> void:
	digital_clock.puzzle_solved.connect(puzzle_solved)
	digital_clock.puzzle_halfway.connect(puzzle_halfway)
	level_start_audio.play()

func puzzle_solved():
	print("puzzle solved")
	level_finished_audio.play()

func puzzle_halfway():
	print("Puzzle halfway point")
