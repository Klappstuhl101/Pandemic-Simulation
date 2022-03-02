extends Object

class_name Game_Management

var entities # states + country
var active # active state / country
var mode # StatsMode or ActionMode
var statOutput # statOutput for stats
var actionOutput
var statButtons
var buttons

var establishedLegends:bool

var paused:bool

var godmode:bool

var interval


var days = []
var currentDay = 0

var previous # previous activated button

var counter = 0

func _init(initEntities, initStatOutput, initActionOutput, initButtons, initGodmode):
#	self.sim = initSim
	self.entities = initEntities
	self.statOutput = initStatOutput
	self.actionOutput = initActionOutput
#	self.statButtons = initStatButtons
	self.buttons = initButtons
	connectSignals()
	previous = entities.get(CONSTANTS.DEU)
	
	self.godmode = initGodmode
	
	self.interval = CONSTANTS.WEEK
	
#	var lineChart = statOutput[CONSTANTS.LINE]
#	lineChart.plot_from_array([sim.days, sim.sStats, sim.iStats, sim.rStats, sim.dStats])
	self.mode = CONSTANTS.STATMODE
	
	self.paused = true
	
	self.establishedLegends = false
	
	self.active = entities.get(CONSTANTS.DEU)
	
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	

func update():
#	HIER DIE UPDATES FÜR STATS ETC. AUCH SHADER
	pass

func showStats():
	statOutput[CONSTANTS.COUNTRYNAME].text = active.name
	if statOutput[CONSTANTS.TIMER].is_stopped():
		statOutput[CONSTANTS.TIMER].start()
	
	if self.days.size() > 3:
		
		if godmode:
			pass
		else:
			var showInterval = getOutputInterval()
			statOutput[CONSTANTS.OVERVIEW].plot_from_array(getOutputOverview(showInterval))
#			statOutput[CONSTANTS.OVERVIEW].redraw()
			
			var incidence = String(getOutputIncidence())
			statOutput[CONSTANTS.INCIDENCE].text = incidence
			var rValue = String(getOutputR())
			statOutput[CONSTANTS.RVALUE].text = rValue
			
			statOutput[CONSTANTS.VAXSTATUS].plot_from_array(getOutputVaccinations())
			
			statOutput[CONSTANTS.DAILYCHANGES].plot_from_array(getDailyChanges(showInterval))
			
			statOutput[CONSTANTS.HOSPBEDS].plot_from_array(getHospitalOccupation(showInterval))
#			if days.max() == 70:
#				entities[CONSTANTS.DEU].setHospitalBeds(days.max(), 500)
			if days.max() == 50:
				entities[CONSTANTS.DEU].setHospitalBeds(days.max(), 100)
			
		if !establishedLegends:
			establishedLegends = true
			establishLegends()
		
		if self.days.size() > 30:
			buttons[CONSTANTS.MONTH].disabled = false
		
		if self.days.size() > 360:
			buttons[CONSTANTS.YEAR].disabled = false
	#		pass
	#	HIERHER DIE GANZEN SHADER EINSTELLUNGEN UND ÜBERGABE
	#	active.mapButton.material.set_shader_param("vaccinated", counter)
	#	active.mapButton.material.set_shader_param("infected", counter)
	#	var color = active.mapButton.material.get_shader_param("infectGradient").get_gradient().interpolate(counter)
	#	active.mapButton.material.get_shader_param("twoColorGradient").get_gradient().set_color(0,color)
		
		
		actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
		statOutput[CONSTANTS.STATCONTAINER].visible = true

func getMode():
	return self.mode

func getOutputArray():
	pass

