extends Control

@onready var Resume:Button = $VBoxContainer/Resume
@onready var Settings:Button =$VBoxContainer/Settings
@onready var Quit:Button =$"VBoxContainer/Quit Game"

func _ready():
	self.hide()
	Resume.pressed.connect(_on_resume_pressed)
	Settings.pressed.connect(_on_settings_pressed)
	Quit.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	print("resume")
	self.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_settings_pressed():
	print("settings")

func _on_quit_pressed():
	get_tree().quit()
