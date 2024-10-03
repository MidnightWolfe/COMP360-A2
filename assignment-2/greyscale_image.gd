extends Node3D

### Global variables
var landscape = MeshInstance3D.new()    # Mesh for the landscape used to place the FastNoiseLite image.
var surfaceTool = SurfaceTool.new()
var image : Image
var quadsHorizontal : int = 20   # Number of quads to do in the horizontal direction.
var quadsVertical : int = 20   # Number of quads to do in the vertical direction.
static var IMAGE_SIZE_X : int = 201
static var IMAGE_SIZE_Y : int = 201

func _ready() -> void:
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)   # This is the settings for the function.
	var quadCount : Array[int] = [0]   # Make a quad for each spot.
	
	# Creating the Cellular Image:
	# Creates a new "FastNoiseLite" object called "cellNoise" and defines the shape of the object.
	# Then, colours the object - in this case, black and white.
	var cellNoise = FastNoiseLite.new()
	cellNoise.set_noise_type(FastNoiseLite.TYPE_CELLULAR)
	cellNoise.noise_type = 4
	cellNoise.fractal_octaves = 6
	cellNoise.frequency = 0.04
	cellNoise.cellular_jitter = 1
	cellNoise.cellular_distance_function = 2
	cellNoise.cellular_return_type = 2
	var imageNoise = cellNoise.get_seamless_image(IMAGE_SIZE_X, IMAGE_SIZE_Y)
	image = Image.create(IMAGE_SIZE_X, IMAGE_SIZE_Y, false, Image.FORMAT_RGBA8)
	
	for horizonalPlaneX in range (IMAGE_SIZE_X):
		for verticalPlaneY in range(IMAGE_SIZE_Y):
			# Trying to change the black/white ratio in the image and give highlights.
			# Color(r,b,g,a) - r = red, b = blue, g= green, a = alpha
			image.set_pixel(horizonalPlaneX, verticalPlaneY, Color(1.0, 1.0, 1.0, 1.0) * imageNoise.get_pixel(horizonalPlaneX,verticalPlaneY) * imageNoise.get_pixel(horizonalPlaneX,verticalPlaneY))
		
	for i in quadsHorizontal:
		for j in quadsVertical:
			_CreateQuad(Vector3(i,0,j), quadCount, quadsHorizontal, quadsVertical, i, j)
	
	surfaceTool.generate_normals()
	var mesh = surfaceTool.commit()
	landscape.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_texture = ImageTexture.create_from_image(image)
	landscape.set_surface_override_material(0, material)
	add_child(landscape)
	pass

### This function accepts the following parameters:
	### point (a location), 
	### count (for allowing multiple quads), 
	### numHorizontalQuads (number of quads in the horizontal direction), 
	### numVerticalQuads (number of quads in the vertical direction), 
	### horizontalQuadIndex (the current horizontal index of the quad), 
	### and verticalQuadIndex (the current vertical index of the quad).