func getOutputInterval():
	var dayArray = [CONSTANTS.DAYS]
	if self.days.size() < CONSTANTS.WEEK:
		dayArray.append_array(self.days)
		dayArray.remove(1)
		return dayArray
	
	match self.interval:
		CONSTANTS.WEEK:
			for i in range(CONSTANTS.WEEK):
				if (days.size() - 1 - CONSTANTS.WEEK + i) <= 0:
					continue
				else:
					dayArray.append(days[days.size() - 1 - CONSTANTS.WEEK + i])
		
		CONSTANTS.MONTH:
			for i in range(CONSTANTS.MONTH / 3):
				if (days.size() - 1 - CONSTANTS.MONTH + (i*3)) <= 0:
					continue
				else:
					dayArray.append(days[days.size() - 1 - CONSTANTS.MONTH + (i*3)])
		
		CONSTANTS.YEAR:
			for i in range(CONSTANTS.YEAR / 12):
				if (days.size() - 1 - CONSTANTS.YEAR + (i*12)) <= 0:
					continue
				else:
					dayArray.append(days[days.size() - 1 - CONSTANTS.YEAR + (i*12)])
		
		CONSTANTS.MAX:
			dayArray.append_array(self.days)
			dayArray.remove(1)
			return dayArray
			
	return dayArray

func getOutputOverview(dayArray):
	var output = [dayArray]
	var sus = [CONSTANTS.SUSCEPTIBLE]
	var inf = [CONSTANTS.INFECTED]
	var rec = [CONSTANTS.RECOVERED]
	var dead = [CONSTANTS.DEAD]
	for i in range(1, dayArray.size()):
		sus.append(active.suscept[dayArray[i]])
		inf.append(active.infect[dayArray[i]])
		rec.append(active.recov[dayArray[i]])
		dead.append(active.dead[dayArray[i]])
	output.append(sus)
	output.append(inf)
	output.append(rec)
	output.append(dead)
	return output

func getOutputIncidence():
	var newCases = 0
	if godmode:
		for i in range(CONSTANTS.WEEK):
			var index = self.days[days.size() - 1] - CONSTANTS.WEEK + i 
			if index < 2:
				continue
			newCases += (active.infect[index] - active.infect[index - 1])
			
#		for i in range(self.interval):
#			var index = self.days[days.size() - 1] - self.interval + i 
#			if index < 2:
#				continue
#			newCases += (active.infect[index] - active.infect[index - 1])
	else:
		for i in range(CONSTANTS.WEEK):
			var index = self.days[days.size() - 1] - CONSTANTS.WEEK + i 
			if index < 2:
				continue
			newCases += (active.inf1[index] - active.inf1[index - 1]) + (active.hosp[index] - active.hosp[index - 1]) + (active.vax1hosp[index] - active.vax1hosp[index - 1]) + (active.vax2hosp[index] - active.vax2hosp[index - 1])
	
#		for i in range(self.interval):
#			var index = self.days[days.size() - 1] - self.interval + i 
#			if index < 2:
#				continue
#			newCases += (active.inf1[index] - active.inf1[index - 1]) + (active.hosp[index] - active.hosp[index - 1]) + (active.vax1hosp[index] - active.vax1hosp[index - 1]) + (active.vax2hosp[index] - active.vax2hosp[index - 1])
	var incidence = int((float(newCases)/float(active.getPopulation())) * 100000)
#	return int((float(newCases)/float(active.getPopulation())) * 100000)
	return incidence if incidence > 0 else 0

func getOutputR():
	var casesGen1:float = 0
	var casesGen2:float = 0
	if godmode:
		pass
	else:
		for i in range(CONSTANTS.WEEK):
			var indexGen1 = self.days[days.size() - 1] - CONSTANTS.WEEK + i
			var indexGen2 = indexGen1 - CONSTANTS.WEEK
			if indexGen1 > 2:
				casesGen1 += (active.inf1[indexGen1] - active.inf1[indexGen1 - 1]) + (active.hosp[indexGen1] - active.hosp[indexGen1 - 1]) + (active.vax1hosp[indexGen1] - active.vax1hosp[indexGen1 - 1]) + (active.vax2hosp[indexGen1] - active.vax2hosp[indexGen1 - 1])
			if indexGen2 > 2:
				casesGen2 += (active.inf1[indexGen2] - active.inf1[indexGen2 - 1]) + (active.hosp[indexGen2] - active.hosp[indexGen2 - 1]) + (active.vax1hosp[indexGen2] - active.vax1hosp[indexGen2 - 1]) + (active.vax2hosp[indexGen2] - active.vax2hosp[indexGen2 - 1])
	
	if casesGen2 == 0:
		return 0
	else:
		return stepify(casesGen1/casesGen2, 0.01)

