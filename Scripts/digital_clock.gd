extends Node3D
signal puzzle_solved
signal puzzle_halfway

var timer_active = false
var total_time = 285 #300
var time_left:float = 0.0

@onready var time_label:Label3D = $Mesh/Label3D
@onready var desk_bell = $"../desk_bell"
@onready var player = $"../Player"

func _ready():
	desk_bell.bell_pressed.connect(self.check_for_five)

	if time_label:
		time_left = total_time
		update_timer_display()
	start_timer()

func start_timer(): timer_active = true
func stop_timer(): timer_active = false

func update_timer_display():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func get_time_left():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	return [minutes, seconds]
	

func _process(delta):
	if timer_active:
		time_left -= delta
		var time_string = time_label.text
		
		if time_string.contains("2:00"):
			time_label.modulate = "f10000"
			emit_signal("puzzle_halfway")
		if time_string.contains("0:00"):
			stop_timer()
			print("time's out")
			var loadScene = load("res://Scenes/loading_screen.tscn")
			get_tree().change_scene_to_packed(loadScene)
			LoadScreen.sceneName = "res://Scenes/End.tscn"
		if time_string.contains(":2"):
			time_label.modulate = "00ffff"
		else:
			time_label.modulate = "ffffff"
			
			
		
		update_timer_display()

#level 1
func check_for_five():
	if not player.current_level == 1: return
	print("Checking if the time has a 25 in it.")
	# Convert the remaining time to a string (e.g., "04:55")
	var time_string = time_label.text
	
	# Check if the string contains the character "5"
	if time_string.contains("25"):
		print("A 25 is in the time.") # Optional: for debugging
		# The puzzle is solved!
		complete_level()
	

func complete_level():
	emit_signal("puzzle_solved")
	stop_timer()
