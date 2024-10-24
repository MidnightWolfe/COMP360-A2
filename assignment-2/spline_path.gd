extends Path3D
##NOTE: Matrix class is from our lectures / labs and is only slightly changed

###Global variables
var pointsCurve = _hilbertPoints(3, 200) #The points of the Hilbert Curve
var splinePoints = [] #Global variable for the points for the cardinal / catmull-rom spline

##Static information for the spline / spline point creation
var resolution = 100 #The resoltion of the spline
var splineScale = 0.5 #Scale of the spline, 0.5 makes this a catmull-rom, which is based on cardinal splines

##Static variables for spline image generation
var splineImage = Image.create(200, 200, false, Image.FORMAT_RGBA8) #Used to create the image of the spline

##Positioning variables for the image as well as the path, but SINCE the the path and the image have different origins you;ll have to also tune the path3D in create3Dpathinworld func
var pathXOffset = 15	
var pathYOffset = 1.8
var pathZOffset = 10
	
##The start and end points of the slice for the Hilbert Curve
var start =  2 #start of the slice
var end = 30 #End of the slice
var points = pointsCurve.slice(start,end) #Random section of points from the Hilbert curve

func _ready() -> void:
	##Making the points of the spline loop
	points.append(pointsCurve[start]) #Calling start twice to make the spline loop due to ghost points
	points.append(pointsCurve[start])
	points.insert(0, pointsCurve[start])
	
	##Calling the spline
	catmullRom()
	#print(pointsCurve) #Testing
	#print(points) #Testing
	
	##Create the 3D path now that the spline is made
	createPath3DInWorld()
	pass

##The function to get the points of the spline based on the projected points and the characteristics of the cardinal spline
func cardinalSpline(projectedPoints):
	##Getting the points after they are altered by the characterisitcs of the cardinal spline
	##and multiplying them by the projected points from the knots
	for i in range(resolution+1):
		var t = float(i) / resolution #The t value that is generated from the knots 
		##A 1 by 4 matrix to represent the polynominal of t
		var polynominalT = Matrix.new(1, 4)
		polynominalT.set_data(
			[ [ 1, t, t*t, t*t*t ] ]
		)
		##The matrix representing the cardinal splines characteristics
		var splineMatrix = Matrix.new(4, 4)
		splineMatrix.set_data(#The matrix information for cardinal splines
			[
				[0, 1, 0, 0],
				[-splineScale, 0, splineScale, 0],
				[2*splineScale, splineScale-3, 3-2*splineScale, -splineScale],
				[-splineScale, 2-splineScale, splineScale-2, splineScale]
			]
		)
		var projectedMatrix = Matrix.new(4, 1)
		projectedMatrix.set_data(projectedPoints) #The 4 by 1 matrix for the projected points 
		
		##The multiplication to get the matrix for the projected points * the spline characteristics
		var multiplyResult = polynominalT.multiply(splineMatrix).multiply(projectedMatrix) #The new matrix
		splinePoints.append(multiplyResult.get_value(0, 0)) #The new points after the multiplication
	return splinePoints
	
	
	
##Generating the cardinal spline using points from the hilbert curve
func catmullRom():
	##The loop for getting each projected points of the spline (based on knots: k)
	##This also allows for the curve in the spline, rather than right angles
	for k in range(points.size()-3):
		splinePoints = cardinalSpline(
			[
				[points[k]],
				[points[k+1]],
				[points[k+2]],
				[points[k+3]]
			
			]
		)
		##Loop to draw / generate the line of the spline based on the points
		for i in range(splinePoints.size()-1):
			bresenhamLine(splinePoints[i].x, splinePoints[i].y, splinePoints[i+1].x, splinePoints[i+1].y )
	
	##Generating the 2D image version of the spline to be used for the 3D image path	
	var splineTexture = ImageTexture.create_from_image(splineImage)
	var splineSprite = Sprite2D.new()
	splineSprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	splineSprite.texture = splineTexture
	
	#create an in world image of the spline
	createImageInWorld(splineSprite)
	
	pass

##Function to get the points from a Hilbert space-filling curve
func _hilbertPoints(level : int, size : int) -> PackedVector2Array:
	
	## Number of times the space is being divided
	var divisions = pow(2, level)
	
	## Total number of points
	var numOfPoints = divisions * divisions
	
	## This is the base case for a level 1 Hilbert curve
	var basePoints = PackedVector2Array([
		Vector2(0,1),
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1)
	])
	
	## The array we will be adding points to
	var pointsHilbert : PackedVector2Array
	
	## Loop over each point using it's index to determine its location
	for i in int(numOfPoints):
		
		## Using bit masking to look at the first two bits to determine it's base case
		var index = i & 3
		var pt = basePoints[index]
		
		## Now look at the next two bits to determine the next quadrant it will be in
		## and add the length respective to that quadrant
		## also, if a point lies in the bottom right quadrant, it needs its x and y
		## coordinates swapped, and if it lies in the bottom left quandrant it needs
		## it's x and y coordinates swapped relative to that quadrant
		## -------
		## |01|10|
		## |00|11|
		## -------
		## Above it how the bits correspond to what quadrant it lies in
		for j in range(1, level):
			
			## Shift bits
			i = i >> 2
			
			## Mask to look at the first two
			index = i & 3
			
			## Length relative to level of curve
			var length = pow(2,j)
			
			## Bottom left quadrant
			if index == 0:
				var temp = length - 1 - pt.x
				pt.x = length - 1 - pt.y
				pt.y = temp
				pt += Vector2(0, length)
			
			## Top left quadrant
			else: if index == 1:
				pass
			
			## Top right quadrant
			else: if index == 2:
				pt += Vector2(length, 0)
			
			## Bottom right quadrant
			else: if index == 3:
				var temp = pt.x
				pt.x = pt.y
				pt.y = temp
				pt += Vector2(length, length)
		
		## This scales the points up to a given size
		## and offsets them to be centered
		var scaling = size/divisions
		pt *= scaling
		pt += Vector2(scaling/2, scaling/2)
		pointsHilbert.append(pt)
	return pointsHilbert



