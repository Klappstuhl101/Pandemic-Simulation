extends Object

class_name Game_Management

#var calcTime:float

var _simThread :Thread
#var _statThread :Thread

#var _simLock :Mutex
#
#var loading :bool
#var running :bool

var entities :Dictionary # states + country
var active # active state / country
var mode # StatsMode or ActionMode or Endmode
var statOutput # statOutput for stats
var actionOutput
#var statButtons
var buttons

#var establishedLegends:bool
var restarted:bool

#var paused:bool

var godmode:bool
var godmodeChanged :bool = false

var optionAdded:bool

var interval

var activePopulationToRealFactor :float
var activePopulationToCalculationFactor :float



var days = []
var currentDay :int = 1
var endDay :int
var ended :bool = false


var vaxColorScheme :PoolColorArray


func _init(initEntities, initStatOutput, initActionOutput, initButtons, initGodmode):
	
	self._simThread = Thread.new()
#	self._simThread.start(self, "_start_thread_with_nothing", "Game_management")
#	self._statThread = Thread.new()
	
#	self.sim = initSim
	self.entities = initEntities
	self.statOutput = initStatOutput
	self.actionOutput = initActionOutput
#	self.statButtons = initStatButtons
	self.buttons = initButtons
	
#	previous = entities.get(CONSTANTS.DEU)
	
	self.godmode = initGodmode
	self.godmodeChanged = true
	
	self.restarted = false
#	self.loading = false
#	self.running = false
	
#	self.selectedLockdown = [0, 1-0.816, 1-0.66, 1-0.451]
#
#	self.maskFactors = [0,0.5,0.1,0.04]
#	self.commuterFactors = [1, 1-0.24, 1-0.42, (1 - 0.43) * 0.42]
	
#	self.lockdownFactor = 0
#	self.maskFactor = 0
	
	self.interval = CONSTANTS.WEEK

	setMode(CONSTANTS.STATMODE)
	
#	self.optionChanged = false
	
#	self.paused = true
	
#	self.establishedLegends = false
	
	establishActions()
	
	self.optionAdded = false
	
	self.active = entities.get(CONSTANTS.DEU)
	activate()
	
#	self.selectedMask = 0
#	self.selectedHomeOffice = 0
	
	connectSignals()
	
	if !godmode:
		statOutput[CONSTANTS.INCIDENCESCALETITLE].text = CONSTANTS.INCIDENCESCALETITLE + CONSTANTS.BL + "(" + CONSTANTS.TESTED + ")"
	
	
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	
	vaxColorScheme.append(Color(1.0, 0.0, 0.0, 1.00))
	vaxColorScheme.append(Color(0.0, 0.50, 0.0, 1.00))
	vaxColorScheme.append(Color(0.0, 1.0, 0.0, 1.00))
	
	statOutput[CONSTANTS.VAXSTATUS].function_colors = vaxColorScheme
	statOutput[CONSTANTS.VAXSTATUS].font_color = Color(1.0, 1.0, 1.0, 1.0)
	statOutput[CONSTANTS.HOSPITALALLOCATION].function_colors = vaxColorScheme
	statOutput[CONSTANTS.HOSPITALALLOCATION].font_color = Color(1.0, 1.0, 1.0, 1.0)
	statOutput[CONSTANTS.DEATHOVERVIEW].function_colors = vaxColorScheme
	statOutput[CONSTANTS.VAXSUMMARY].function_colors = vaxColorScheme
	statOutput[CONSTANTS.VAXSUMMARY].font_color = Color(1.0, 1.0, 1.0, 1.0)
	statOutput[CONSTANTS.DEATHSUMMARY].function_colors = vaxColorScheme
	statOutput[CONSTANTS.DEATHSUMMARY].font_color = Color(1.0, 1.0, 1.0, 1.0)
	

func _start_thread_with_nothing(userdata):
	print(userdata + " Thread started")
	return



func showAction():
	
	updateMap()
	updateInterventionWeight()
	
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	statOutput[CONSTANTS.ENDCONTAINER].visible = false
	
#	if self.optionChanged:
#		actionOutput[CONSTANTS.USERDEFINED].pressed = self.optionChanged
#		self.optionChanged = false
	
#	actionOutput[CONSTANTS.MASKOPTION].select(active.getSelectedMask())
#	actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(active.getSelectedHomeOffice())
	
	if active.getName() == entities[CONSTANTS.DEU].getName():
		if !optionAdded:
			add_options(true)
			optionAdded = true
		actionOutput[CONSTANTS.BORDERTIP].visible = (true if entities[CONSTANTS.DEU].getBorderOpen() is int else false)
		actionOutput[CONSTANTS.BORDERCONTROL].pressed = !entities[CONSTANTS.DEU].getBorderOpen() if entities[CONSTANTS.DEU].getBorderOpen() is bool else false
		
#		if entities[CONSTANTS.DEU].getSelectedMask() == entities[CONSTANTS.DEU].getSelectedHomeOffice() and entities[CONSTANTS.DEU].getOptionChanged: 
#			match entities[CONSTANTS.DEU].getSelectedMask():
#				0:
#					actionOutput[CONSTANTS.NO].pressed = true
#				1:
#					actionOutput[CONSTANTS.LIGHT].pressed = true
#				2:
#					actionOutput[CONSTANTS.MEDIUM].pressed = true
#				3:
#					actionOutput[CONSTANTS.HEAVY].pressed = true
#		else:
#			actionOutput[CONSTANTS.USERDEFINED].pressed = true
		
	else:
		if optionAdded:
			add_options(false)
			optionAdded = false
		actionOutput[CONSTANTS.MASKOPTION].select(active.getSelectedMask())
		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(active.getSelectedHomeOffice())
		
		actionOutput[CONSTANTS.BORDERCONTROL].pressed = !active.getBorderOpen()
		actionOutput[CONSTANTS.BORDERTIP].visible = false
	
	if active.getSelectedMask() == active.getSelectedHomeOffice() and !active.getOptionChanged(): 
		match active.getSelectedMask():
			0:
				actionOutput[CONSTANTS.NO].pressed = true
			1:
				actionOutput[CONSTANTS.LIGHT].pressed = true
			2:
				actionOutput[CONSTANTS.MEDIUM].pressed = true
			3:
				actionOutput[CONSTANTS.HEAVY].pressed = true
	else:
		actionOutput[CONSTANTS.USERDEFINED].pressed = true
	
	
	actionOutput[CONSTANTS.TESTOPTION].select(active.getSelectedTestRates())
	actionOutput[CONSTANTS.MASKOPTION].select(active.getSelectedMask())
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(active.getSelectedHomeOffice())
	
	actionOutput[CONSTANTS.VAXPRODUCTIONSPINBOX].editable = active.getName() == entities[CONSTANTS.DEU].getName()
	actionOutput[CONSTANTS.VAXPRODUCTIONSPINBOX].value = getProjectedToRealPopulation(entities[CONSTANTS.DEU].getVaxProduction())
	
	actionOutput[CONSTANTS.HOSPITALBEDSPINBOX].editable = active.getName() == entities[CONSTANTS.DEU].getName()
	actionOutput[CONSTANTS.HOSPITALBEDSPINBOX].value = getProjectedToRealPopulation(active.getHospitalBeds(self.days.max() if self.days.max() != null else 0))
	
	actionOutput[CONSTANTS.OCCBEDS].text = String(getProjectedToRealPopulation(active.getDailyOccupiedBeds(self.days.max() if self.days.max() != null else -1))) + " / " + String(getProjectedToRealPopulation(active.getHospitalBeds()))
	actionOutput[CONSTANTS.AVLBLVAX].text = String(getProjectedToRealPopulation(active.getAvlbVax()))
	
	actionOutput[CONSTANTS.GODMODEBUTTON].set_pressed_no_signal(self.godmode)
