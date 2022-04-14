extends Panel

var calculationTimer :Timer

var paused	:bool = false

var pause
var play
var playspeedx2

var running :bool = false
var statsLoading :bool = false

var menu

var bawu
var bayern
var berlin
var brand
var bremen
var hamb
var hessen
var meckPom
var nieders
var nrw
var rlp
var saar
var sachsen
var sacanh
var schlHol
var thur

var deu
var states

var game_manager

var remainingDays

var statOutput = {}
var actionOutput = {}
var buttons = {}

var populationFactor :float

# Called when the node enters the scene tree for the first time.
func _ready():
	
	populationFactor = Constants.POPULATIONFACTOR
	
	remainingDays = -1
	
	menu = get_node("Menu")
	
#	Time Control Buttons
	pause = get_node("TimeControls/Pause")
	play = get_node("TimeControls/Play")
	playspeedx2 = get_node("TimeControls/PlaySpeedx2")

	pause.connect("pressed", self, "_on_Pause_pressed")
	play.connect("pressed", self, "_on_Play_pressed")
	playspeedx2.connect("pressed", self, "_on_PlaySpeedx2_pressed")
	
	menu.connect("pressed", self, "_on_menu_pressed")
	
	statOutput[CONSTANTS.TIMER] = get_node("Time")
	
	statOutput[CONSTANTS.MAPBACKGROUND] = get_node("Map")
	
	statOutput[CONSTANTS.STATCONTAINER] = get_node("Statistics")
	statOutput[CONSTANTS.COUNTRYNAME] = get_node("CountryName")
	statOutput[CONSTANTS.OVERVIEW] = get_node("Statistics/GridContainer/Overview")
	statOutput[CONSTANTS.OVERVIEWLEGEND] = get_node("Statistics/GridContainer/Indicators/OverviewContainer/OverviewLegend")
	statOutput[CONSTANTS.OVERVIEWHEADLINE] = get_node("Statistics/GridContainer/Indicators/OverviewContainer/Overview")
	statOutput[CONSTANTS.VAXSTATUS] = get_node("Statistics/GridContainer/VaxStatusContainer/VaxStatus")
	statOutput[CONSTANTS.VAXSTATUSLEGEND] = get_node("Statistics/GridContainer/VaxStatusContainer/VaxLegendContainer/VaxStatusLegend")
	statOutput[CONSTANTS.NEWINFECTIONS] = get_node("Statistics/GridContainer/DailyInfections")
	statOutput[CONSTANTS.NEWINFECTIONSLEGEND] = get_node("Statistics/GridContainer/DailyInfectionsContainer/GridContainer/DailyInfectionsLegend")
	statOutput[CONSTANTS.DAILYINFECTIONNUMBERS] = get_node("Statistics/GridContainer/DailyInfectionsContainer/GridContainer/DailyInfectionNumbers")
	statOutput[CONSTANTS.DAILYVAXCHANGES] = get_node("Statistics/GridContainer/DailyChanges")
	statOutput[CONSTANTS.DAILYLEGEND] = get_node("Statistics/GridContainer/VaxStatusContainer/DailyLegendContainer/DailyLegend")
	
	statOutput[CONSTANTS.PROGRESSBAR] = get_node("SimProgress")
	statOutput[CONSTANTS.PROGRESSPANEL] = get_node("SimProgress/ProgressPanel")
	statOutput[CONSTANTS.SIMANIMATION] = get_node("SimProgress/ProgressPanel/SimAnimation")
	statOutput[CONSTANTS.DAYS] = get_node("SimProgress/CurrentDay")
	
	statOutput[CONSTANTS.INCIDENCESCALETITLE] = get_node("Map/ScaleContainer/IncidenceScaleTitle")
	statOutput[CONSTANTS.INCIDENCELABELS] = get_node("Map/ScaleContainer/ScaleContainer/IncidenceLabels")
	
	statOutput[CONSTANTS.INCIDENCE] = get_node("Statistics/GridContainer/Indicators/IncidenceContainer/IncidenceNr")
	statOutput[CONSTANTS.RVALUE] = get_node("Statistics/GridContainer/Indicators/RContainer/RNr")
	statOutput[CONSTANTS.BEDSTATUS] = get_node("Statistics/GridContainer/BedsOverview/BedsLegendContainer/BedNr")
	statOutput[CONSTANTS.HOSPBEDS] = get_node("Statistics/GridContainer/HospBeds")
	statOutput[CONSTANTS.HOSPITALALLOCATION] = get_node("Statistics/GridContainer/BedsOverview/HospitalAllocation")
	statOutput[CONSTANTS.ALLOCATIONPLACEHOLER] = get_node("Statistics/GridContainer/BedsOverview/AllocationPlaceHolder")
	statOutput[CONSTANTS.ALLOCATIONLEGEND] = get_node("Statistics/GridContainer/BedsOverview/BedAllocationContainer/AllocationLegend")
	statOutput[CONSTANTS.BEDSLEGEND] = get_node("Statistics/GridContainer/BedsOverview/BedsLegendContainer/BedsLegend")
	statOutput[CONSTANTS.DEATHOVERVIEW] = get_node("Statistics/GridContainer/DeathOverview")
	statOutput[CONSTANTS.DEATHLEGEND] = get_node("Statistics/GridContainer/DeathContainer/DeathLegendContainer/DeathLegend")
	statOutput[CONSTANTS.DEATHNUMBERS] = get_node("Statistics/GridContainer/DeathContainer/DeathLegendContainer/DeathNumbers")
	
	
	statOutput[CONSTANTS.ENDCONTAINER] = get_node("EndScreen")
	statOutput[CONSTANTS.SUMMARYOVERVIEW] = get_node("EndScreen/GridContainer/SummaryContainer/SummaryOverview")
	statOutput[CONSTANTS.SUMMARYOVERVIEWLEGEND] = get_node("EndScreen/GridContainer/SummaryContainer/SummaryOverviewLegend")
	statOutput[CONSTANTS.SUMMARY] = get_node("EndScreen/GridContainer/SummaryContainer/Summary")
	
	statOutput[CONSTANTS.VAXSUMMARY] = get_node("EndScreen/GridContainer/VaxSummaryContainer/VaxSummary")
	statOutput[CONSTANTS.VAXSUMMARYLEGEND] = get_node("EndScreen/GridContainer/VaxSummaryContainer/VaxSummaryLegend")
	statOutput[CONSTANTS.VAXSUMMARYTEXT] = get_node("EndScreen/GridContainer/VaxSummaryContainer/VaxSummaryText")
	
	statOutput[CONSTANTS.DEATHSUMMARY] = get_node("EndScreen/GridContainer/DeathSummaryContainer/DeathSummary")
	statOutput[CONSTANTS.DEATHSUMMARYLEGEND] = get_node("EndScreen/GridContainer/DeathSummaryContainer/DeathSummaryLegend")
	statOutput[CONSTANTS.DEATHSUMMARYTEXT] = get_node("EndScreen/GridContainer/DeathSummaryContainer/DeathSummaryText")
	
	statOutput[CONSTANTS.CHRONIC] = get_node("EndScreen/GridContainer/ChronicContainer/Chronic")
	statOutput[CONSTANTS.CHRONICLEGEND] = get_node("EndScreen/GridContainer/ChronicContainer/ChronicLegend")
	statOutput[CONSTANTS.CHRONICSUMMARYTEXT] = get_node("EndScreen/GridContainer/ChronicContainer/ChronicSummary")
	
	
	actionOutput[CONSTANTS.NO] = get_node("PlayControls/GridContainer/LockDownOptions/No")
	actionOutput[CONSTANTS.LIGHT] = get_node("PlayControls/GridContainer/LockDownOptions/Light")
	actionOutput[CONSTANTS.MEDIUM] = get_node("PlayControls/GridContainer/LockDownOptions/Medium")
	actionOutput[CONSTANTS.HEAVY] = get_node("PlayControls/GridContainer/LockDownOptions/Heavy")
	actionOutput[CONSTANTS.USERDEFINED] = get_node("PlayControls/GridContainer/LockDownOptions/Userdefined")
	
	actionOutput[CONSTANTS.INTERVENTIONWEIGHT] = get_node("InterventionWeight")
	
	actionOutput[CONSTANTS.ACTIONCONTAINER] = get_node("PlayControls")
	actionOutput[CONSTANTS.OPTIONBUTTON] = get_node("PlayControls/GridContainer/OptionContainer/MaskOption/OptionButton")
	actionOutput[CONSTANTS.LOCKDOWNOPTION] = get_node("PlayControls/GridContainer/LockDownOptions")
	actionOutput[CONSTANTS.MASKOPTION] = get_node("PlayControls/GridContainer/OptionContainer/MaskOption/OptionButton")
	actionOutput[CONSTANTS.HOMEOFFICEOPTION] = get_node("PlayControls/GridContainer/OptionContainer/HomeOfficeOption/OptionButton")
	actionOutput[CONSTANTS.HOSPITALBEDSPINBOX] = get_node("PlayControls/GridContainer/GridContainer/BedContainer/HospitalBeds")
	actionOutput[CONSTANTS.VAXPRODUCTIONSPINBOX] = get_node("PlayControls/GridContainer/GridContainer/VaxContainer/VaxProduction")
	actionOutput[CONSTANTS.TESTOPTION] = get_node("PlayControls/GridContainer/TestOption/OptionButton")
	actionOutput[CONSTANTS.BORDERCONTROL] = get_node("PlayControls/GridContainer/OptionContainer/HomeOfficeOption/BorderControl")
	actionOutput[CONSTANTS.BORDERTIP] = get_node("PlayControls/GridContainer/OptionContainer/HomeOfficeOption/BorderControlTip")
	actionOutput[CONSTANTS.OCCBEDS] = get_node("PlayControls/GridContainer/GridContainer/BedContainer/HospitalBedsNumber")
	actionOutput[CONSTANTS.AVLBLVAX] = get_node("PlayControls/GridContainer/GridContainer/VaxContainer/VaxNumber")
	
	actionOutput[CONSTANTS.GODMODEBUTTON] = get_node("PlayControls/GridContainer/GodmodeContainer/GodmodeButton")
	actionOutput[CONSTANTS.RESTARTBUTTON] = get_node("PlayControls/GridContainer/GodmodeContainer/RestartButton")
	actionOutput[CONSTANTS.CONFIRMRESTART] = get_node("PlayControls/GridContainer/GodmodeContainer/RestartButton/ConfirmRestart")
	actionOutput[CONSTANTS.ENDRESTART] = get_node("EndScreen/GridContainer/TitleContainer/EndRestartButton")
	
	buttons[CONSTANTS.STATBUTTON] = get_node("ModeControl/StatMode")
	buttons[CONSTANTS.ACTIONBUTTON] = get_node("ModeControl/ActionMode")
	buttons[CONSTANTS.PAUSEBUTTON] = get_node("TimeControls/Pause")
	buttons[CONSTANTS.PLAYBUTTON] = get_node("TimeControls/Play")
	buttons[CONSTANTS.PLAYX2BUTTON] = get_node("TimeControls/PlaySpeedx2")
	buttons[CONSTANTS.WEEK] = get_node("Statistics/GridContainer/Interval/Week")
	buttons[CONSTANTS.MONTH] = get_node("Statistics/GridContainer/Interval/Month")
	buttons[CONSTANTS.YEAR] = get_node("Statistics/GridContainer/Interval/Year")
	buttons[CONSTANTS.MAX] = get_node("Statistics/GridContainer/Interval/Max")
	