##Based (though altered) on lecture / lab code generated by Gemini and the actual bresenham algorithm
func bresenhamLine(funcX0, funcY0, funcX1, funcY1):
	var x1 = floor(funcX0)
	var x2 = floor(funcX1)
	var y1 = floor(funcY0)
	var y2 = floor(funcY1)
	var differenceX = abs(x2 - x1)
	var differenceY = -abs(y2 - y1)
	var slopeX = -1 
	if x1 < x2:
		slopeX = 1 
	var slopeY = -1 
	if y1 < y2:
		slopeY = 1
	var error = differenceX + differenceY
	
	##Plotting the points for the line
	while true:
		splineImage.set_pixel(floor(x1), floor(y1), Color.RED)
		if x1 == x2 and y1 == y2:
			break
		var error2 = 2 * error
		if error2 >= differenceY:
			error += differenceY
			x1 += slopeX
		if error2 <= differenceX:
			error += differenceX
			y1 += slopeY
			
##This takes the image made by catMullRom and turns it into a Sprite 3D then positions it so it will be visible in the world
func createImageInWorld(image: Sprite2D):
	
	
	#Find pathimage and add image to it is the overarching goal here
	#We could totally generate this on the fly instead of having a pre done node
	var path_image_node = get_node("../PathImage")
	
	#~~~~~~~~ convert Sprite2D to 3D ~~~~~~~~ 
	
	#Grab the texture from the image passed to the function
	var textureFromSprite2D = image.texture
	if (textureFromSprite2D == null):
		print("Error, unable to grab texture from 2DSprite in CreateImageInWorld.")
		return
		
	#We make a new 3D sprite which we will paste the 2D sprit's texture onto
	var new3DSprite = Sprite3D.new()
	#Set up the 3D sprite with the new texture
	new3DSprite.texture = textureFromSprite2D

	
	#Rotate the image. Thanks to the info from today's class to make that easy
	var th = PI/2
	new3DSprite.transform.basis = Basis.IDENTITY.rotated(Vector3(-1, 0, 0), th)

	#Add the 3D sprite to the Scene
	path_image_node.add_child(new3DSprite)
	
	#Set the 3DSprite's default position based on the offsets (Global)
	new3DSprite.transform.origin = Vector3(pathXOffset,pathYOffset,pathZOffset)
	
	#Scale if wanted
	new3DSprite.scale = Vector3(12.0,8.0,1)
	
	
	pass
	
	
##Create a path3D from the points used to generate the image, these points are taken directly from the pts[]. I found this easier than tracing it as my image only exists in runtime
func createPath3DInWorld():
	#The points are way too spread apart for the size of our landscape this will shrink it down and make the path3D be scalable
	var shrinkFactorX = 8.2
	var shrinkFactorZ = 12.4
	
	#Positioning variables for the actual path3D
	var path3DXOffset = 2.9
	var path3DZOffset = 2
	
	#The points of the curve are already global under pts[] so lets use that
	#First find the path3D in scene which if this script is set up as part of a path3D we are by default which means we don't need a refrence to it
	
	for point in splinePoints:
		#Convert vector2 to vector 3 while also adjusting the positioning of the points to fit the image we generated
		#NOTE This is a manual step, you must adjust the values that the offsets are to move the path3D moving the image has no interaction with the path
		var pointX = point.x/shrinkFactorX + path3DXOffset
		@warning_ignore("integer_division")
		#Y becomes Z due to rotation of the plane
		var pointY = point.y/shrinkFactorZ + path3DZOffset
		var pointIn3DSpace = Vector3(pointX, pathYOffset, pointY)
		#Add the now modified point to the curve
		self.curve.add_point(pointIn3DSpace)
	#Show the path with objects for testing purposes
	debugShowPath(self.curve)
	
	
	pass
	
	
	##Shows the location of the actual curve 3D which is normally transparent
func debugShowPath(splineCurve: Curve3D):
	#for each point in curve
	for i in range(splineCurve.get_point_count()):
		#Get the position of the point
		var positionOfPoint = splineCurve.get_point_position(i)
		#create a small cube at that point
		var testObj = MeshInstance3D.new()
		var testObjMesh = BoxMesh.new()
		testObjMesh.size = Vector3(0.05,0.05,0.05)
		testObj.mesh = testObjMesh
		testObj.transform.origin = positionOfPoint
		#Add the cube
		add_child(testObj)
	pass
