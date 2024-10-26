extends Node3D

var roll = 0.0005
var aheadNode3D
var closeNode3D
var thisNode3D
var crossProduct
var a
var b

## Function to get the slope for the plane position
func _process(_delta: float) -> void:

	# Get position of glider, position ahead of glider on path,
	# and a position slightly in front of the glider
	thisNode3D = get_global_position()
	aheadNode3D = %aheadNode.get_global_position()
	closeNode3D = %PathFollow3D3.get_global_position()
	
	# Vector a is a small vector pointing forward from the glider
	# Vector b is a vector from the glider to the ahead point
	a = closeNode3D - thisNode3D
	b = aheadNode3D - thisNode3D
	
	# When b is to the left of a, b cross a will be negative y direction
	# and when b is to the right of a, b cross a will be positive y direction
	# as the angle between them increases, the magnitide of b cross a increases
	crossProduct = b.cross(a)
	
	# Add a scaled b cross a to the z rotation
	# the (1 - abs(rotation.z)) term prevents the rotation from getting to large
	rotation.z += crossProduct.y*0.05*(1 - abs(rotation.z))
	
	# This corrects the gliders roll towards 0 at all times,
	# but the above process outweighs this correction when the turns are sharper
	# In this case the (1 - abs(rotation.z)) term increases the correction
	# when the glider is greatly rolled
	if rotation.z < 0:
		rotation.z +=roll/(1- abs(rotation.z))
	if rotation.z > 0:
		rotation.z -=roll/(1- abs(rotation.z))
	
	pass
