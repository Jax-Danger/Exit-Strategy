extends Control
class_name Main_Menu

@onready var start_button = $MenuContainer/StartButton
@onready var continue_button = $MenuContainer/ContinueButton
@onready var settings_button = $MenuContainer/SettingsButton
@onready var quit_button = $MenuContainer/QuitButton
@onready var ambient_audio = $AmbientAudio


func _ready():
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	

func _on_start_pressed():
	var loadScene = load("res://Scenes/loading_screen.tscn")
	get_tree().change_scene_to_packed(loadScene)
	LoadScreen.sceneName = "res://Scenes/Lobby.tscn"
	

func _on_continue_pressed():
	# TODO: Load"res://Scenes/Lobby.tscn" save system
	print("Continue pressed")

func _on_settings_pressed():
	# TODO: Show settings menu
	print("Settings pressed")

func _on_quit_pressed():
	get_tree().quit()
