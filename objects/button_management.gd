extends Object

class_name Button_Management

var entities # states + country
var active # active state / country
var mode # StatsMode or ActionMode
var ui_output # ui_output for stats

func _init(initEntities, initOutput):
	self.entities = initEntities
	self.ui_output = initOutput
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
				print("connected Deutschland")
				entity.mapButton.connect("toggled", self, "_on_DEU_press")

func resetAll(exception = ""):
	for entity in entities.values():
		if (entity.name != exception):
			entity.mapButton.pressed = false

func showStats():
#	print(active.name)
	resetAll(active.name)
	ui_output[Constants.LABEL].text = active.name
	pass

func activate():
	showStats()
	pass

func _on_BAW_press(toggle):
	if toggle:
		active = entities.get(Constants.BAW)
		activate()
func _on_BAY_press(toggle):
	if toggle:
		active = entities.get(Constants.BAY)
		activate()
func _on_BER_press(toggle):
	if toggle:
		active = entities.get(Constants.BER)
		activate()
func _on_BRA_press(toggle):
	if toggle:
		active = entities.get(Constants.BRA)
		activate()
func _on_BRE_press(toggle):
	if toggle:
		active = entities.get(Constants.BRE)
		activate()
func _on_HAM_press(toggle):
	if toggle:
		active = entities.get(Constants.HAM)
		activate()
func _on_HES_press(toggle):
	if toggle:
		active = entities.get(Constants.HES)
		activate()
func _on_MVP_press(toggle):
	if toggle:
		active = entities.get(Constants.MVP)
		activate()
func _on_NIE_press(toggle):
	if toggle:
		active = entities.get(Constants.NIE)
		activate()
func _on_NRW_press(toggle):
	if toggle:
		active = entities.get(Constants.NRW)
		activate()
func _on_RLP_press(toggle):
	if toggle:
		active = entities.get(Constants.RLP)
		activate()
func _on_SAA_press(toggle):
	if toggle:
		active = entities.get(Constants.SAA)
		activate()
func _on_SCN_press(toggle):
	if toggle:
		active = entities.get(Constants.SCN)
		activate()
func _on_SCA_press(toggle):
	if toggle:
		active = entities.get(Constants.SCA)
		activate()
func _on_SLH_press(toggle):
	if toggle:
		active = entities.get(Constants.SLH)
		activate()
func _on_THU_press(toggle):
	if toggle:
		active = entities.get(Constants.THU)
		activate()
	
func _on_DEU_press(toggle):
	print("Deutschland pressed")
	if toggle:
		active = entities.get(Constants.DEU)
		activate()