#	actionOutput[CONSTANTS.GODMODEBUTTON].set_pressed(self.godmode)
	
	
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = true
	
	
	
	

func showStats():
#	if _simThread.is_active():
#		_simThread.wait_to_finish()
	updateMap()
	updateInterventionWeight()
	
	if getMode() == CONSTANTS.ACTIONMODE:
		return
	
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	statOutput[CONSTANTS.ENDCONTAINER].visible = false
	
	if statOutput[CONSTANTS.TIMER].is_stopped():
		statOutput[CONSTANTS.TIMER].start()
	
	if self.days.size() > 3:
		buttons[CONSTANTS.STATBUTTON].disabled = false
		
		
		var showInterval = getOutputInterval()
		statOutput[CONSTANTS.OVERVIEW].plot_from_array(getOutputOverview(showInterval))
#			statOutput[CONSTANTS.OVERVIEW].redraw()
		
		var incidence = String(getOutputIncidence())
		statOutput[CONSTANTS.INCIDENCE].text = incidence
		var rValue = String(getOutputR())
		statOutput[CONSTANTS.RVALUE].text = rValue
		
		statOutput[CONSTANTS.NEWINFECTIONS].plot_from_array(getDailyInfections(showInterval))
		
		statOutput[CONSTANTS.VAXSTATUS].plot_from_array(getOutputVaccinations())
		
		statOutput[CONSTANTS.DAILYVAXCHANGES].plot_from_array(getDailyVax(showInterval))
		
		var hospitalOccupation = getHospitalOccupation(showInterval)
		statOutput[CONSTANTS.HOSPBEDS].plot_from_array(hospitalOccupation)
		statOutput[CONSTANTS.BEDSTATUS].text = String(hospitalOccupation[2][hospitalOccupation[2].size() - 1]) + CONSTANTS.BL + "/" + CONSTANTS.BL + String(getProjectedToRealPopulation(active.getHospitalBeds()))
		
		if hospitalOccupation[2][hospitalOccupation[2].size() - 1] > 0:
			statOutput[CONSTANTS.HOSPITALALLOCATION].plot_from_array(getHospitalAllocation(showInterval))
			statOutput[CONSTANTS.ALLOCATIONPLACEHOLER].visible = false
			statOutput[CONSTANTS.HOSPITALALLOCATION].visible = true
		else:
			statOutput[CONSTANTS.HOSPITALALLOCATION].visible = false
			statOutput[CONSTANTS.ALLOCATIONPLACEHOLER].visible = true
		
		statOutput[CONSTANTS.DEATHOVERVIEW].plot_from_array(getDeathOverview(showInterval))
		
			
#		if !establishedLegends:
#			establishStatLegends()
#			establishedLegends = true
		
		if godmodeChanged:
			establishStatLegends()
#			_show_overview_legend()
#			_show_daily_legend()
			self.godmodeChanged = false
			
		
		
		
		
		if self.days.size() > 30:
			buttons[CONSTANTS.MONTH].disabled = false
		
		if self.days.size() > 360:
			buttons[CONSTANTS.YEAR].disabled = false
			
		
		statOutput[CONSTANTS.STATCONTAINER].visible = true
	else:
		buttons[CONSTANTS.STATBUTTON].disabled = true
		
		statOutput[CONSTANTS.STATCONTAINER].visible = false
		
		buttons[CONSTANTS.MONTH].disabled = true
		buttons[CONSTANTS.YEAR].disabled = true


func showEnd():
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	
	for button in buttons.values():
		button.disabled = true
#	buttons[CONSTANTS.STATBUTTON].disabled = true
#	buttons[CONSTANTS.ACTIONBUTTON].disabled = true
	
	
	var summaryOverview = getSummaryOverview()
	statOutput[CONSTANTS.SUMMARYOVERVIEW].plot_from_array(summaryOverview)
	statOutput[CONSTANTS.SUMMARY].text = getSummaryText(summaryOverview)
	
	var vaxSummary = getOutputVaccinations()
	statOutput[CONSTANTS.VAXSUMMARY].plot_from_array(vaxSummary)
	statOutput[CONSTANTS.VAXSUMMARYTEXT].text = getVaxSummaryText(vaxSummary)
	
	var deathSummary = getDeathSummary()
	statOutput[CONSTANTS.DEATHSUMMARY].plot_from_array(deathSummary)
	statOutput[CONSTANTS.DEATHSUMMARYTEXT].text = getDeathSummaryText(deathSummary)
	
	if !ended:
		ended = true
		establishEndLegends()
	
	statOutput[CONSTANTS.ENDCONTAINER].visible = true
	
	



func updateInterventionWeight():
	var value :int = 0
	if active.getName() == entities[CONSTANTS.DEU].getName():
		value += entities[CONSTANTS.DEU].getMaskAverage()
		value += entities[CONSTANTS.DEU].getHomeOfficeAverage()
		value += entities[CONSTANTS.DEU].getTestAverage()
		value += entities[CONSTANTS.DEU].getBorderAverage() * 2
	else:
		value += active.getSelectedMask()
		value += active.getSelectedHomeOffice()
		value += active.getSelectedTestRates()
		value += int(!active.getBorderOpen()) * 2 
	
	actionOutput[CONSTANTS.INTERVENTIONWEIGHT].value = value
	

func updateMap():
	
	if !godmode:
		statOutput[CONSTANTS.INCIDENCESCALETITLE].text = CONSTANTS.INCIDENCESCALETITLE + CONSTANTS.BL + "(" + CONSTANTS.TESTED + ")"
	else:
		statOutput[CONSTANTS.INCIDENCESCALETITLE].text = CONSTANTS.INCIDENCESCALETITLE + "\n"
	
	
	var incidences = []
	for entity in entities.values():
		incidences.append(entity.get7DayIncidence(godmode))
		
	var i = 0
	for entity in entities.values():
		if incidences.max() > 0:
			entity.mapButton.material.set_shader_param("incidenceRatio", float(incidences[i]) / float(incidences.max()))
		else:
			entity.mapButton.material.set_shader_param("incidenceRatio", 0)
		i += 1
	
	# Berechnung Wert Superindikator: ((Höchste Inzidenz / Wert Superindikatorstufe) + Stufe Superindikator) / Anzahl Superindikatorstufen
	var superindicator :float
	var superindicatorStep = CONSTANTS.SUPERINDICATORSTEPS.bsearch(incidences.max())