func getOutputVaccinations():
	var sumUnvax = active.getUnvaxedSum()
	var sumV1 = active.getV1Sum()
	var sumV2 = active.getV2Sum()
#	var sumV1 = CONSTANTS.sum(active.vax1sus) + CONSTANTS.sum(active.vax1inf) + CONSTANTS.sum(active.vax1hosp) + CONSTANTS.sum(active.vax1rec)
#	var sumV2 = CONSTANTS.sum(active.vax2sus) + CONSTANTS.sum(active.vax2inf) + CONSTANTS.sum(active.vax2hosp) + CONSTANTS.sum(active.vax2rec)
	return [[CONSTANTS.VAXSTATUS, "Anzahl Personen"], [CONSTANTS.UNVAXED, sumUnvax], [CONSTANTS.VAX1, sumV1], [CONSTANTS.VAX2, sumV2]]

func getDailyChanges(dayArray):
	var output = [dayArray]
	var newInfections = [CONSTANTS.NEWINFECTIONS]
	var newVaxxed1 = [CONSTANTS.FIRSTVAX]
	var newVaxxed2 = [CONSTANTS.SECONDVAX]
	
#	if dayArray.size() == ((CONSTANTS.YEAR/12.0) + 1):
#		pass
	
	for i in range(1, dayArray.size()):
		if dayArray[i] > 2:
			newInfections.append(active.getDailyInfections(dayArray[i]))
			newVaxxed1.append(active.getDailyV1Difference(dayArray[i]))
			newVaxxed2.append(active.getDailyV2Difference(dayArray[i]))
		else:
			newInfections.append(0)
			newVaxxed1.append(0)
			newVaxxed2.append(0)
			
	output.append(newInfections)
	output.append(newVaxxed1)
	output.append(newVaxxed2)
	
	return output
	
	var data = [["0","A","B","C"], ["Stimmen",2,3,4], ["Bla",6,7,8], ["Drei", 2, 5, 8]]
	
	return output

func getHospitalOccupation(dayArray):
	var output = [dayArray]
	var hosp = [CONSTANTS.HOSPITALISED]
	var maxBeds = [CONSTANTS.HOSPBEDS]
	
	for i in range(1, dayArray.size()):
		hosp.append(active.getDailyOccupiedBeds(dayArray[i]))
		maxBeds.append(active.getHospitalBeds(dayArray[i]))
	
	output.append(maxBeds)
	output.append(hosp)
	return output

func simulate():
	entities[CONSTANTS.DEU].simulateALL()
	days.append(self.currentDay)
	updateDay()

func updateDay():
	statOutput[CONSTANTS.DAYS].text = CONSTANTS.DAYS + CONSTANTS.BL + String(self.currentDay)
	self.currentDay += 1

func activate():
#	resetAll(active.name)
	showStats()

#func resetAll(exception = ""):
#	for entity in entities.values():
#		if (entity.name != exception):
#			entity.mapButton.pressed = false
			
func _on_BAW_press(_toggle):
	active = entities.get(CONSTANTS.BAW)
	activate()
func _on_BAY_press(_toggle):
	active = entities.get(CONSTANTS.BAY)
	activate()
#	if _toggle:
#		active = entities.get(CONSTANTS.BAY)
#		activate()
#	else:
#		active.mapButton.pressed = true
func _on_BER_press(_toggle):
	active = entities.get(CONSTANTS.BER)
	activate()
func _on_BRA_press(_toggle):
	active = entities.get(CONSTANTS.BRA)
	activate()
#	if _toggle:
#		active = entities.get(CONSTANTS.BRA)
#		activate()
#	else:
#		active.mapButton.pressed = true
func _on_BRE_press(_toggle):
	active = entities.get(CONSTANTS.BRE)
	activate()
func _on_HAM_press(_toggle):
	active = entities.get(CONSTANTS.HAM)
	activate()
func _on_HES_press(_toggle):
	active = entities.get(CONSTANTS.HES)
	activate()
func _on_MVP_press(_toggle):
	active = entities.get(CONSTANTS.MVP)
	activate()
func _on_NIE_press(_toggle):
	active = entities.get(CONSTANTS.NIE)
	activate()
