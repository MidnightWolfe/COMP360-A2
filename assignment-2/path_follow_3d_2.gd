extends PathFollow3D

var first = 0


## To intiate movement of the plane
func _process(delta: float) -> void:
	if first == 0:
		first = 1
		progress = 0.5
	progress += delta
	pass
