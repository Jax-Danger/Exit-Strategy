extends Control
class_name LoadScreen

var progress = []
static var sceneName: String
var scene_load_status = 0

func _ready():
	#sceneName = "res://Scenes/Lobby.tscn"
	print("_ready: loading threaded request ", sceneName)
	ResourceLoader.load_threaded_request(sceneName)
	
func _process(delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
	$countDown.text = "Loading.. " +str(floor(progress[0]*100)) + "%"
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(sceneName)
		get_tree().change_scene_to_packed(newScene)