#	#Map Buttons
#	# Test data	
	bawu = State.new(CONSTANTS.BAW,		 	11103043, populationFactor, get_node("Map/BaWuButton"), [CONSTANTS.BAY, CONSTANTS.HES, CONSTANTS.RLP], 0.026)
	bayern = State.new(CONSTANTS.BAY, 		13140183, populationFactor, get_node("Map/BayernButton"), [CONSTANTS.BAW, CONSTANTS.HES, CONSTANTS.SCN, CONSTANTS.THU], 0.022)
	berlin = State.new(CONSTANTS.BER, 		3664088, populationFactor, get_node("Map/BerlinButton"), [CONSTANTS.BRA], 0.05)
	brand = State.new(CONSTANTS.BRA, 		2531071, populationFactor, get_node("Map/BrandenburgButton"), [CONSTANTS.BER, CONSTANTS.MVP, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.SCA], 0.119)
	bremen = State.new(CONSTANTS.BRE, 		680130, populationFactor, get_node("Map/BremenButton"), [CONSTANTS.NIE], 0.079)
	hamb = State.new(CONSTANTS.HAM, 		1852478, populationFactor, get_node("Map/HamburgButton"), [CONSTANTS.NIE, CONSTANTS.SLH], 0.07)
	hessen = State.new(CONSTANTS.HES, 		6293154, populationFactor, get_node("Map/HessenButton"), [CONSTANTS.BAW, CONSTANTS.BAY, CONSTANTS.NIE, CONSTANTS.NRW, CONSTANTS.RLP, CONSTANTS.THU], 0.042)
	meckPom = State.new(CONSTANTS.MVP, 		1610774, populationFactor, get_node("Map/MeckPomButton"), [CONSTANTS.BRA, CONSTANTS.NIE, CONSTANTS.SLH], 0.046)
	nieders = State.new(CONSTANTS.NIE, 		8003421, populationFactor, get_node("Map/NiedersachsenButton"), [CONSTANTS.BRA, CONSTANTS.BRE, CONSTANTS.HAM,
																					CONSTANTS.HES, CONSTANTS.MVP, CONSTANTS.NRW, CONSTANTS.SCA, CONSTANTS.SLH, CONSTANTS.THU], 0.055)
	nrw = State.new(CONSTANTS.NRW, 			17925570, populationFactor, get_node("Map/NrwButton"), [CONSTANTS.HES, CONSTANTS.NIE, CONSTANTS.RLP], 0.019)
	rlp = State.new(CONSTANTS.RLP, 			4098391, populationFactor, get_node("Map/RlpButton"), [CONSTANTS.BAW, CONSTANTS.HES, CONSTANTS.NRW, CONSTANTS.SAA], 0.08)
	saar = State.new(CONSTANTS.SAA, 		983991, populationFactor, get_node("Map/SaarlandButton"), [CONSTANTS.RLP], 0.035)
	sachsen = State.new(CONSTANTS.SCN, 		4056941, populationFactor, get_node("Map/SachsenButton"), [CONSTANTS.BAY, CONSTANTS.BRA, CONSTANTS.SCA, CONSTANTS.THU], 0.035)
	sacanh = State.new(CONSTANTS.SCA, 		2180684, populationFactor, get_node("Map/SachsenAnhaltButton"), [CONSTANTS.BRA, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.THU], 0.065)
	schlHol = State.new(CONSTANTS.SLH, 		2910875, populationFactor, get_node("Map/SchlHolButton"), [CONSTANTS.HAM, CONSTANTS.MVP, CONSTANTS.NIE], 0.082)
	thur = State.new(CONSTANTS.THU, 		2120237, populationFactor, get_node("Map/ThuringenButton"), [CONSTANTS.BAY, CONSTANTS.HES, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.SCA], 0.058)
	
