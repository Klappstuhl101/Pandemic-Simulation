extends Object

class_name Game_Management

var entities :Dictionary # states + country
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

	setMode(CONSTANTS.STATMODE)
	
	self.paused = true
	
	self.establishedLegends = false
	
	establishActions()
	
	self.active = entities.get(CONSTANTS.DEU)
	
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	

func showAction():
	statOutput[CONSTANTS.COUNTRYNAME].text = active.name
	updateMap()
	
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = true
	
	
	

func showStats():
	statOutput[CONSTANTS.COUNTRYNAME].text = active.name
	updateMap()
	
	if getMode() == CONSTANTS.ACTIONMODE:
		return
	
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	
	if statOutput[CONSTANTS.TIMER].is_stopped():
		statOutput[CONSTANTS.TIMER].start()
	
	if self.days.size() > 3:
		buttons[CONSTANTS.STATBUTTON].disabled = false
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
			
			var hospitalOccupation = getHospitalOccupation(showInterval)
			statOutput[CONSTANTS.HOSPBEDS].plot_from_array(hospitalOccupation)
			statOutput[CONSTANTS.BEDSTATUS].text = String(hospitalOccupation[2][hospitalOccupation[2].size() - 1]) + CONSTANTS.BL + "/" + CONSTANTS.BL + String(active.getHospitalBeds())
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
			
		
		statOutput[CONSTANTS.STATCONTAINER].visible = true
	#	HIERHER DIE GANZEN SHADER EINSTELLUNGEN UND ÜBERGABE
	#	active.mapButton.material.set_shader_param("vaccinated", counter)
	#	active.mapButton.material.set_shader_param("infected", counter)
	#	var color = active.mapButton.material.get_shader_param("infectGradient").get_gradient().interpolate(counter)
	#	active.mapButton.material.get_shader_param("twoColorGradient").get_gradient().set_color(0,color)
		
		
		

func updateMap():
	var incidences = []
	for entity in entities.values():
		incidences.append(entity.get7DayIncidence(godmode))
#	var maxInc = incidences.max()
#	print(log(incidences[0]) / log(incidences.max()), " //", String(incidences[0]) + " Inzidenz Bawü// " + String(incidences.max()))
#	entities[CONSTANTS.BAW].mapButton.material.set_shader_param("incidenceRatio", log(incidences[0]) / log(incidences.max()))
#
	# Für die Zukunft in der jeder MapButton einen Shader hat
	var i = 0
	for entity in entities.values():
		if incidences.max() > 0:
#			print(entity.getName()," MapFaktor //", float(incidences[i]) / float(incidences.max()), " // ", float(log(incidences[i])) / float(log(incidences.max())))
			entity.mapButton.material.set_shader_param("incidenceRatio", float(incidences[i]) / float(incidences.max()))
#			entity.mapButton.material.set_shader_param("incidenceRatio", float(log(incidences[i])) / float(log(incidences.max())))
		else:
			entity.mapButton.material.set_shader_param("incidenceRatio", 0)
		i += 1
	
	print("Inzidenz Deutschland ", incidences[incidences.size() -1], " // Inzidenz Durchschnitt: " , float(CONSTANTS.sum(incidences) - incidences[incidences.size() -1]) / 16.0)
	i = statOutput[CONSTANTS.INCIDENCELABELS].get_children().size()
	for label in statOutput[CONSTANTS.INCIDENCELABELS].get_children():
		label.text = String(int(incidences.max() * (i/4.0)))
		i -= 1

func getMode():
	return self.mode

func setMode(newMode):
	self.mode = newMode

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
	if godmode:
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
	else:
		# HIER STATT ALLEN ZAHLEN NUR GETESTETE FÄLLE
#		var output = [dayArray]
#		var sus = [CONSTANTS.SUSCEPTIBLE]
#		var susTested = [CONSTANTS.SUSCEPTIBLE + CONSTANTS.BL + CONSTANTS.TESTED]
#		var inf = [CONSTANTS.INFECTED + CONSTANTS.BL + CONSTANTS.TESTED]
##		var rec = [CONSTANTS.RECOVERED]
#		var recTested = [CONSTANTS.RECOVERED + CONSTANTS.BL + CONSTANTS.TESTED]
#		var dead = [CONSTANTS.DEAD]
#		for i in range(1, dayArray.size()):
#			sus.append(active.suscept[dayArray[i]])
#			susTested.append(active.sus1[dayArray[i]])
#			inf.append(active.inf1[dayArray[i]] + active.getDailyOccupiedBeds(dayArray[i]))
##			rec.append(active.recov[dayArray[i]])
#			recTested.append(active.rec1[dayArray[i]] + active.rec2[dayArray[i]])
#			dead.append(active.dead[dayArray[i]])
#		output.append(sus)
#		output.append(susTested)
#		output.append(inf)
##		output.append(rec)
#		output.append(recTested)
#		output.append(dead)
#		return output
		
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
	return active.get7DayIncidence(godmode)

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
	if self.days.size() > 3:
		buttons[CONSTANTS.STATBUTTON].disabled = false
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
	setMode(CONSTANTS.STATMODE)
#	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
#	statOutput[CONSTANTS.STATCONTAINER].visible = true
	showStats()
	
func _on_actionButton_press():
	setMode(CONSTANTS.ACTIONMODE)
#	statOutput[CONSTANTS.STATCONTAINER].visible = false
#	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = true
	showAction()
	

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
#	print(OS.get_ticks_msec()/1000, " secs // or ", OS.get_ticks_msec()/60000, " minutes // ", OS.get_ticks_msec())
	showStats()
	statOutput[CONSTANTS.TIMER].stop()

func _show_overview_legend():
	if godmode:
		statOutput[CONSTANTS.OVERVIEWHEADLINE].text = "Anzahl aller Fälle"
	
	for function in statOutput[CONSTANTS.OVERVIEW].get_legend():
		statOutput[CONSTANTS.OVERVIEWLEGEND].add_child(function)

func _show_vaxStatus_legend():
	for function in statOutput[CONSTANTS.VAXSTATUS].get_legend():
		statOutput[CONSTANTS.VAXSTATUSLEGEND].add_child(function)

func _show_daily_legend():
	for function in statOutput[CONSTANTS.DAILYCHANGES].get_legend():
		statOutput[CONSTANTS.DAILYLEGEND].add_child(function)

func establishActions():
	actionOutput[CONSTANTS.OPTIONBUTTON].add_item("NR1")
	actionOutput[CONSTANTS.OPTIONBUTTON].add_item("NR2")
	actionOutput[CONSTANTS.OPTIONBUTTON].add_item("NR3")
	
	actionOutput[CONSTANTS.MENUBUTTON].get_popup().add_item("NR1")
	actionOutput[CONSTANTS.MENUBUTTON].get_popup().add_item("NR2")
	actionOutput[CONSTANTS.MENUBUTTON].get_popup().add_item("NR3")

func establishLegends():
	_show_overview_legend()
	_show_vaxStatus_legend()
	_show_daily_legend()

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
	
