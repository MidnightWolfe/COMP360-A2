extends PathFollow3D

var first = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if first == 0:
		first = 1
		progress = 0.1
	progress += delta
	pass