#	# Real Data
#	bawu = State.new(CONSTANTS.BAW,		11103043, get_node("Map/BaWuButton"), [CONSTANTS.BAY, CONSTANTS.HES, CONSTANTS.RLP], 0.026)
#	bayern = State.new(CONSTANTS.BAY,	13140183, get_node("Map/BayernButton"), [CONSTANTS.BAW, CONSTANTS.HES, CONSTANTS.SCN, CONSTANTS.THU], 0.022)
#	berlin = State.new(CONSTANTS.BER,	3664088, get_node("Map/BerlinButton"), [CONSTANTS.BRA], 0.05)
#	brand = State.new(CONSTANTS.BRA, 	2531071, get_node("Map/BrandenburgButton"), [CONSTANTS.BER, CONSTANTS.MVP, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.SCA], 0.119)
#	bremen = State.new(CONSTANTS.BRE, 	680130, get_node("Map/BremenButton"), [CONSTANTS.NIE], 0.079)
#	hamb = State.new(CONSTANTS.HAM, 	1852478, get_node("Map/HamburgButton"), [CONSTANTS.NIE, CONSTANTS.SLH], 0.07)
#	hessen = State.new(CONSTANTS.HES, 	6293154, get_node("Map/HessenButton"), [CONSTANTS.BAW, CONSTANTS.BAY, CONSTANTS.NIE, CONSTANTS.NRW, CONSTANTS.RLP, CONSTANTS.THU], 0.042)
#	meckPom = State.new(CONSTANTS.MVP, 	1610774, get_node("Map/MeckPomButton"), [CONSTANTS.BRA, CONSTANTS.NIE, CONSTANTS.SLH], 0.046)
#	nieders = State.new(CONSTANTS.NIE, 	8003421, get_node("Map/NiedersachsenButton"), [CONSTANTS.BRA, CONSTANTS.BRE, CONSTANTS.HAM,
#																					CONSTANTS.HES, CONSTANTS.MVP, CONSTANTS.NRW, CONSTANTS.SCA, CONSTANTS.SLH, CONSTANTS.THU], 0.055)
#	nrw = State.new(CONSTANTS.NRW, 		17925570, get_node("Map/NrwButton"), [CONSTANTS.HES, CONSTANTS.NIE, CONSTANTS.RLP], 0.019)
#	rlp = State.new(CONSTANTS.RLP, 		4098391, get_node("Map/RlpButton"), [CONSTANTS.BAW, CONSTANTS.HES, CONSTANTS.NRW, CONSTANTS.SAA], 0.08)
#	saar = State.new(CONSTANTS.SAA, 	983991, get_node("Map/SaarlandButton"), [CONSTANTS.RLP], 0.035)
#	sachsen = State.new(CONSTANTS.SCN, 	4056941, get_node("Map/SachsenButton"), [CONSTANTS.BAY, CONSTANTS.BRA, CONSTANTS.SCA, CONSTANTS.THU], 0.035)
#	sacanh = State.new(CONSTANTS.SCA, 	2180684, get_node("Map/SachsenAnhaltButton"), [CONSTANTS.BRA, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.THU], 0.065)
#	schlHol = State.new(CONSTANTS.SLH, 	2910875, get_node("Map/SchlHolButton"), [CONSTANTS.HAM, CONSTANTS.MVP, CONSTANTS.NIE], 0.082)
#	thur = State.new(CONSTANTS.THU, 	2120237, get_node("Map/ThuringenButton"), [CONSTANTS.BAY, CONSTANTS.HES, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.SCA], 0.058)
	
	states = {CONSTANTS.BAW:bawu, CONSTANTS.BAY:bayern, CONSTANTS.BER:berlin, CONSTANTS.BRA:brand,
	 CONSTANTS.BRE:bremen, CONSTANTS.HAM:hamb, CONSTANTS.HES:hessen, CONSTANTS.MVP:meckPom,
	 CONSTANTS.NIE:nieders, CONSTANTS.NRW:nrw, CONSTANTS.RLP:rlp, CONSTANTS.SAA:saar,
	 CONSTANTS.SCN:sachsen, CONSTANTS.SCA:sacanh, CONSTANTS.SLH:schlHol, CONSTANTS.THU:thur}
	
	deu = Country.new(states, CONSTANTS.DEU, get_node("Map/DeutschButton"))
	
	var entities = {CONSTANTS.BAW:bawu, CONSTANTS.BAY:bayern, CONSTANTS.BER:berlin, CONSTANTS.BRA:brand,
	 CONSTANTS.BRE:bremen, CONSTANTS.HAM:hamb, CONSTANTS.HES:hessen, CONSTANTS.MVP:meckPom,
	 CONSTANTS.NIE:nieders, CONSTANTS.NRW:nrw, CONSTANTS.RLP:rlp, CONSTANTS.SAA:saar,
	 CONSTANTS.SCN:sachsen, CONSTANTS.SCA:sacanh, CONSTANTS.SLH:schlHol, CONSTANTS.THU:thur, 
	 CONSTANTS.DEU: deu
	 }
	game_manager = Game_Management.new(entities, statOutput, actionOutput, buttons, Constants.GODMODE)
	
	actionOutput[CONSTANTS.CONFIRMRESTART].connect("confirmed", self, "_on_confirmed_restart")
	
	game_manager._simThread.start(self, "_start_thread_with_nothing", "simThread")