#	print("SUPERINDICATORSTEP ", superindicatorStep)
	if superindicatorStep > 0:
		if superindicatorStep == CONSTANTS.SUPERINDICATORSTEPS.size():
			superindicator = ((incidences.max() / CONSTANTS.SUPERINDICATORSTEPS[superindicatorStep - 1]) + superindicatorStep) / float(CONSTANTS.SUPERINDICATORSTEPS.size())
		else:
			superindicator = ((incidences.max() / CONSTANTS.SUPERINDICATORSTEPS[superindicatorStep]) + superindicatorStep) / float(CONSTANTS.SUPERINDICATORSTEPS.size())
	else:
		superindicator = 0
	statOutput[CONSTANTS.MAPBACKGROUND].material.set_shader_param("superindicator", superindicator)
	
	
#	print("Inzidenz Deutschland ", incidences[incidences.size() -1], " // Inzidenz Durchschnitt: " , float(CONSTANTS.sum(incidences) - incidences[incidences.size() -1]) / 16.0)
	i = statOutput[CONSTANTS.INCIDENCELABELS].get_children().size()
	for label in statOutput[CONSTANTS.INCIDENCELABELS].get_children():
		label.text = String(stepify(incidences.max() * (i/float(statOutput[CONSTANTS.INCIDENCELABELS].get_children().size())), 0.1))
		i -= 1

func getMode():
	return self.mode

func setMode(newMode):
	self.mode = newMode

func isRestarted():
	return self.restarted

func getProjectedToRealPopulation(value):
	return int(round(value * self.activePopulationToRealFactor))

func getProjectedToCalculationPopulation(value):
	return int(round(round(value) * self.activePopulationToCalculationFactor))

#func getLoading():
#	return self.loading

func getOutputInterval():
	var dayArray = [CONSTANTS.DAYS]
	if self.days.size() < CONSTANTS.WEEK + 1:
		dayArray.append_array(self.days)
		dayArray.remove(1)
		return dayArray
	
	match self.interval:
		CONSTANTS.WEEK:
			for i in range(CONSTANTS.WEEK):
#				var index = (days.size() - 1 - CONSTANTS.WEEK + i)
				var index = (days.size() - CONSTANTS.WEEK + i)
				if index <= 0:
#				if (days.size() - CONSTANTS.WEEK + i) <= 0:
					continue
				else:
					dayArray.append(days[index])
		
		CONSTANTS.MONTH:
# warning-ignore:integer_division
			for i in range(CONSTANTS.MONTH / 3):
#				var index = (days.size() - 1 - CONSTANTS.MONTH + (i*3))
				var index = (days.size() - CONSTANTS.MONTH + (i*3))
				if index <= 0:
					continue
				else:
					dayArray.append(days[index])
		
		CONSTANTS.YEAR:
# warning-ignore:integer_division
			for i in range(CONSTANTS.YEAR / 12):
#				var index = (days.size() - 1 - CONSTANTS.YEAR + (i*12))
				var index = (days.size() - CONSTANTS.YEAR + (i*12))
				if index <= 0:
					continue
				else:
					dayArray.append(days[index])
		
		CONSTANTS.MAX:
			dayArray.append_array(self.days)
			dayArray.remove(1)
			return dayArray
			
	return dayArray

func getOutputOverview(dayArray):
	if godmode:
		var output = [dayArray]
#		var sus = [CONSTANTS.SUSCEPTIBLE]
		var susTested = [CONSTANTS.SUSCEPTIBLE + CONSTANTS.BL + CONSTANTS.TESTED]
		var inf = [CONSTANTS.INFECTED]
		var infTested = [CONSTANTS.INFECTED + CONSTANTS.BL + CONSTANTS.TESTED]
		var rec = [CONSTANTS.RECOVERED]
		var recTested = [CONSTANTS.RECOVERED + CONSTANTS.BL + CONSTANTS.TESTED]
		var dead = [CONSTANTS.DEAD]
		for i in range(1, dayArray.size()):
#			sus.append(getProjectedToRealPopulation(active.suscept[dayArray[i]]))
			
			var testedSus = active.sus1[dayArray[i]]
			susTested.append(getProjectedToRealPopulation(testedSus))
			
			var testedInf = active.inf1[dayArray[i]] + active.getDailyOccupiedBeds(dayArray[i])
			infTested.append(getProjectedToRealPopulation(testedInf))
			
			var testedRec = active.rec1[dayArray[i]] + active.rec2[dayArray[i]]
			recTested.append(getProjectedToRealPopulation(testedRec))
			
			inf.append(getProjectedToRealPopulation(active.infect[dayArray[i]]))
			rec.append(getProjectedToRealPopulation(active.recov[dayArray[i]]))
			dead.append(getProjectedToRealPopulation(active.dead[dayArray[i]]))
#		output.append(sus)
		output.append(susTested)
		
		output.append(rec)
		output.append(recTested)
		
		output.append(inf)
		output.append(infTested)
		
		output.append(dead)
		
		var colors = PoolColorArray()
#		colors.append(Color(0.12, 1.00, 0.12, 1.00))
		colors.append(Color(0.0, 0.50, 0.0, 1.00))
		
		colors.append(Color(0.0, 0.50, 1.0, 1.00))
		colors.append(Color(0.0, 0.0, 0.5, 1.00))
		
		colors.append(Color(1.0, 0.0, 0.0, 1.00))
		colors.append(Color(0.5, 0.0, 0.0, 1.00))
		
		colors.append(Color(1.0, 1.0, 1.0, 1.00))
		statOutput[CONSTANTS.OVERVIEW].function_colors = colors
		
		return output
		
	else:
		# HIER STATT ALLEN ZAHLEN NUR GETESTETE FÄLLE
		var output = [dayArray]
#		var sus = [CONSTANTS.SUSCEPTIBLE]
		var susTested = [CONSTANTS.SUSCEPTIBLE + CONSTANTS.BL + CONSTANTS.TESTED]
		var infTested = [CONSTANTS.INFECTED + CONSTANTS.BL + CONSTANTS.TESTED]
#		var rec = [CONSTANTS.RECOVERED]
		var recTested = [CONSTANTS.RECOVERED + CONSTANTS.BL + CONSTANTS.TESTED]
		var dead = [CONSTANTS.DEAD]
		for i in range(1, dayArray.size()):
			var testedSus = active.sus1[dayArray[i]]
			susTested.append(getProjectedToRealPopulation(testedSus))
			
			var testedInf = active.inf1[dayArray[i]] + active.getDailyOccupiedBeds(dayArray[i])
			infTested.append(getProjectedToRealPopulation(testedInf))
