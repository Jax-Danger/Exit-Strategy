extends InteractableObject

signal bell_pressed


func _ready():
	super._ready()

func ring_bell():
	print("emitting signal")
	emit_signal("bell_pressed")
