extends Node

class_name Button_Management

var entities
var active
var mode
var ui_output

func _init(initEntities, initOutput):
	self.entities = initEntities
	self.ui_output = initOutput
	print("Button init")
	connectButtons()
	
	
func connectButtons():
	for entity in entities.values():
		print(entity.name)
		match entity.name:
			Constants.BAW:
				entity.mapButton.connect("toggled", self, "_on_BAW_press")
			Constants.BAY:
				entity.mapButton.connect("toggled", self, "_on_BAY_press")
			Constants.BER:
				entity.mapButton.connect("toggled", self, "_on_BER_press")
			Constants.BRA:
				entity.mapButton.connect("toggled", self, "_on_BRA_press")
			Constants.BRE:
				entity.mapButton.connect("toggled", self, "_on_BRE_press")
			Constants.HAM:
				entity.mapButton.connect("toggled", self, "_on_HAM_press")
			Constants.HES:
				entity.mapButton.connect("toggled", self, "_on_HES_press")
			Constants.MVP:
				entity.mapButton.connect("toggled", self, "_on_MVP_press")
			Constants.NIE:
				entity.mapButton.connect("toggled", self, "_on_NIE_press")
			Constants.NRW:
				entity.mapButton.connect("toggled", self, "_on_NRW_press")
			Constants.RLP:
				entity.mapButton.connect("toggled", self, "_on_RLP_press")
			Constants.SAA:
				entity.mapButton.connect("toggled", self, "_on_SAA_press")
			Constants.SCN:
				entity.mapButton.connect("toggled", self, "_on_SCN_press")
			Constants.SCA:
				entity.mapButton.connect("toggled", self, "_on_SCA_press")
			Constants.SLH:
				entity.mapButton.connect("toggled", self, "_on_SLH_press")
			Constants.THU:
				entity.mapButton.connect("toggled", self, "_on_THU_press")
			Constants.DEU:
				entity.mapButton.connect("toggled", self, "on_DEU_press")

func resetAll(exception = ""):
	for entity in entities:
		if (entity.name != exception):
			entity.mapButton.toggled = false

func showStats():
	pass

func activate()

func _on_BAW_press(_toggle):
	active = entities.get(Constants.BAW)
	print(entities.get(Constants.BAW).name)
func _on_BAY_press(_toggle):
	active = entities.get(Constants.BAY)
func _on_BER_press(_toggle):
	active = entities.get(Constants.BER)
func _on_BRA_press(_toggle):
	active = entities.get(Constants.BRA)
func _on_BRE_press(_toggle):
	active = entities.get(Constants.BRE)
func _on_HAM_press(_toggle):
	active = entities.get(Constants.HAM)
func _on_HES_press(_toggle):
	active = entities.get(Constants.HES)
func _on_MVP_press(_toggle):
	active = entities.get(Constants.MVP)
func _on_NIE_press(_toggle):
	active = entities.get(Constants.NIE)
func _on_NRW_press(_toggle):
	active = entities.get(Constants.NRW)
func _on_RLP_press(_toggle):
	active = entities.get(Constants.RLP)
func _on_SAA_press(_toggle):
	active = entities.get(Constants.SAA)
func _on_SCN_press(_toggle):
	active = entities.get(Constants.SCN)
func _on_SCA_press(_toggle):
	active = entities.get(Constants.SCA)
func _on_SLH_press(_toggle):
	active = entities.get(Constants.SLH)
func _on_THU_press(_toggle):
	active = entities.get(Constants.THU)
	
func _on_DEU_press(_toggle):
	active = entities.get(Constants.DEU)

