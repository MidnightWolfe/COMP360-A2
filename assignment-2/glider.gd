extends Node3D
#var path = get_parent().get_parent()
var roll_intensity = 1
var hold = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#path.curve
	hold +=1
	if hold == 20:
		hold=0
		#print("x pos "+str(get_global_position().x))
	#get_parent.progress += 1
	pass
