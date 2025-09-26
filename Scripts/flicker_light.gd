extends OmniLight3D
# Works on OmniLight3D, SpotLight3D, etc.

var _original_enabled: bool
var _flicker_count: int = 0
var _flickering: bool = false


func _ready() -> void:
	_original_enabled = visible


# Call this function from your Interactable:
#   light_node.start_flicker(0.2, 6)
func start_flicker(flicker_speed: float, flicker_amount: int) -> void:
	print("starting flicker")
	if _flickering:
		print("already flickering.")
		return
	_flickering = true
	_flicker_count = 0
	_do_flicker(flicker_speed, flicker_amount)
	#$Flickeringlight.play()

func _do_flicker(flicker_speed: float, flicker_amount: int) -> void:
	print("doing flicker")
	if _flicker_count >= flicker_amount:
		visible = _original_enabled
		_flickering = false
		print("finished flickering")
		return

	visible = not visible
	_flicker_count += 1

	await get_tree().create_timer(flicker_speed).timeout
	_do_flicker(flicker_speed, flicker_amount)
	
	
	print("flicker repeat")
