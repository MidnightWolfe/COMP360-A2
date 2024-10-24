# generated with Gemini free version
# 2024 Jul 13
# minimal bugs generated, and only the type declaration of `data` member had error

#From the lecture

class_name Matrix

var rows : int
var cols : int
var data : Array

func _init(rs, cs):
	self.rows = rs
	self.cols = cs
	data = []
	for i in range(rows):
		data.append([])
		for j in range(cols):
			data[i].append(0.0)

func set_value(row, col, value):
	data[row][col] = value

func get_value(row, col):
	return data[row][col]

func set_data(new_data):
	# Check if the provided data has the correct dimensions
	if new_data.size() != rows or new_data[0].size() != cols:
		print("ERROR: Incorrect data dimensions for set_data")
		return

	# Copy the data
	data = []
	for row in new_data:
		data.append(row.slice(0, row.size(), true))  # Create a copy of the row to avoid modifying the original

func multiply(other : Matrix):
	if self.cols != other.rows:
		push_error("Matrix dimensions mismatch for multiplication")
		return null
	
	var result = Matrix.new(self.rows, other.cols)
	for i in range(self.rows):
		for j in range(other.cols):
			var sum: Variant
			var a = get_value(i, 0)
			var b = other.get_value(0, j)
#			print(str(a) + " " + str(b))
			if (a is float or a is int) and (b is float or b is int):
#				print("sum is float for row " + str(i) + " and col " + str(j))
				sum = 0.0
			else:
#				print("sum is Vector2 for row " + str(i) + " and col " + str(j))
				sum = Vector2(0, 0)
			for k in range(self.cols):
#				print("A[" + str(i) + "][" + str(k) + "] = " + str(data[i][k]))
#				print("B[" + str(k) + "][" + str(j) + "] = " + str(other.data[k][j]))
				sum += self.data[i][k] * other.data[k][j]
			result.data[i][j] = sum
	return result

func _to_string():
	var message = ""
	for row in data:
		message += "["
		for col in row:
			message += str(col) + ", "
		message = message.substr(0, message.length() - 2)  # Remove trailing ", "
		message += "]\n"
	return message.substr(0, message.length() - 1)  # Remove trailing newline