#	game_manager._statThread.start(self, "_start_thread_with_nothing", "statThread")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_manager.ended:
		paused = true
		
	if !paused:
		if remainingDays > 0 and !running:
			Constants.currentProgress = 0
			statOutput[CONSTANTS.PROGRESSPANEL].visible = true
			
			
			# For DEBUGGING
#			self.running = true
#			game_manager.simulate()
#			self.remainingDays -= 1
#			self.running = false

			# For RUNNING
			game_manager._simThread.wait_to_finish()
			game_manager._simThread.start(self, "runSimulation", null)
			
		elif running:
			actionOutput[CONSTANTS.RESTARTBUTTON].disabled = true
			statOutput[CONSTANTS.PROGRESSPANEL].visible = true
			statOutput[CONSTANTS.SIMANIMATION].visible = true
			statOutput[CONSTANTS.SIMANIMATION].playing = true
		else:
			actionOutput[CONSTANTS.RESTARTBUTTON].disabled = false
			statOutput[CONSTANTS.PROGRESSPANEL].visible = false
			statOutput[CONSTANTS.SIMANIMATION].visible = false
			statOutput[CONSTANTS.SIMANIMATION].playing = false
		
		updateProgress()
		
		
	else:
		statOutput[CONSTANTS.SIMANIMATION].playing = false
	
	


