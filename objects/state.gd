# Class for all the federal states of germany.
extends Object

class_name State

var name
var population
var mapButton
var ui_output

func _init(initName, initPopulation, initButton, initOutput):
	self.name = initName
	self.population = initPopulation
	self.mapButton = initButton
#	self.ui_output = initOutput
	
	
	var image = Image.new()
	image.load("res://resources/map/" + name + ".png")
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	mapButton.toggle_mode = true
#	mapButton.connect("pressed", self, "_on_mapButton_pressed")