#			rec.append(active.recov[dayArray[i]])
			
			var testedRec = active.rec1[dayArray[i]] + active.rec2[dayArray[i]]
			recTested.append(getProjectedToRealPopulation(testedRec))
			
			var confirmedDead = active.dead[dayArray[i]]
			dead.append(getProjectedToRealPopulation(confirmedDead))
#			sus.append(getProjectedToRealPopulation(active.getPopulation() - (testedInf + testedRec + confirmedDead)))
			
			
#		output.append(sus)
		output.append(susTested)
		output.append(recTested)
		output.append(infTested)
#		output.append(rec)
		output.append(dead)
		
		var colors = PoolColorArray()
#		colors.append(Color(0.12, 1.00, 0.12, 1.00))
		colors.append(Color(0.0, 0.50, 0.0, 1.00))
		colors.append(Color(0.0, 0.50, 1.0, 1.00))
		colors.append(Color(1.0, 0.0, 0.0, 1.00))
		colors.append(Color(1.0, 1.0, 1.0, 1.00))
		statOutput[CONSTANTS.OVERVIEW].function_colors = colors
		
		return output
		
#		var output = [dayArray]
#		var sus = [CONSTANTS.SUSCEPTIBLE]
#		var inf = [CONSTANTS.INFECTED]
#		var rec = [CONSTANTS.RECOVERED]
#		var dead = [CONSTANTS.DEAD]
#		for i in range(1, dayArray.size()):
#			sus.append(getProjectedToRealPopulation(active.suscept[dayArray[i]]))
#			inf.append(getProjectedToRealPopulation(active.infect[dayArray[i]]))
#			rec.append(getProjectedToRealPopulation(active.recov[dayArray[i]]))
#			dead.append(getProjectedToRealPopulation(active.dead[dayArray[i]]))
#		output.append(sus)
#		output.append(inf)
#		output.append(rec)
#		output.append(dead)
#		return output

func getOutputIncidence():
	return active.get7DayIncidence(godmode)

func getOutputR():
	var casesGen1:float = 0
	var casesGen2:float = 0
	if godmode:
		for i in range(CONSTANTS.WEEK):
			var indexGen1 = self.days[days.size() - 1] - CONSTANTS.WEEK + i
			var indexGen2 = indexGen1 - CONSTANTS.WEEK
			if indexGen1 > 2:
				casesGen1 += active.infect[indexGen1] - active.infect[indexGen1 - 1]
			if indexGen2 > 2:
				casesGen2 += active.infect[indexGen2] - active.infect[indexGen2 - 1] 
	
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
		return stepify((casesGen1/casesGen2), 0.01) if (casesGen1/casesGen2) > 0 else 0.0

func getOutputVaccinations():
	var sumUnvax = getProjectedToRealPopulation(active.getUnvaxedSum())
	var sumV1 = getProjectedToRealPopulation(active.getV1Sum())
	var sumV2 = getProjectedToRealPopulation(active.getV2Sum())
	return [[CONSTANTS.VAXSTATUS, "Anzahl Personen"], [CONSTANTS.UNVAXED, sumUnvax], [CONSTANTS.VAX1, sumV1], [CONSTANTS.VAX2, sumV2]]

func getDailyInfections(dayArray):
	var output = [dayArray]
	var newInfections = [CONSTANTS.NEWINFECTIONS]
	var newInfectionsTested = [CONSTANTS.NEWINFECTIONS + CONSTANTS.BL + CONSTANTS.TESTED]
	
	for i in range(1, dayArray.size()):
		if dayArray[i] >= 1:
			if godmode:
				newInfections.append(getProjectedToRealPopulation(active.getDailyInfections(dayArray[i], godmode)))
			newInfectionsTested.append(getProjectedToRealPopulation(active.getDailyInfections(dayArray[i], false)))
		else:
			if godmode:
				newInfections.append(0)
			newInfectionsTested.append(0)
	
	if godmode:
		output.append(newInfections)
	output.append(newInfectionsTested)
	
	var colors = PoolColorArray()
	
	colors.append(Color(1.0, 0.0, 0.0, 1.00))
	if godmode:
		colors.append(Color(0.5, 0.0, 0.0, 1.00))
	
	statOutput[CONSTANTS.NEWINFECTIONS].function_colors = colors
	
	var i :int = 0
	for child in statOutput[CONSTANTS.DAILYINFECTIONNUMBERS].get_children():
		match i:
			0:
				pass
			1:
				child.text = String(output[i][-1])
			2:
				child.visible = godmode
			3:
				child.visible = godmode
				if godmode:
					child.text = String(output[2][-1])
		i += 1
	
	return output

func getDailyVax(dayArray):
	var output = [dayArray]
	
	var newVaxxed1 = [CONSTANTS.FIRSTVAX]
	var newVaxxed2 = [CONSTANTS.SECONDVAX]
	
#	if dayArray.size() == ((CONSTANTS.YEAR/12.0) + 1):
#		pass
	
	for i in range(1, dayArray.size()):
		if dayArray[i] >= 1:

			newVaxxed1.append(getProjectedToRealPopulation(active.getDailyV1Difference(dayArray[i])))
			newVaxxed2.append(getProjectedToRealPopulation(active.getDailyV2Difference(dayArray[i])))

		else:

			newVaxxed1.append(0)
			newVaxxed2.append(0)
			
	output.append(newVaxxed1)
	output.append(newVaxxed2)
	
#	var colors = PoolColorArray()
#	
#	colors.append(Color(1.0, 0.0, 0.0, 1.00))
#	if godmode:
#		colors.append(Color(0.5, 0.0, 0.0, 1.0))
#	colors.append(Color(0.0, 0.50, 0.0, 1.00))
#	colors.append(Color(0.12, 1.00, 0.12, 1.00))
##	colors.append(Color(0.0, 0.50, 1.0, 1.00))
##	colors.append(Color(1.0, 0.0, 0.0, 1.00))
##	colors.append(Color(1.0, 1.0, 1.0, 1.00))
#	statOutput[CONSTANTS.DAILYCHANGES].function_colors = colors
	
	return output

func getHospitalOccupation(dayArray):
	var output = [dayArray]
	var hosp = [CONSTANTS.HOSPITALISED]
	var maxBeds = [CONSTANTS.HOSPBEDS]
	
	for i in range(1, dayArray.size()):
		hosp.append(getProjectedToRealPopulation(active.getDailyOccupiedBeds(dayArray[i])))
		maxBeds.append(getProjectedToRealPopulation(active.getHospitalBeds(dayArray[i])))
		
	output.append(maxBeds)
	output.append(hosp)
	
	return output


