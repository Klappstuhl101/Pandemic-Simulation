# Class for all the federal states of germany.
extends Node

class_name State

#const LABEL = "Label"
#
#const BAW = "Baden-Württemberg"
#const BAY = "Bayern"
#const BER = "Berlin"
#const BRA = "Brandenburg"
#const BRE = "Bremen"
#const HAM = "Hamburg"
#const HES = "Hessen"
#const MVP = "Mecklenburg-Vorpommern"
#const NIE = "Niedersachsen"
#const NRW = "Nordrhein-Westfalen"
#const RLP = "Rheinland-Pfalz"
#const SAA = "Saarland"
#const SCN = "Sachsen"
#const SCA = "Sachsen-Anhalt"
#const SLH = "Schleswig-Holstein"
#const THU = "Thüringen"

#var name
var population
var mapButton
var ui_output

func _init(initName, initPopulation, initButton, initOutput):
	self.name = initName
	self.population = initPopulation
	self.mapButton = initButton
	self.ui_output = initOutput
	
	
	var image = Image.new()
	image.load("res://resources/map/" + name + ".png")
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	mapButton.toggle_mode = true
#	mapButton.connect("pressed", self, "_on_mapButton_pressed")
	

func _on_mapButton_pressed():
	if mapButton.pressed:
		showStats()


func showStats():
	ui_output[Constants.LABEL].text = name
