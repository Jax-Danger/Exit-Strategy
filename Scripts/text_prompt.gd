extends MeshInstance3D

var cam: Camera3D

func _ready() -> void:
	# get the main active camera in the scene
	cam = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	if cam:
		var target = cam.global_transform.origin
		look_at(Vector3(target.x, global_transform.origin.y, target.z), Vector3.UP)