func getHospitalAllocation(dayArray):
	var allocation = active.getHospitalAllocation(dayArray[dayArray.size() - 1])
	return [[CONSTANTS.VAXSTATUS, "Anzahl Personen"], [CONSTANTS.UNVAXED + CONSTANTS.BL + CONSTANTS.HOSPITALISED, getProjectedToRealPopulation(allocation[0])], [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.HOSPITALISED, getProjectedToRealPopulation(allocation[1])], [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.HOSPITALISED, getProjectedToRealPopulation(allocation[2])]]

func getDeathOverview(dayArray):
	var output = [dayArray]
	var unvaxDeath = [CONSTANTS.UNVAXED + CONSTANTS.BL + CONSTANTS.DEAD]
	var vax1Death = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.DEAD]
	var vax2Death = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.DEAD]
	
	
	for i in range(1, dayArray.size()):
		unvaxDeath.append(getProjectedToRealPopulation(active.getUnvaxedDead(dayArray[i])))
		vax1Death.append(getProjectedToRealPopulation(active.getVax1Dead(dayArray[i])))
		vax2Death.append(getProjectedToRealPopulation(active.getVax2Dead(dayArray[i])))
	
	output.append(unvaxDeath)
	output.append(vax1Death)
	output.append(vax2Death)
	
	var i :int = 0
	for child in statOutput[CONSTANTS.DEATHNUMBERS].get_children():
		if i % 2 == 0:
			i += 1
			continue
		else:
			child.text = String(output[int(floor(i/2.0)) + 1][-1])
			i += 1
	
	
	return output


func getSummaryOverview():
	var sumSus = getProjectedToRealPopulation(active.getSusceptibles())
	var sumRecov = getProjectedToRealPopulation(active.getRecovered())
	var sumDead = getProjectedToRealPopulation(active.getDeaths())
	var sumInf = getProjectedToRealPopulation(active.getInfected())
	return [[CONSTANTS.HEALTHSTATUS, "Anzahl Personen"], [CONSTANTS.SUSCEPTIBLE, sumSus], [CONSTANTS.RECOVERED, sumRecov], [CONSTANTS.DEAD, sumDead], [CONSTANTS.INFECTED, sumInf]]

func getSummaryText(summary):
#	var sum :int = summary[1][1] + summary[2][1] + summary[3][1]
	var sum :int = getProjectedToRealPopulation(active.getPopulationBase())
	var str0 :String = "Die Pandemie hat %d Tage gedauert. \n \n" % self.endDay 
	var str1 :String = "%.2f%% der Bevölkerung haben sich nicht angesteckt. \n \n" % ((float(summary[1][1])/sum) * 100)
	var str2 :String = "%.2f%% der Bevölkerung sind Genesen. \n \n" % ((float(summary[2][1])/sum) * 100)
	var str3 :String = "%.2f%% der Bevölkerung sind am Virus gestorben.\n \n" % ((float(summary[3][1])/sum) * 100)
#	var str4 :String = "Damit wurden %.2f%% der Menschen mit dem Virus infiziert." % ((float(summary[2][1] + summary[3][1])/sum) * 100)
	var str4 :String = "Damit wurden %.2f%% der Menschen mit dem Virus infiziert." % (((float(summary[2][1])/sum) * 100) + ((float(summary[3][1])/sum) * 100))
	
	return str0 + str1 + str2 + str3 + str4

func getVaxSummaryText(summary):
	var sum :int = summary[1][1] + summary[2][1] + summary[3][1]
	var vaxSum = summary[2][1] + summary[3][1]
	var str0 :String = "Insgesamt haben %.2f%% der Bevölkerung Impfungen erhalten. Dabei wurden %d Impfdosen verbraucht. \n \n" %  [((float(vaxSum) / getProjectedToRealPopulation(active.getPopulation())) * 100), summary[2][1] + summary[3][1] * 2]
	var str1 :String = "%.2f%% der Bevölkerung wurden nicht geimpft. \n \n" % ((float(summary[1][1])/sum) * 100)
	var str2 :String = "%.2f%% der Bevölkerung wurden 1x geimpft. \n \n" % ((float(summary[2][1])/sum) * 100)
	var str3 :String = "%.2f%% der Bevölkerung wurden 2x geimpft." % ((float(summary[3][1])/sum) * 100)
	
	return str0 + str1 + str2 + str3

func getDeathSummary():
	return [[CONSTANTS.VAXSTATUS, "Anzahl Personen"], [CONSTANTS.UNVAXED, getProjectedToRealPopulation(active.getUnvaxedDead())], [CONSTANTS.VAX1, getProjectedToRealPopulation(active.getVax1Dead())], [CONSTANTS.VAX2, getProjectedToRealPopulation(active.getVax2Dead())]]

func getDeathSummaryText(summary):
	var sum :int = summary[1][1] + summary[2][1] + summary[3][1]
	var str0 :String = "Insgesamt sind %.2f%% der Bevölkerung verstorben. Davon waren %.2f%% mindestens einmal geimpft. \n \n" %  [(float(sum) / getProjectedToRealPopulation(active.getPopulationBase())) * 100, (float(summary[2][1] + summary[3][1]) / sum) * 100]
	var str1 :String = "%.2f%% der Verstorbenen war nicht geimpft. \n \n" % ((float(summary[1][1])/sum) * 100)
	var str2 :String = "%.2f%% der Verstorbenen war 1x geimpft. \n \n" % ((float(summary[2][1])/sum) * 100)
	var str3 :String = "%.2f%% der Verstorbenen war 2x geimpft." % ((float(summary[3][1])/sum) * 100)
	
	return str0 + str1 + str2 + str3
###############################################################################

func simulate():
	print("\n", "DAY ", currentDay + 1, " HAS STARTED")
	var startTime = OS.get_ticks_msec()
	
	entities[CONSTANTS.DEU].simulateALL()
	
	if self.days.size() > 2:
		if entities[CONSTANTS.DEU].infect[self.currentDay] < 1:
			setMode(CONSTANTS.ENDMODE)
			if !ended:
				endDay = currentDay
#				ended = true
			print("Tag ", self.currentDay, ": PANDEMIE VORÜBER")
		
	updateDay()
	
	match getMode():
		CONSTANTS.STATMODE:
			showStats()
		CONSTANTS.ACTIONMODE:
			showAction()
		CONSTANTS.ENDMODE:
			showEnd()
	
	var endTime = OS.get_ticks_msec()
	var timeDiff = endTime - startTime
	print("%23s SIMULATION OF DAY " % "", days[-1], " TOOK: ", floor(timeDiff/1000.0/60.0/60), ":", int(timeDiff/1000.0/60.0)%60, ":", int(timeDiff/1000.0)%60, ":%003d" % (int(timeDiff) % 1000))



func updateDay():
	self.currentDay += 1
	days.append(self.currentDay)
	statOutput[CONSTANTS.DAYS].text = CONSTANTS.DAYS + CONSTANTS.BL + String(self.currentDay)
	
	if self.days.size() > 3:
		buttons[CONSTANTS.STATBUTTON].disabled = false
		
