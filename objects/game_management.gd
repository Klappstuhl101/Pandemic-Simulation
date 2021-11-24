extends Object

class_name Game_Management

var entities # states + country
var active # active state / country
var mode # StatsMode or ActionMode
var stat_output # stat_output for stats
var statButtons
var sim # simulation class

var previous # previous activated button

var counter = 0

func _init(initSim,  initStatOutput, initStatButtons):
	self.sim = initSim
	self.entities = sim.entities
	self.stat_output = initStatOutput
	self.statButtons = initStatButtons
	connectButtons()
	previous = entities.get(CONSTANTS.DEU)
	
#	var lineChart = stat_output[CONSTANTS.LINE]
#	lineChart.plot_from_array([sim.days, sim.sStats, sim.iStats, sim.rStats, sim.dStats])
	
	

func update():
#	HIER DIE UPDATES FÜR STATS ETC. AUCH SHADER
	pass

func resetAll(exception = ""):
	for entity in entities.values():
		if (entity.name != exception):
			entity.mapButton.pressed = false

func showStats():
#	HIERHER DIE GANZEN SHADER EINSTELLUNGEN UND ÜBERGABE
#	active.mapButton.material.set_shader_param("vaccinated", counter)
#	active.mapButton.material.set_shader_param("infected", counter)
#	var color = active.mapButton.material.get_shader_param("infectGradient").get_gradient().interpolate(counter)
#	active.mapButton.material.get_shader_param("twoColorGradient").get_gradient().set_color(0,color)
	stat_output[CONSTANTS.LABEL].text = active.name
	pass

func activate():
	resetAll(active.name)

	showStats()

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
#		self.material.set_shader_param("testcolor", Color(1.0,0.0,0.0))
		active.mapButton.material.set_shader_param("vaccinated", counter)
		active.mapButton.material.set_shader_param("infected", counter)
		var color = active.mapButton.material.get_shader_param("infectGradient").get_gradient().interpolate(counter)
		active.mapButton.material.get_shader_param("twoColorGradient").get_gradient().set_color(0,color)
		print(counter)
		counter += 0.01
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
		
func _on_statButton_press():
	var lineChart = stat_output[CONSTANTS.LINE]
	lineChart.plot_from_array([sim.days, sim.sStats, sim.iStats, sim.rStats, sim.dStats])
	

func connectButtons():
	statButtons[CONSTANTS.STATBUTTON].connect("pressed", self, "_on_statButton_press")
	for entity in entities.values():
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
				entity.mapButton.connect("toggled", self, "_on_DEU_press")