#	if _toggle:
#		active = entities.get(CONSTANTS.NIE)
##		self.material.set_shader_param("testcolor", Color(1.0,0.0,0.0))
#		active.mapButton.material.set_shader_param("vaccinated", counter)
#		active.mapButton.material.set_shader_param("infected", counter)
#		var color = active.mapButton.material.get_shader_param("infectGradient").get_gradient().interpolate(counter)
#		active.mapButton.material.get_shader_param("twoColorGradient").get_gradient().set_color(0,color)
#		print(counter)
#		counter += 0.01
#		activate()
#	else:
#		active.mapButton.pressed = true
func _on_NRW_press(_toggle):
	active = entities.get(CONSTANTS.NRW)
	activate()
func _on_RLP_press(_toggle):
	active = entities.get(CONSTANTS.RLP)
	activate()
func _on_SAA_press(_toggle):
	active = entities.get(CONSTANTS.SAA)
	activate()
func _on_SCN_press(_toggle):
	active = entities.get(CONSTANTS.SCN)
	activate()
func _on_SCA_press(_toggle):
	active = entities.get(CONSTANTS.SCA)
	activate()
func _on_SLH_press(_toggle):
	active = entities.get(CONSTANTS.SLH)
	activate()
func _on_THU_press(_toggle):
	active = entities.get(CONSTANTS.THU)
	activate()
	
func _on_DEU_press(_toggle):
	active = entities.get(CONSTANTS.DEU)
	activate()
		
func _on_statButton_press():
	mode = CONSTANTS.STATMODE
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	statOutput[CONSTANTS.STATCONTAINER].visible = true
	
func _on_actionButton_press():
	mode = CONSTANTS.ACTIONMODE
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = true
	

func _on_weekButton_press():
	self.interval = CONSTANTS.WEEK
	showStats()
	
func _on_monthButton_press():
	self.interval = CONSTANTS.MONTH
	showStats()
	
func _on_yearButton_press():
	self.interval = CONSTANTS.YEAR
	showStats()
	
func _on_maxButton_press():
	self.interval = CONSTANTS.MAX
	showStats()

func _on_Time_timeout():
	print(OS.get_ticks_msec()/1000, " secs // or ", OS.get_ticks_msec()/60000, " minutes // ", OS.get_ticks_msec())
	showStats()
	statOutput[CONSTANTS.TIMER].stop()

func _show_overview_legend():
	for function in statOutput[CONSTANTS.OVERVIEW].get_legend():
		statOutput[CONSTANTS.OVERVIEWLEGEND].add_child(function)

func _show_vaxStatus_legend():
	for function in statOutput[CONSTANTS.VAXSTATUS].get_legend():
		statOutput[CONSTANTS.VAXSTATUSLEGEND].add_child(function)

func establishLegends():
	_show_overview_legend()
	_show_vaxStatus_legend()

func connectSignals():
	statOutput[CONSTANTS.TIMER].set_wait_time(0.5)
	statOutput[CONSTANTS.TIMER].connect("timeout", self, "_on_Time_timeout")
	statOutput[CONSTANTS.TIMER].start()
	
#	statOutput[CONSTANTS.OVERVIEW].connect("chart_plotted", self, "_show_overview_legend")
	
	
	buttons[CONSTANTS.STATBUTTON].connect("pressed", self, "_on_statButton_press")
	buttons[CONSTANTS.ACTIONBUTTON].connect("pressed", self, "_on_actionButton_press")
	
	buttons[CONSTANTS.WEEK].connect("pressed", self, "_on_weekButton_press")
	buttons[CONSTANTS.MONTH].connect("pressed", self, "_on_monthButton_press")
	buttons[CONSTANTS.YEAR].connect("pressed", self, "_on_yearButton_press")
	buttons[CONSTANTS.MAX].connect("pressed", self, "_on_maxButton_press")
	
#	buttons[CONSTANTS.PAUSEBUTTON].connect("pressed", self, "_on_Pause_pressed")
#	buttons[CONSTANTS.PLAYBUTTON].connect("pressed", self, "_on_Play_pressed")
#	buttons[CONSTANTS.PLAYX2BUTTON].connect("pressed", self, "_on_PlaySpeedx2_pressed")
	
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
	
