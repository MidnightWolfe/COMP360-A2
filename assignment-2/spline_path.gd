extends Path3D
#This will require a matrix script to work, current one is from the lab /class and will need adjusted
#Matrix class and bresenham_line function from class lecture, we will need to change them
#Currently have them in so we can get this working


#Currently does not display above the landscape only displays as a 2D image
#2D Image is currently in the center of the screen above the landscape

##The points for the hilbert curve
var pointsCurve = _hilbertPoints(3, 200) #Size may need changed

##The selected points from the hilbert curve, used to generate the spline
var points = [ 
	pointsCurve[0], #Start and end points repeated to make a cycle
	pointsCurve[0],
	pointsCurve[3],
	pointsCurve[6],
	pointsCurve[9],
	pointsCurve[12],
	pointsCurve[14],
	pointsCurve[32],
	pointsCurve[16],
	pointsCurve[0],
	pointsCurve[0]

]

func _ready() -> void:
	catmull_rom()
	#print(pointsCurve) #Testing
	#print(points) #Testing
	pass

##The math / matrix for the cardinal spline
func cardinal_spline(res, s, p): #p is for the altered points, res is the resolution, s is the scale
	var pts = []
	for k in range(res+1):
		var t = float(k) / res
		var PolyT = Matrix.new(1, 4)
		PolyT.set_data( #Polynominal for the value t
			[ [ 1, t, t*t, t*t*t ] ]
		)
		var CharMtx = Matrix.new(4, 4)
		CharMtx.set_data(#The matrix information for cardinal splines
			[
				[0, 1, 0, 0],
				[-s, 0, s, 0],
				[2*s, s-3, 3-2*s, -s],
				[-s, 2-s, s-2, s]
			]
		)
		var PtMtx = Matrix.new(4, 1)
		PtMtx.set_data(p)
		var R = PolyT.multiply(CharMtx).multiply(PtMtx)
		pts.append(R.get_value(0, 0))
	return pts
	
	
	
##Generating the cardinal spline using points from the hilbert curve
##Currently based on our lab / lecture code, but will change it as needed
func catmull_rom():
	var s = 0.5 #Scale of the matrix, 0.5 makes this a catmull-rom, which is based on cardinal splines
	var res = 40
	var width = 200 #width of the 2D image
	var height = 200 #Height of the 2D Image
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	#image.fill(Color.BLACK) #Showing just the spline
	
	#The k values of generating a spline
	for k in range(points.size()-3):
		var pts: Array;
		pts = cardinal_spline(
			res, s,
			[
				[points[k]],
				[points[k+1]],
				[points[k+2]],
				[points[k+3]]
			
			]
		)
		
		#This loop shows the cardinal / catmull-rom spline
		#Place holder for later, or this needs adjusted for the pathing over the landscape
		for i in range(pts.size()-1):
			bresenham_line(image, Color.RED, pts[i].x, pts[i].y, pts[i+1].x, pts[i+1].y )
			
	var texture = ImageTexture.create_from_image(image)
	var sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = texture
	
	#The sprite things below will need changed
	sprite.position = Vector2(width + 450, height + 100) #This will need changed
	sprite.scale = Vector2(3.0,3.0) #Play around with the scaling
	
	add_child(sprite)
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
	var points : PackedVector2Array
	
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
		points.append(pt)
	return points



#May need to adjust this function as needed, from our slides
#Adjust this and Matrix class to what we need
# bresenham_line Generated by Gemini
# 2024 Jul 13
func bresenham_line(image, c, fx0, fy0, fx1, fy1):
	var x1 = floor(fx0)
	var x2 = floor(fx1)
	var y1 = floor(fy0)
	var y2 = floor(fy1)
	var dx = abs(x2 - x1)
	var dy = -abs(y2 - y1)
	var sx = 1 if x1 < x2 else - 1
	var sy = 1 if y1 < y2 else - 1
	var err = dx + dy
	
	while true:
		image.set_pixel(floor(x1), floor(y1), c) # edited
		if x1 == x2 and y1 == y2:
			break

		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x1 += sx
		if e2 <= dx:
			err += dx
			y1 += sy
