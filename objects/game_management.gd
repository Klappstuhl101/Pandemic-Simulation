extends Object

class_name Game_Management

var entities # states + country
var active # active state / country
var mode # StatsMode or ActionMode
var statOutput # statOutput for stats
var actionOutput
var statButtons
var buttons


var days = [CONSTANTS.DAYS]

var previous # previous activated button

var counter = 0

func _init(initEntities, initStatOutput, initActionOutput, initButtons):
#	self.sim = initSim
	self.entities = initEntities
	self.statOutput = initStatOutput
	self.actionOutput = initActionOutput
#	self.statButtons = initStatButtons
	self.buttons = initButtons
	connectButtons()
	previous = entities.get(CONSTANTS.DEU)
	
#	var lineChart = statOutput[CONSTANTS.LINE]
#	lineChart.plot_from_array([sim.days, sim.sStats, sim.iStats, sim.rStats, sim.dStats])
	self.mode = CONSTANTS.STATMODE
	

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
	statOutput[CONSTANTS.LABEL].text = active.name
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
	mode = CONSTANTS.STATMODE
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	statOutput[CONSTANTS.STATCONTAINER].visible = true
	
	
#	var l1 = statOutput[CONSTANTS.LINE]
	statOutput[CONSTANTS.LINE].plot_from_array([self.days, entities[CONSTANTS.DEU].suscept, entities[CONSTANTS.DEU].infect, entities[CONSTANTS.DEU].recov, entities[CONSTANTS.DEU].dead])

#	var l2 = statOutput[CONSTANTS.LINE2]
	statOutput[CONSTANTS.LINE2].plot_from_array([self.days, entities[CONSTANTS.DEU].sus0, entities[CONSTANTS.DEU].inf0, entities[CONSTANTS.DEU].rec0, entities[CONSTANTS.DEU].dead0])

#	var l3 = statOutput[CONSTANTS.LINE3]
	statOutput[CONSTANTS.LINE3].plot_from_array([self.days, entities[CONSTANTS.DEU].sus1, entities[CONSTANTS.DEU].inf1, entities[CONSTANTS.DEU].rec1, entities[CONSTANTS.DEU].dead1])

#	var l4 = statOutput[CONSTANTS.LINE4]
#	l4.plot_from_array([self.days, entities[CONSTANTS.DEU].sus2, entities[CONSTANTS.DEU].inf2, entities[CONSTANTS.DEU].rec2, entities[CONSTANTS.DEU].dead2])
	statOutput[CONSTANTS.LINE4].plot_from_array([self.days, entities[CONSTANTS.DEU].inf2, entities[CONSTANTS.DEU].rec2, entities[CONSTANTS.DEU].dead2])

#	var l5 = statOutput[CONSTANTS.LINE5]
#	l5.plot_from_array([self.days, entities[CONSTANTS.DEU].beds, entities[CONSTANTS.DEU].hosp])
	statOutput[CONSTANTS.LINE5].plot_from_array([self.days, entities[CONSTANTS.DEU].vax2sus, entities[CONSTANTS.DEU].vax2inf, entities[CONSTANTS.DEU].vax2hosp, entities[CONSTANTS.DEU].vax2rec, entities[CONSTANTS.DEU].vax2dead])

#	var l6 = statOutput[CONSTANTS.LINE6]
	statOutput[CONSTANTS.LINE6].plot_from_array([self.days, entities[CONSTANTS.DEU].vax1sus, entities[CONSTANTS.DEU].vax1inf, entities[CONSTANTS.DEU].vax1hosp, entities[CONSTANTS.DEU].vax1rec, entities[CONSTANTS.DEU].vax1dead])
#	l6.plot_from_array([self.days, entities[CONSTANTS.DEU].vax1sus, entities[CONSTANTS.DEU].vax1inf])
#	var lineChart = statOutput[CONSTANTS.LINE]
#	lineChart.plot_from_array([self.days, entities[CONSTANTS.DEU].suscept, entities[CONSTANTS.DEU].infect, entities[CONSTANTS.DEU].recov, entities[CONSTANTS.DEU].dead])
	

func _on_actionButton_press():
	mode = CONSTANTS.ACTIONMODE
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = true
	

func connectButtons():
	buttons[CONSTANTS.STATBUTTON].connect("pressed", self, "_on_statButton_press")
	buttons[CONSTANTS.ACTIONBUTTON].connect("pressed", self, "_on_actionButton_press")
	
	# Buttons for Map
	entities[CONSTANTS.BAW].mapButton.connect("toggled", self, "_on_BAW_press")
	entities[CONSTANTS.BAY].mapButton.connect("toggled", self, "_on_BAY_press")
	entities[CONSTANTS.BER].mapButton.connect("toggled", self, "_on_BER_press")
	entities[CONSTANTS.BRA].mapButton.connect("toggled", self, "_on_BRA_press")
	entities[CONSTANTS.BRE].mapButton.connect("toggled", self, "_on_BRE_press")
	entities[CONSTANTS.HAM].mapButton.connect("toggled", self, "_on_HAM_press")
	entities[CONSTANTS.HES].mapButton.connect("toggled", self, "_on_HES_press")
	entities[CONSTANTS.MVP].mapButton.connect("toggled", self, "_on_MVP_press")
	entities[CONSTANTS.NIE].mapButton.connect("toggled", self, "_on_NIE_press")
	entities[CONSTANTS.NRW].mapButton.connect("toggled", self, "_on_NRW_press")
	entities[CONSTANTS.RLP].mapButton.connect("toggled", self, "_on_RLP_press")
	entities[CONSTANTS.SAA].mapButton.connect("toggled", self, "_on_SAA_press")
	entities[CONSTANTS.SCN].mapButton.connect("toggled", self, "_on_SCN_press")
	entities[CONSTANTS.SCA].mapButton.connect("toggled", self, "_on_SCA_press")
	entities[CONSTANTS.SLH].mapButton.connect("toggled", self, "_on_SLH_press")
	entities[CONSTANTS.THU].mapButton.connect("toggled", self, "_on_THU_press")
	entities[CONSTANTS.DEU].mapButton.connect("toggled", self, "_on_DEU_press")
