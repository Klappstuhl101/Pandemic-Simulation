extends Node

class_name Button_Management

var entities

func _init(initEntities):
	self.entities = initEntities
	
	
func connectButtons():
	for entity in entities:
		entity.mapButton.connect("pressed", self, "_on_button_press")

func resetAll(exception = ""):
	for entity in entities:
		if (entity.name != exception):
			entity.mapButton.pressed = false
		

func _on_button_press():
	print("Hallo")
	print(name)
	pass
