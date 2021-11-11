extends Panel

var label
var pieChart

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
var states

var game_manager

var tenthsec

var statOutput = {}

# Called when the node enters the scene tree for the first time.
func _ready():
#	Statistics shown
	label = get_node("Label")
	
	pieChart = get_node("Statistics/PieChart")
	pieChart.plot()
#	var stats = [["Country","Votes"],[7,"Germany"],[15,"GB"],[10,"Canada"]]
	
#	pieChart = get_node("Statistics/PieChart")
#	pieChart.plot_from_array(stats)
	
	
	
#	var data =  DataFrame.new(stats, ["1","2","3"], ["4","5","6"])
	
#	columnChart.plot_from_array(stats)
	
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
	
	statOutput[CONSTANTS.LABEL] = label
	
#	Map Buttons
	bawu = State.new(CONSTANTS.BAW, 11103043, get_node("Map/BaWuButton"), statOutput)
	bayern = State.new(CONSTANTS.BAY, 10000, get_node("Map/BayernButton"), statOutput)
	berlin = State.new(CONSTANTS.BER, 10000, get_node("Map/BerlinButton"), statOutput)
	brand = State.new(CONSTANTS.BRA, 10000, get_node("Map/BrandenburgButton"), statOutput)
	bremen = State.new(CONSTANTS.BRE, 10000, get_node("Map/BremenButton"), statOutput)
	hamb = State.new(CONSTANTS.HAM, 10000, get_node("Map/HamburgButton"), statOutput)
	hessen = State.new(CONSTANTS.HES, 10000, get_node("Map/HessenButton"), statOutput)
	meckPom = State.new(CONSTANTS.MVP, 10000, get_node("Map/MeckPomButton"), statOutput)
	nieders = State.new(CONSTANTS.NIE, 10000, get_node("Map/NiedersachsenButton"), statOutput)
	nrw = State.new(CONSTANTS.NRW, 10000, get_node("Map/NrwButton"), statOutput)
	rlp = State.new(CONSTANTS.RLP, 10000, get_node("Map/RlpButton"), statOutput)
	saar = State.new(CONSTANTS.SAA, 10000, get_node("Map/SaarlandButton"), statOutput)
	sachsen = State.new(CONSTANTS.SCN, 10000, get_node("Map/SachsenButton"), statOutput)
	sacanh = State.new(CONSTANTS.SCA, 10000, get_node("Map/SachsenAnhaltButton"), statOutput)
	schlHol = State.new(CONSTANTS.SLH, 10000, get_node("Map/SchlHolButton"), statOutput)
	thur = State.new(CONSTANTS.THU, 10000, get_node("Map/ThuringenButton"), statOutput)
	
	states = {CONSTANTS.BAW:bawu, CONSTANTS.BAY:bayern, CONSTANTS.BER:berlin, CONSTANTS.BRA:brand,
	 CONSTANTS.BRE:bremen, CONSTANTS.HAM:hamb, CONSTANTS.HES:hessen, CONSTANTS.MVP:meckPom,
	 CONSTANTS.NIE:nieders, CONSTANTS.NRW:nrw, CONSTANTS.RLP:rlp, CONSTANTS.SAA:saar,
	 CONSTANTS.SCN:sachsen, CONSTANTS.SCA:sacanh, CONSTANTS.SLH:schlHol, CONSTANTS.THU:thur}
	
	
	# Herausfinden wie man Objekte von Unterklassen richtig erstellt
#	deu = State.new(CONSTANTS.DEU, 0, get_node("Map/DeutschButton"), statOutput)
	deu = Country.new(states, CONSTANTS.DEU, get_node("Map/DeutschButton"), statOutput)
	print(deu.name)
	
	game_manager = Game_Management.new({CONSTANTS.BAW:bawu, CONSTANTS.BAY:bayern, CONSTANTS.BER:berlin, CONSTANTS.BRA:brand,
	 CONSTANTS.BRE:bremen, CONSTANTS.HAM:hamb, CONSTANTS.HES:hessen, CONSTANTS.MVP:meckPom,
	 CONSTANTS.NIE:nieders, CONSTANTS.NRW:nrw, CONSTANTS.RLP:rlp, CONSTANTS.SAA:saar,
	 CONSTANTS.SCN:sachsen, CONSTANTS.SCA:sacanh, CONSTANTS.SLH:schlHol, CONSTANTS.THU:thur, 
	 CONSTANTS.DEU: deu
	 }, 
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