func _input(event):
	if event.is_action_pressed("pause"):
		_on_Pause_pressed()
	if event.is_action_pressed("simulate_7"):
		_on_Play_pressed()
	if event.is_action_pressed("simulate_14"):
		_on_PlaySpeedx2_pressed()



func runSimulation(_userdata = null):
	self.running = true
	
	game_manager.simulate()
	self.remainingDays -= 1
	
	self.running = false
	

func updateProgress():
	var value = float(Constants.currentProgress) / game_manager.entities.values().size()
	statOutput[CONSTANTS.PROGRESSBAR].value = statOutput[CONSTANTS.PROGRESSBAR].max_value - remainingDays + value
	

func _on_Pause_pressed():
	if remainingDays > 0:
		paused = !paused

func _on_Play_pressed():
	if paused:
		paused = false
	else:
		if remainingDays < 1:
			remainingDays = CONSTANTS.WEEK
			statOutput[CONSTANTS.PROGRESSBAR].max_value = remainingDays

func _on_PlaySpeedx2_pressed():
	if paused:
		paused = false
	else:
		if remainingDays < 1:
#			remainingDays = CONSTANTS.WEEK * 2
			remainingDays = CONSTANTS.WEEK * 45
			statOutput[CONSTANTS.PROGRESSBAR].max_value = remainingDays


func _on_confirmed_restart():
	self.remainingDays = 0
	updateProgress()
	
	self.running = false
	self.paused = false
	


func _on_menu_pressed():
	get_tree().quit()


func _start_thread_with_nothing(userdata):
	print(userdata + " Thread started")
	return
