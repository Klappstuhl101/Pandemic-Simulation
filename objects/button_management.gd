extends Object

class_name Button_Management

var entities # states + country
var active # active state / country
var mode # StatsMode or ActionMode
var ui_output # ui_output for stats

var previous # previous activated button

func _init(initEntities, initOutput):
	self.entities = initEntities
	self.ui_output = initOutput
	connectButtons()
	previous = entities.get(CONSTANTS.DEU)
	
	
func connectButtons():
	for entity in entities.values():
		print(entity.name)
		match entity.name:
			CONSTANTS.BAW:
				entity.mapButton.connect("toggled", self, "_on_BAW_press")
			CONSTANTS.BAY:
				entity.mapButton.connect("toggled", self, "_on_BAY_press")
			CONSTANTS.BER:
				entity.mapButton.connect("toggled", self, "_on_BER_press")
			CONSTANTS.BRA:
				entity.mapButton.connect("toggled", self, "_on_BRA_press")
			CONSTANTS.BRE:
				entity.mapButton.connect("toggled", self, "_on_BRE_press")
			CONSTANTS.HAM:
				entity.mapButton.connect("toggled", self, "_on_HAM_press")
			CONSTANTS.HES:
				entity.mapButton.connect("toggled", self, "_on_HES_press")
			CONSTANTS.MVP:
				entity.mapButton.connect("toggled", self, "_on_MVP_press")
			CONSTANTS.NIE:
				entity.mapButton.connect("toggled", self, "_on_NIE_press")
			CONSTANTS.NRW:
				entity.mapButton.connect("toggled", self, "_on_NRW_press")
			CONSTANTS.RLP:
				entity.mapButton.connect("toggled", self, "_on_RLP_press")
			CONSTANTS.SAA:
				entity.mapButton.connect("toggled", self, "_on_SAA_press")
			CONSTANTS.SCN:
				entity.mapButton.connect("toggled", self, "_on_SCN_press")
			CONSTANTS.SCA:
				entity.mapButton.connect("toggled", self, "_on_SCA_press")
			CONSTANTS.SLH:
				entity.mapButton.connect("toggled", self, "_on_SLH_press")
			CONSTANTS.THU:
				entity.mapButton.connect("toggled", self, "_on_THU_press")
			CONSTANTS.DEU:
				print("connected Deutschland")
				entity.mapButton.connect("toggled", self, "_on_DEU_press")

func resetAll(exception = ""):
	for entity in entities.values():
		if (entity.name != exception):
			entity.mapButton.pressed = false

func showStats():
#	print(active.name)
	resetAll(active.name)
	ui_output[CONSTANTS.LABEL].text = active.name
	pass

func activate():
	showStats()
#	if previous.name != active.name:
#		previous = active
#		showStats()
#	else:
#		print("else")
#		active = entities.get(CONSTANTS.DEU)
#		previous = active
#		showStats()

func _on_BAW_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.BAW)
		activate()
	else:
		active.mapButton.pressed = true
func _on_BAY_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.BAY)
		activate()
	else:
		active.mapButton.pressed = true
func _on_BER_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.BER)
		activate()
	else:
		active.mapButton.pressed = true
func _on_BRA_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.BRA)
		activate()
	else:
		active.mapButton.pressed = true
func _on_BRE_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.BRE)
		activate()
	else:
		active.mapButton.pressed = true
func _on_HAM_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.HAM)
		activate()
	else:
		active.mapButton.pressed = true
func _on_HES_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.HES)
		activate()
	else:
		active.mapButton.pressed = true
func _on_MVP_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.MVP)
		activate()
	else:
		active.mapButton.pressed = true
func _on_NIE_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.NIE)
		activate()
	else:
		active.mapButton.pressed = true
func _on_NRW_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.NRW)
		activate()
	else:
		active.mapButton.pressed = true
func _on_RLP_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.RLP)
		activate()
	else:
		active.mapButton.pressed = true
func _on_SAA_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.SAA)
		activate()
	else:
		active.mapButton.pressed = true
func _on_SCN_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.SCN)
		activate()
	else:
		active.mapButton.pressed = true
func _on_SCA_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.SCA)
		activate()
	else:
		active.mapButton.pressed = true
func _on_SLH_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.SLH)
		activate()
	else:
		active.mapButton.pressed = true
func _on_THU_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.THU)
		activate()
	else:
		active.mapButton.pressed = true
	
func _on_DEU_press(toggle):
	if toggle:
		active = entities.get(CONSTANTS.DEU)
		activate()
	else:
		active.mapButton.pressed = true