#	self.currentDay += 1

#func rewindWeek():
#	for _i in range(CONSTANTS.WEEK):
#		entities[CONSTANTS.DEU].rewindAll()

func restart():
	self.restarted = true
	
	for button in buttons.values():
		button.disabled = false
	
	buttons[CONSTANTS.STATBUTTON].disabled = true
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	
	self.godmodeChanged = true
#	self.establishedLegends = false
	
	entities[CONSTANTS.DEU].restartAll()
	
	self.currentDay = 1
	self.days.clear()
	statOutput[CONSTANTS.DAYS].text = CONSTANTS.DAYS + CONSTANTS.BL + String(self.currentDay)
	
	self.interval = CONSTANTS.WEEK
	
	setMode(CONSTANTS.STATMODE)
	self.ended = false
	
	active = entities[CONSTANTS.DEU]
	activate()
	
	statOutput[CONSTANTS.STATCONTAINER].visible = false
	actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
	self.restarted = false




func activate():
	statOutput[CONSTANTS.COUNTRYNAME].text = active.name
	self.activePopulationToRealFactor = active.getPopulationToRealFactor()
	self.activePopulationToCalculationFactor = active.getPopulationToCalculationFactor()

	match getMode():
		CONSTANTS.STATMODE:
			showStats()
		CONSTANTS.ACTIONMODE:
			showAction()
		CONSTANTS.ENDMODE:
			showEnd()


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





func _on_NO_toggled(pressed:bool):
	if pressed:
		lockdownSelection(0)
#		active.setSelectedMask(0)
#		active.setSelectedHomeOffice(0)
#
#		actionOutput[CONSTANTS.MASKOPTION].select(0)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(0)
#
#		active.setOptionChanged(false)
#		_on_mask_selected(0)
#		_on_homeOffice_selected(0)
		
#		self.optionChanged = false
#		self.lockdownFactor = self.selectedLockdown[0]
#
#		self.selectedMask = 0
#		self.selectedHomeOffice = 0
#
#		actionOutput[CONSTANTS.MASKOPTION].select(self.selectedMask)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(self.selectedHomeOffice)
#		active.setCommuterFactor(commuterFactors[self.selectedHomeOffice])
#
#		self.optionChanged = false
#
#		active.setLockdown(getIsLockdown(), getLockdownStrictness())

func _on_LIGHT_toggled(pressed:bool):
	if pressed:
		lockdownSelection(1)
#		active.setSelectedMask(1)
#		active.setSelectedHomeOffice(1)
#
#		actionOutput[CONSTANTS.MASKOPTION].select(1)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(1)
#
#		active.setOptionChanged(false)
#		_on_mask_selected(1)
#		_on_homeOffice_selected(1)
		
#		self.optionChanged = false
#		self.lockdownFactor = self.selectedLockdown[1]
#
#		self.selectedMask = 1
#		self.selectedHomeOffice = 1
#
#		actionOutput[CONSTANTS.MASKOPTION].select(self.selectedMask)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(self.selectedHomeOffice)
#		active.setCommuterFactor(commuterFactors[self.selectedHomeOffice])
#
#		self.optionChanged = false
#
#		active.setLockdown(getIsLockdown(), getLockdownStrictness())

func _on_MEDIUM_toggled(pressed:bool):
	if pressed:
		lockdownSelection(2)
#		active.setSelectedMask(2)
#		active.setSelectedHomeOffice(2)
#
#		actionOutput[CONSTANTS.MASKOPTION].select(2)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(2)
#
#		active.setOptionChanged(false)
#		_on_mask_selected(2)
#		_on_homeOffice_selected(2)
		
#		self.optionChanged = false
#		self.lockdownFactor = self.selectedLockdown[2]
#
#		self.selectedMask = 2
#		self.selectedHomeOffice = 2
#
#		actionOutput[CONSTANTS.MASKOPTION].select(self.selectedMask)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(self.selectedHomeOffice)
#		active.setCommuterFactor(commuterFactors[self.selectedHomeOffice])
#
#		self.optionChanged = false
#
#		active.setLockdown(getIsLockdown(), getLockdownStrictness())

func _on_HEAVY_toggled(pressed:bool):
	if pressed:
		lockdownSelection(3)
#		active.setSelectedMask(3)
#		active.setSelectedHomeOffice(3)
#
#		actionOutput[CONSTANTS.MASKOPTION].select(3)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(3)
#
#		active.setOptionChanged(false)
#		_on_mask_selected(3)
#		_on_homeOffice_selected(3)
		
#		self.optionChanged = false
#		self.lockdownFactor = self.selectedLockdown[3]
#
#		self.selectedMask = 3
#		self.selectedHomeOffice = 3
#		actionOutput[CONSTANTS.MASKOPTION].select(self.selectedMask)
#		actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(self.selectedHomeOffice)
#		active.setCommuterFactor(commuterFactors[self.selectedHomeOffice])
#
#
#
#		self.optionChanged = false
#
#		active.setLockdown(getIsLockdown(), getLockdownStrictness())

func _on_USERDEFINED_toggled(pressed:bool):
	if pressed:
		pass
#		self.optionChanged = false
#		self.lockdownFactor = self.selectedLockdown[int(CONSTANTS.average([self.selectedMask, self.selectedHomeOffice]))]
##		active.setCommuterFactor(commuterFactors[self.selectedHomeOffice])
#
#		active.setLockdown(getIsLockdown(), getLockdownStrictness())

func lockdownSelection(index:int):
	active.setSelectedMask(index)
	active.setSelectedHomeOffice(index)
	
	actionOutput[CONSTANTS.MASKOPTION].select(index)
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].select(index)
	
	entities[CONSTANTS.DEU].setOptionChanged(true)
	active.setOptionChanged(false)
	updateInterventionWeight()

func _on_borderControl_toggle(button_pressed:bool):
	if active.getName() == entities[CONSTANTS.DEU].getName():
		if entities[CONSTANTS.DEU].getBorderOpen() is int:
			if button_pressed:
				entities[CONSTANTS.DEU].setBorderOpen(false)
		else:
			active.setBorderOpen(!button_pressed)
#	if active.getName() == entities[CONSTANTS.DEU].getName() and entities[CONSTANTS.DEU].getBorderOpen() is int:
#		pass
#	if active.getName() == entities[CONSTANTS.DEU].getName() and entities[CONSTANTS.DEU].getOptionChanged():
#		pass
#	else:
#		active.setBorderOpen(!button_pressed)
#	self.optionChanged = true
#	self.selectedHomeOffice = 4
#	print("Border Control ", button_pressed)
	else:
		active.setBorderOpen(!button_pressed)
	
	updateInterventionWeight()
	showAction()


func _on_mask_selected(index:int):
	entities[CONSTANTS.DEU].setOptionChanged(true)
	
	active.setOptionChanged(true)
	active.setSelectedMask(index)

	showAction()

