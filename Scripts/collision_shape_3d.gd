extends Node3D

var isAllowed = false
@export var area: Area3D
func _ready():
	self.body_entered.connect(on_body_entered)
	print("collision body entered should be connected to _entered()")

func on_body_entered(body: Node3D):
	if body.is_in_group("player"):
		print('entered')
		var loadScene = load("res://Scenes/loading_screen.tscn")
		get_tree().change_scene_to_packed(loadScene)
		LoadScreen.sceneName = "res://Scenes/End.tscn"
