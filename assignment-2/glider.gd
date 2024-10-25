extends Node3D

var roll = 0.01
var hold = 0
var aheadNode3D
var closeNode3D
var thisNode3D
var slopeFar
var slopeClose

## Function to get the slope for the plane position
func _process(_delta: float) -> void:
	#grabs the position of the plane and two extra nodes to calculate the slope of the lines 
	#one is close and the other one is farther away. the close one aproximates the direction of the plane
	#where the far one aproximates the tragectory of the turn.
	thisNode3D = get_global_position()
	aheadNode3D = %aheadNode.get_global_position()
	closeNode3D = %PathFollow3D3.get_global_position()
	#calculates the slope of the two lines coming out of the plane. adds a small amount to keep is mostly above 1
	slopeFar = ((aheadNode3D.z - thisNode3D.z)/(aheadNode3D.x - thisNode3D.x))+0.8 
	slopeClose = ((closeNode3D.z - thisNode3D.z)/(closeNode3D.x - thisNode3D.x))+0.8
	hold +=1
	#every 8 points it calculates if the farther slope is greater less than or equal too zero and rotates the plan acordingly
	if hold == 8:
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
		#print("slope Far: "+str(int(slopeFar)))
		#print("slope Close: "+str(int(slopeClose)))
	pass