func _on_homeOffice_selected(index:int):
	entities[CONSTANTS.DEU].setOptionChanged(true)
	
	active.setOptionChanged(true)
	active.setSelectedHomeOffice(index)

	showAction()

func _on_testScenario_selected(index:int):
	active.setTestRates(index)
	updateInterventionWeight()
#	showAction()


func _on_vaxProduction_changed(value:float):
#	entities[CONSTANTS.DEU].setVaxProduction(int(value))
	entities[CONSTANTS.DEU].setVaxProduction(getProjectedToCalculationPopulation(int(value)))

func _on_hospitalBed_changed(value:float):
	if actionOutput[CONSTANTS.HOSPITALBEDSPINBOX].editable and value != getProjectedToRealPopulation(entities[CONSTANTS.DEU].getHospitalBeds(self.days.max() if self.days.max() != null else 0)):
#		entities[CONSTANTS.DEU].setHospitalBeds(self.days.max() if self.days.max() != null else 0, int(value))
#		actionOutput[CONSTANTS.HOSPITALBEDSPINBOX].value = entities[CONSTANTS.DEU].getHospitalBeds(self.days.max() if self.days.max() != null else 0)
		entities[CONSTANTS.DEU].setHospitalBeds(self.days.max() if self.days.max() != null else 0, getProjectedToCalculationPopulation(int(value)))
#		actionOutput[CONSTANTS.HOSPITALBEDSPINBOX].value = getProjectedToRealPopulation(entities[CONSTANTS.DEU].getHospitalBeds(self.days.max() if self.days.max() != null else 0))
		actionOutput[CONSTANTS.OCCBEDS].text = String(getProjectedToRealPopulation(active.getDailyOccupiedBeds(self.days.max() if self.days.max() != null else -1))) + " / " + String(getProjectedToRealPopulation(active.getHospitalBeds()))

func _on_godmode_toggled(pressed:bool):
	self.godmodeChanged = true
	self.godmode = pressed
	updateMap()


func add_options(isGermany:bool):
	if isGermany:
		actionOutput[CONSTANTS.MASKOPTION].add_separator()
		actionOutput[CONSTANTS.MASKOPTION].add_item("Verschiedene Regelungen in den Bundesländern")
		actionOutput[CONSTANTS.MASKOPTION].set_item_disabled(5, true)
		
		actionOutput[CONSTANTS.HOMEOFFICEOPTION].add_separator()
		actionOutput[CONSTANTS.HOMEOFFICEOPTION].add_item("Verschiedene Regelungen in den Bundesländern")
		actionOutput[CONSTANTS.HOMEOFFICEOPTION].set_item_disabled(5, true)
		
		actionOutput[CONSTANTS.TESTOPTION].add_separator()
		actionOutput[CONSTANTS.TESTOPTION].add_item("Verschiedene Regelungen in den Bundesländern")
		actionOutput[CONSTANTS.TESTOPTION].set_item_disabled(5, true)
		
	else:
		actionOutput[CONSTANTS.MASKOPTION].remove_item(5)
		actionOutput[CONSTANTS.MASKOPTION].remove_item(4)
		
		actionOutput[CONSTANTS.HOMEOFFICEOPTION].remove_item(5)
		actionOutput[CONSTANTS.HOMEOFFICEOPTION].remove_item(4)
		
		actionOutput[CONSTANTS.TESTOPTION].remove_item(5)
		actionOutput[CONSTANTS.TESTOPTION].remove_item(4)
		
		

func _establish_mask_options():
	actionOutput[CONSTANTS.MASKOPTION].add_item("Keine Masken")
	actionOutput[CONSTANTS.MASKOPTION].add_item("Stoffmasken, Schals, etc.")
	actionOutput[CONSTANTS.MASKOPTION].add_item("OP-Masken")
	actionOutput[CONSTANTS.MASKOPTION].add_item("FFP2-Masken")
#	actionOutput[CONSTANTS.MASKOPTION].add_separator()
#	actionOutput[CONSTANTS.MASKOPTION].add_item("Verschiedene Regelungen in den Bundesländern")
	
#	actionOutput[CONSTANTS.MASKOPTION].get_popup().set_item_tooltip(0, ".")

func _establish_homeOffice_options():
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].add_item("Keine Vorgabe")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].add_item("Empfehlung zum Home-Office")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].add_item("Verpflichtung zum Home-Office")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].add_item("Schließung nicht kritischer Betriebe")
	
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].get_popup().set_item_tooltip(0, "Jeder Arbeitnehmer kann ganz normal zur Arbeit gehen.")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].get_popup().set_item_tooltip(1, "Jedem Arbeitnehmer wird empfohlen von zu Hause zu arbeiten, vorausgesetzt der Beruf lässt es zu.")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].get_popup().set_item_tooltip(2, "Jeder Arbeitnehmer wird verpflichtet von zu Hause zu arbeiten, vorausgesetzt der Beruf lässt es zu.")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].get_popup().set_item_tooltip(3, "Alle Betriebe, außer kritischer Infrastruktur, werden geschlossen. Arbeitnehmer bleiben zu Hause.")

func _establish_test_options():
	actionOutput[CONSTANTS.TESTOPTION].add_item("Keine Tests")
	actionOutput[CONSTANTS.TESTOPTION].add_item("	Tests für Zugang zu öffentlichen Einrichtungen")
	actionOutput[CONSTANTS.TESTOPTION].add_item("+	Regelmäßige Tests in Schulen und Arbeitsstätten")
	actionOutput[CONSTANTS.TESTOPTION].add_item("+	Tests für private Treffen")
	
	
func establishActions():
	_establish_mask_options()
	_establish_homeOffice_options()
	_establish_test_options()
	

func _show_overview_legend():
	if godmodeChanged:
		var i :int = 0
		for child in statOutput[CONSTANTS.OVERVIEWLEGEND].get_children():
			if i < 2:
				i += 1
				continue
			else:
				statOutput[CONSTANTS.OVERVIEWLEGEND].remove_child(child)
				child.queue_free()
	
	for function in statOutput[CONSTANTS.OVERVIEW].get_legend():
		statOutput[CONSTANTS.OVERVIEWLEGEND].add_child(function)
	

func _show_vaxStatus_legend():
	if godmodeChanged:
		var i :int = 0
		for child in statOutput[CONSTANTS.VAXSTATUSLEGEND].get_children():
			if i < 2:
				i += 1
				continue
			else:
				statOutput[CONSTANTS.VAXSTATUSLEGEND].remove_child(child)
				child.queue_free()
				
	for function in statOutput[CONSTANTS.VAXSTATUS].get_legend():
		statOutput[CONSTANTS.VAXSTATUSLEGEND].add_child(function)

