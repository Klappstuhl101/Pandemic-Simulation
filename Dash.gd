extends Panel

var label
var pieChart
var lineChart
var lineChart2
var lineChart3
var lineChart4
var lineChart5
var lineChart6

#var timer

var paused	:bool = false

var pause
var play
var playspeedx2

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
var sim

var tenthsec = 0
var sec = 0
var minute = 0

var counter = 0

var remainingDays

var statOutput = {}
var actionOutput = {}
var buttons = {}

var showStatsSafe	:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	
	remainingDays = -1
	
	self.showStatsSafe = false
	
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
	
	
	statOutput[CONSTANTS.STATCONTAINER] = get_node("Statistics")
	statOutput[CONSTANTS.COUNTRYNAME] = get_node("CountryName")
	statOutput[CONSTANTS.OVERVIEW] = get_node("Statistics/GridContainer/Overview")
	statOutput[CONSTANTS.OVERVIEWLEGEND] = get_node("Statistics/GridContainer/Indicators/OverviewContainer/OverviewLegend")
	statOutput[CONSTANTS.OVERVIEWHEADLINE] = get_node("Statistics/GridContainer/Indicators/OverviewContainer/Overview")
	statOutput[CONSTANTS.VAXSTATUS] = get_node("Statistics/GridContainer/VaxStatusContainer/VaxStatus")
	statOutput[CONSTANTS.VAXSTATUSLEGEND] = get_node("Statistics/GridContainer/VaxStatusContainer/VaxLegendContainer/VaxStatusLegend")
	statOutput[CONSTANTS.DAILYCHANGES] = get_node("Statistics/GridContainer/DailyChanges")
	statOutput[CONSTANTS.DAILYLEGEND] = get_node("Statistics/GridContainer/VaxStatusContainer/DailyLegendContainer/DailyLegend")
	
	statOutput[CONSTANTS.PROGRESSBAR] = get_node("SimProgress")
	statOutput[CONSTANTS.PROGRESSPANEL] = get_node("SimProgress/ProgressPanel")
	statOutput[CONSTANTS.DAYS] = get_node("CurrentDay")
	
	statOutput[CONSTANTS.INCIDENCELABELS] = get_node("Map/ScaleContainer/ScaleContainer/IncidenceLabels")
	
	statOutput[CONSTANTS.INCIDENCE] = get_node("Statistics/GridContainer/Indicators/IncidenceNr")
	statOutput[CONSTANTS.RVALUE] = get_node("Statistics/GridContainer/Indicators/RNr")
	statOutput[CONSTANTS.BEDSTATUS] = get_node("Statistics/GridContainer/BedsOverview/BedNr")
	statOutput[CONSTANTS.HOSPBEDS] = get_node("Statistics/GridContainer/HospBeds")
	
	actionOutput[CONSTANTS.ACTIONCONTAINER] = get_node("PlayControls")
	actionOutput[CONSTANTS.OPTIONBUTTON] = get_node("PlayControls/GridContainer/OptionButton")
	actionOutput[CONSTANTS.MENUBUTTON] = get_node("PlayControls/GridContainer/MenuButton")
	
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
	bawu = State.new(CONSTANTS.BAW,		 	11103043,1000, get_node("Map/BaWuButton"), [CONSTANTS.BAY, CONSTANTS.HES, CONSTANTS.RLP], 0.026)
	bayern = State.new(CONSTANTS.BAY, 		13140183, 1000, get_node("Map/BayernButton"), [CONSTANTS.BAW, CONSTANTS.HES, CONSTANTS.SCN, CONSTANTS.THU], 0.022)
	berlin = State.new(CONSTANTS.BER, 		3664088, 1000, get_node("Map/BerlinButton"), [CONSTANTS.BRA], 0.05)
	brand = State.new(CONSTANTS.BRA, 		2531071, 1000, get_node("Map/BrandenburgButton"), [CONSTANTS.BER, CONSTANTS.MVP, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.SCA], 0.119)
	bremen = State.new(CONSTANTS.BRE, 		680130, 1000, get_node("Map/BremenButton"), [CONSTANTS.NIE], 0.079)
	hamb = State.new(CONSTANTS.HAM, 		1852478, 1000, get_node("Map/HamburgButton"), [CONSTANTS.NIE, CONSTANTS.SLH], 0.07)
	hessen = State.new(CONSTANTS.HES, 		6293154, 1000, get_node("Map/HessenButton"), [CONSTANTS.BAW, CONSTANTS.BAY, CONSTANTS.NIE, CONSTANTS.NRW, CONSTANTS.RLP, CONSTANTS.THU], 0.042)
	meckPom = State.new(CONSTANTS.MVP, 		1610774, 1000, get_node("Map/MeckPomButton"), [CONSTANTS.BRA, CONSTANTS.NIE, CONSTANTS.SLH], 0.046)
	nieders = State.new(CONSTANTS.NIE, 		8003421, 1000, get_node("Map/NiedersachsenButton"), [CONSTANTS.BRA, CONSTANTS.BRE, CONSTANTS.HAM,
																					CONSTANTS.HES, CONSTANTS.MVP, CONSTANTS.NRW, CONSTANTS.SCA, CONSTANTS.SLH, CONSTANTS.THU], 0.055)
	nrw = State.new(CONSTANTS.NRW, 			17925570, 1000, get_node("Map/NrwButton"), [CONSTANTS.HES, CONSTANTS.NIE, CONSTANTS.RLP], 0.019)
	rlp = State.new(CONSTANTS.RLP, 			4098391, 1000, get_node("Map/RlpButton"), [CONSTANTS.BAW, CONSTANTS.HES, CONSTANTS.NRW, CONSTANTS.SAA], 0.08)
	saar = State.new(CONSTANTS.SAA, 		983991, 1000, get_node("Map/SaarlandButton"), [CONSTANTS.RLP], 0.035)
	sachsen = State.new(CONSTANTS.SCN, 		4056941, 1000, get_node("Map/SachsenButton"), [CONSTANTS.BAY, CONSTANTS.BRA, CONSTANTS.SCA, CONSTANTS.THU], 0.035)
	sacanh = State.new(CONSTANTS.SCA, 		2180684, 1000, get_node("Map/SachsenAnhaltButton"), [CONSTANTS.BRA, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.THU], 0.065)
	schlHol = State.new(CONSTANTS.SLH, 		2910875, 1000, get_node("Map/SchlHolButton"), [CONSTANTS.HAM, CONSTANTS.MVP, CONSTANTS.NIE], 0.082)
	thur = State.new(CONSTANTS.THU, 		2120237, 1000, get_node("Map/ThuringenButton"), [CONSTANTS.BAY, CONSTANTS.HES, CONSTANTS.NIE, CONSTANTS.SCN, CONSTANTS.SCA], 0.058)
	
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
	game_manager = Game_Management.new(entities, statOutput, actionOutput, buttons, false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !paused:
		updateProgress()
	#	game_manager.showStats()
		if remainingDays > 0:
			statOutput[CONSTANTS.PROGRESSPANEL].visible = true
			game_manager.simulate()
			game_manager.showStats()
			remainingDays -= 1
		else:
			statOutput[CONSTANTS.PROGRESSPANEL].visible = false
	
#	if game_manager.days.size() > 3:
#		game_manager.showStats()
	
#	if remainingDays == 0:
##		game_manager.testStats()
#		game_manager.showStats()
#		remainingDays -= 1
#
#		match game_manager.getMode():
#			CONSTANTS.STATMODE:
#				statOutput[CONSTANTS.STATCONTAINER].visible = false
#				statOutput[CONSTANTS.STATCONTAINER].visible = true
#			CONSTANTS.ACTIONMODE:
#				actionOutput[CONSTANTS.ACTIONCONTAINER].visible = false
#				actionOutput[CONSTANTS.ACTIONCONTAINER].visible = true


func updateProgress():
	statOutput[CONSTANTS.PROGRESSBAR].value = statOutput[CONSTANTS.PROGRESSBAR].max_value - remainingDays
	pass

func _on_Pause_pressed():
	if remainingDays > 0:
		paused = true
#	remainingDays = 0

func _on_Play_pressed():
	if paused:
		paused = false
	else:
		if remainingDays < 1:
			remainingDays = CONSTANTS.WEEK + 1
			statOutput[CONSTANTS.PROGRESSBAR].max_value = remainingDays

func _on_PlaySpeedx2_pressed():
	if paused:
		paused = false
	else:
		if remainingDays < 1:
			remainingDays = CONSTANTS.WEEK * 20 + 1
			statOutput[CONSTANTS.PROGRESSBAR].max_value = remainingDays

func _on_menu_pressed():
	get_tree().quit()

