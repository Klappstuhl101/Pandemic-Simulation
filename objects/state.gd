# Class for all the federal states of germany.

class_name State

var name
var population
var mapButton

func _init(initName, initPopulation, initButton):
	self.name = initName
	self.population = initPopulation
	self.mapButton = initButton
	
	
	# Create Bitmap for Clickmask
	var image = Image.new()
	image.load("res://resources/map/" + name + ".png")
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	