func _show_newInfections_legend():
	if godmodeChanged:
		var i :int = 0
		for child in statOutput[CONSTANTS.NEWINFECTIONSLEGEND].get_children():
			if i < 2:
				i += 1
				continue
			else:
				statOutput[CONSTANTS.NEWINFECTIONSLEGEND].remove_child(child)
				child.queue_free()
	
	for function in statOutput[CONSTANTS.NEWINFECTIONS].get_legend():
		statOutput[CONSTANTS.NEWINFECTIONSLEGEND].add_child(function)

func _show_daily_legend():
	if godmodeChanged:
		var i :int = 0
		for child in statOutput[CONSTANTS.DAILYLEGEND].get_children():
			if i < 2:
				i += 1
				continue
			else:
				statOutput[CONSTANTS.DAILYLEGEND].remove_child(child)
				child.queue_free()
	
	for function in statOutput[CONSTANTS.DAILYVAXCHANGES].get_legend():
		statOutput[CONSTANTS.DAILYLEGEND].add_child(function)

func _show_bedAllocation_legend():
	
	statOutput[CONSTANTS.HOSPITALALLOCATION].plot_from_array(getHospitalAllocation([0,1]))
	
	if godmodeChanged:
		var i :int = 0
		for child in statOutput[CONSTANTS.ALLOCATIONLEGEND].get_children():
			if i < 2:
				i += 1
				continue
			else:
				statOutput[CONSTANTS.ALLOCATIONLEGEND].remove_child(child)
				child.queue_free()
	
	for function in statOutput[CONSTANTS.HOSPITALALLOCATION].get_legend():
		statOutput[CONSTANTS.ALLOCATIONLEGEND].add_child(function)

func _show_beds_legend():
	if godmodeChanged:
		var i :int = 0
		for child in statOutput[CONSTANTS.BEDSLEGEND].get_children():
			if i < 2:
				i += 1
				continue
			else:
				statOutput[CONSTANTS.BEDSLEGEND].remove_child(child)
				child.queue_free()
	
	for function in statOutput[CONSTANTS.HOSPBEDS].get_legend():
		statOutput[CONSTANTS.BEDSLEGEND].add_child(function)

func _show_death_legend():
	if godmodeChanged:
		var i :int = 0
		for child in statOutput[CONSTANTS.DEATHLEGEND].get_children():
			if i < 2:
				i += 1
				continue
			else:
				statOutput[CONSTANTS.DEATHLEGEND].remove_child(child)
				child.queue_free()
	
	for function in statOutput[CONSTANTS.DEATHOVERVIEW].get_legend():
		statOutput[CONSTANTS.DEATHLEGEND].add_child(function)


func establishStatLegends():
	_show_overview_legend()
	_show_vaxStatus_legend()
	_show_newInfections_legend()
	_show_daily_legend()
	_show_bedAllocation_legend()
	_show_beds_legend()
	_show_death_legend()
	
	print("StatLegends established")


func _show_summary_legend():
	for function in statOutput[CONSTANTS.SUMMARYOVERVIEW].get_legend():
		statOutput[CONSTANTS.SUMMARYOVERVIEWLEGEND].add_child(function)

func _show_vaxSummary_legend():
	for function in statOutput[CONSTANTS.VAXSUMMARY].get_legend():
		statOutput[CONSTANTS.VAXSUMMARYLEGEND].add_child(function)

func _show_deathSummary_legend():
	for function in statOutput[CONSTANTS.DEATHSUMMARY].get_legend():
		statOutput[CONSTANTS.DEATHSUMMARYLEGEND].add_child(function)

func establishEndLegends():
	_show_summary_legend()
	_show_vaxSummary_legend()
	_show_deathSummary_legend()
	
	print("EndLegends established")

func _on_restart_pressed():
	actionOutput[CONSTANTS.CONFIRMRESTART].popup_centered_ratio(0.2)

func _on_restart_confirmed():
	print("Restarting")
	restart()
	

func _on_Time_timeout():
#	print(OS.get_ticks_msec()/1000, " secs // or ", OS.get_ticks_msec()/60000, " minutes // ", OS.get_ticks_msec())
	showStats()
	statOutput[CONSTANTS.TIMER].stop()


func connectSignals():
	statOutput[CONSTANTS.TIMER].set_wait_time(0.05)
	statOutput[CONSTANTS.TIMER].connect("timeout", self, "_on_Time_timeout")
	statOutput[CONSTANTS.TIMER].start()
	
	
	actionOutput[CONSTANTS.NO].connect("toggled", self, "_on_NO_toggled")
	actionOutput[CONSTANTS.LIGHT].connect("toggled", self, "_on_LIGHT_toggled")
	actionOutput[CONSTANTS.MEDIUM].connect("toggled", self, "_on_MEDIUM_toggled")
	actionOutput[CONSTANTS.HEAVY].connect("toggled", self, "_on_HEAVY_toggled")
	actionOutput[CONSTANTS.USERDEFINED].connect("toggled", self, "_on_USERDEFINED_toggled")
	
	actionOutput[CONSTANTS.BORDERCONTROL].connect("toggled", self, "_on_borderControl_toggle")
	
	actionOutput[CONSTANTS.MASKOPTION].connect("item_selected", self, "_on_mask_selected")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION].connect("item_selected", self, "_on_homeOffice_selected")
	
	actionOutput[CONSTANTS.TESTOPTION].connect("item_selected", self, "_on_testScenario_selected")
	
	actionOutput[CONSTANTS.VAXPRODUCTIONSPINBOX].connect("value_changed", self, "_on_vaxProduction_changed")
	actionOutput[CONSTANTS.VAXPRODUCTIONSPINBOX].step = int(round(self.activePopulationToRealFactor))
	
	actionOutput[CONSTANTS.HOSPITALBEDSPINBOX].connect("value_changed", self, "_on_hospitalBed_changed")
	actionOutput[CONSTANTS.HOSPITALBEDSPINBOX].step = int(round(self.activePopulationToRealFactor)) * entities[CONSTANTS.DEU].states.values().size()
	
	actionOutput[CONSTANTS.GODMODEBUTTON].connect("toggled", self, "_on_godmode_toggled")
	actionOutput[CONSTANTS.RESTARTBUTTON].connect("pressed", self, "_on_restart_pressed")
	actionOutput[CONSTANTS.CONFIRMRESTART].connect("confirmed", self, "_on_restart_confirmed")
	actionOutput[CONSTANTS.ENDRESTART].connect("pressed", self, "_on_restart_pressed")
	
	buttons[CONSTANTS.STATBUTTON].connect("pressed", self, "_on_statButton_press")
	buttons[CONSTANTS.ACTIONBUTTON].connect("pressed", self, "_on_actionButton_press")
	
	buttons[CONSTANTS.WEEK].connect("pressed", self, "_on_weekButton_press")
	buttons[CONSTANTS.MONTH].connect("pressed", self, "_on_monthButton_press")
	buttons[CONSTANTS.YEAR].connect("pressed", self, "_on_yearButton_press")
	buttons[CONSTANTS.MAX].connect("pressed", self, "_on_maxButton_press")


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
	
	print("Signals connected")
