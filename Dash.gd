extends Panel

#class_name Dash

const LABEL = "Label"

#const BAW = "Baden-Württemberg"
#const BAY = "Bayern"
#const BER = "Berlin"
#const BRA = "Brandenburg"
#const BRE = "Bremen"
#const HAM = "Hamburg"
#const HES = "Hessen"
#const MVP = "Mecklenburg-Vorpommern"
#const NIE = "Niedersachsen"
#const NRW = "Nordrhein-Westfalen"
#const RLP = "Rheinland-Pfalz"
#const SAA = "Saarland"
#const SCN = "Sachsen"
#const SCA = "Sachsen-Anhalt"
#const SLH = "Schleswig-Holstein"
#const THU = "Thüringen"

#const DEU = "Deutschland"


var label

var timer

var pause
var play
var playspeedx2

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

var mapButtons

var tenthsec

var statOutput = {}

# Called when the node enters the scene tree for the first time.
func _ready():
#	Statistics shown
	label = get_node("Label")
	
	timer = get_node("Time")
	
#	Time Control Buttons
	pause = get_node("TimeControls/Pause")
	play = get_node("TimeControls/Play")
	playspeedx2 = get_node("TimeControls/PlaySpeedx2")
	
	pause.connect("pressed", self, "_on_Pause_pressed")
	play.connect("pressed", self, "_on_Play_pressed")
	playspeedx2.connect("pressed", self, "_on_PlaySpeedx2_pressed")
	
	timer.set_wait_time(0.1)
	timer.connect("timeout", self, "_on_Time_timeout")
	
	statOutput[Constants.LABEL] = label
	
#	Map Buttons
	bawu = State.new(Constants.BAW, 11103043, get_node("Map/BaWuButton"), statOutput)
	bayern = State.new(Constants.BAY, 10000, get_node("Map/BayernButton"), statOutput)
	berlin = State.new(Constants.BER, 10000, get_node("Map/BerlinButton"), statOutput)
	brand = State.new(Constants.BRA, 10000, get_node("Map/BrandenburgButton"), statOutput)
	bremen = State.new(Constants.BRE, 10000, get_node("Map/BremenButton"), statOutput)
	hamb = State.new(Constants.HAM, 10000, get_node("Map/HamburgButton"), statOutput)
	hessen = State.new(Constants.HES, 10000, get_node("Map/HessenButton"), statOutput)
	meckPom = State.new(Constants.MVP, 10000, get_node("Map/MeckPomButton"), statOutput)
	nieders = State.new(Constants.NIE, 10000, get_node("Map/NiedersachsenButton"), statOutput)
	nrw = State.new(Constants.NRW, 10000, get_node("Map/NrwButton"), statOutput)
	rlp = State.new(Constants.RLP, 10000, get_node("Map/RlpButton"), statOutput)
	saar = State.new(Constants.SAA, 10000, get_node("Map/SaarlandButton"), statOutput)
	sachsen = State.new(Constants.SCN, 10000, get_node("Map/SachsenButton"), statOutput)
	sacanh = State.new(Constants.SCA, 10000, get_node("Map/SachsenAnhaltButton"), statOutput)
	schlHol = State.new(Constants.SLH, 10000, get_node("Map/SchlHolButton"), statOutput)
	thur = State.new(Constants.THU, 10000, get_node("Map/ThuringenButton"), statOutput)
	
#	deu = Country.new()
	
	mapButtons = Button_Management.new({Constants.BAW:bawu, Constants.BAY:bayern, Constants.BER:berlin, Constants.BRA:brand,
	 Constants.BRE:bremen, Constants.HAM:hamb, Constants.HES:hessen, Constants.MVP:meckPom,
	 Constants.NIE:nieders, Constants.NRW:nrw, Constants.RLP:rlp, Constants.SAA:saar,
	 Constants.SCN:sachsen, Constants.SCA:sacanh, Constants.SLH:schlHol, Constants.THU:thur, 
	 Constants.DEU: deu}, 
	 statOutput)
	
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_Pause_pressed():
	label.text = "Pause"
	timer.stop()
	pass
	
func _on_Play_pressed():
	label.text = "Play"
	timer.start()
	pass
	
func _on_PlaySpeedx2_pressed():
	label.text = "x2"
	pass


func _on_Time_timeout():
	label.text = "Hallo"