### All these together allow us to compute which part of the UV to map it to.
func _CreateQuad(
	point: Vector3, 
	count: Array[int],
	numHorizontalQuads: int,
	numVerticalQuads: int,
	horizontalQuadsIndex: int,
	verticalQuadsIndex: int):
		
		# Okay so we need to figure out some stuff to make this work
		# Lets imagine a 2x2, 4 vertices each
		# [0.0,0.0][0.3,0.0]|[0.6,0.0][1.0,0.0]
		# [0.0,0.3][0.3,0.3]|[0.6,0.3][1.0,0.3]
		# ------------------------------------
		# [0.0,0.6][0.3,0.6]|[0.6,0.6][1.0,0.6]
		# [0.0,1.0][0.3,1.0]|[0.6,1.0][1.0,1.0]
		
		# Each of these quads has 4 values, up/down & left/right pairs.
		# The upper values are what percent of the number of horizontal quads (numHorizontalQuads) 
		# or number of Vertical quads (numVerticalQuads) the respective verticalQuadsIndex or horizontalQuadsIndex is
		# The lower values are the values of the upper - 1/numQuadsDirection
		
		# By generating these 4 numbers we can then create a quad with correct UV mapping.
		
	var upperHorizontal = _GenerateUVSlice(true, horizontalQuadsIndex, numHorizontalQuads)
	var lowerHorizontal = _GenerateUVSlice(false, horizontalQuadsIndex, numHorizontalQuads)
	var upperVertical = _GenerateUVSlice(true, verticalQuadsIndex, numVerticalQuads)
	var lowerVertical = _GenerateUVSlice(false, verticalQuadsIndex, numVerticalQuads)
	
	# Here we are setting the values of the quads corners to match the generated values from the _GenerateUVSlice function
	# What is cool about this is it splits the UV map into sections the size of a quad
	# Imagine having a stencil of a square and putting it over an image, by moving the stencil you can show different things
	
	# Added height to the y-axis by using the _GetHeight function. Had to add 1 to the 2-4th passes to get the corners of quadrant as the variable point only stores (0,0)
	
	surfaceTool.set_uv(Vector2(lowerHorizontal,lowerVertical))
	surfaceTool.add_vertex(point + Vector3(0,_GetHeight((point.x),(point.z)),0))
	count[0] += 1
	
	surfaceTool.set_uv(Vector2(upperHorizontal,lowerVertical))
	surfaceTool.add_vertex(point + Vector3(1,_GetHeight((point.x+1),(point.z)),0))
	count[0] += 1
	
	surfaceTool.set_uv(Vector2(upperHorizontal,upperVertical))
	surfaceTool.add_vertex(point + Vector3(1,_GetHeight((point.x+1),(point.z+1)),1))
	count[0] += 1
	
	surfaceTool.set_uv(Vector2(lowerHorizontal,upperVertical))
	surfaceTool.add_vertex(point + Vector3(0,_GetHeight((point.x),(point.z+1)),1))
	count[0] += 1
	
	# Assemble the quad from the vertices.
	surfaceTool.add_index(count[0] - 4)
	surfaceTool.add_index(count[0] - 3)
	surfaceTool.add_index(count[0] - 2)
	
	surfaceTool.add_index(count[0] - 4)
	surfaceTool.add_index(count[0] - 2)
	surfaceTool.add_index(count[0] - 1)

### This function is super cool, it is pretty effective at doing it's job.
### This function accepts the following parameters:
	### isUpperValue (a boolean value that indicates whether to get the upper or lower UV value of the quad),
	### indexOfQuad (the current index of the quad in the direction we're looking at (horizontal or vertical)),
	### sizeOfQuadDirection (the length (count) of quads that make up that direction)
func _GenerateUVSlice(
	isUpperValue: bool, 
	indexOfQuad: int, 
	sizeOfQuadDirection: int) -> float:
		# The upper values are what percent of the number of horizontal quads (numHorizontalQuads) 
		# or number of Vertical quads (numVerticalQuads) the respective verticalQuadsIndex or horizontalQuadsIndex is.
		# The lower values are the values of the upper - 1/numQuadsDirection (notice sizeOfQuadDirection was made 1.0 to convert to float).
		
		# The _GetPercent function is run at index+1 to account for starting index at 0; when starting at 0 the function automatically
		# gives the lower bound as the upperbound due to multiplying by 0. 
		# It's important to note that the _GenerateUVSlice function first computes the upper value then finds the size of a quad to subtract back to get lower
	var value : float = _GetPercent(indexOfQuad+1, sizeOfQuadDirection)
	
	# If the lower value is needed, then do the following to the upper value:
	# 1.0/sizeOfQuadDirection is the portion of 1.0 that represents the quad's directional size
	# So if we have 3 quads each segment works out to 0.33 of 1.0
	if !isUpperValue:
		value = value - (1.0/sizeOfQuadDirection)
	return value

### Simple function to return a percentage as a decimal float between 0.0 and 1.0
func _GetPercent(numerator : float, denominator : float) -> float:
	if denominator == 0:
		return 0.0
	var percent : float = (numerator/denominator)
	return percent

### Returns the height of a pixel, from an image, based on its red channel (r).
### Takes the size of the image and divides it by the number of quadrants being generated to get the correct pixel.
### Multiplies that value by the quardrant, from the _CreateQuad function, to return the proper x,y height relative to the quadrant.
func _GetHeight(x : float,y : float) -> float:
	return image.get_pixel(x * (IMAGE_SIZE_X/quadsHorizontal), y * (IMAGE_SIZE_Y/quadsVertical)).r
