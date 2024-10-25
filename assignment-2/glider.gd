extends Node3D

var roll = 0.01
var hold = 0
var aheadNode3D
var closeNode3D
var thisNode3D
var lengthAhead
var lhold
var slopeFar
var slopeClose

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	thisNode3D = get_global_position()
	aheadNode3D = %aheadNode.get_global_position()
	closeNode3D = %PathFollow3D3.get_global_position()
	slopeFar = ((aheadNode3D.z - thisNode3D.z)/(aheadNode3D.x - thisNode3D.x))+0.5
	slopeClose = ((closeNode3D.z - thisNode3D.z)/(closeNode3D.x - thisNode3D.x))+0.5
	hold +=1
	
	if hold == 10:
		if int(slopeFar) > int(slopeClose):
			rotation.z += roll
		if int(slopeFar) < int(slopeClose):
			rotation.z -= roll
		if int(slopeFar) == int(slopeClose):
			if rotation.z < 0:
				rotation.z +=roll
			if rotation.z > 0:
				rotation.z -=roll
		hold=0
		print("slope Far: "+str(int(slopeFar)))
		print("slope Close: "+str(int(slopeClose)))
	pass
