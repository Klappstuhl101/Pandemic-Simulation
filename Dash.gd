extends Panel

var label

var timer

var pause
var play
var playspeedx2

var bayern
var bawu
var thur

var bawuButton
var bayernButton
var berlinButton
var brandButton
var bremenButton
var hambButton
var hessenButton
var meckPomButton
var niedersButton
var nrwButton
var rlpButton
var saarButton
var sachsenButton
var sacanhButton
var schlHolButton
var thurButton

var tenthsec

# Called when the node enters the scene tree for the first time.
func _ready():
	label = get_node("Label")
	
	timer = get_node("Time")
	
	pause = get_node("Pause")
	play = get_node("Play")
	playspeedx2 = get_node("PlaySpeedx2")
	
#	bayernButton = get_node("Map/BayernButton")
	
	pause.connect("pressed", self, "_on_Pause_pressed")
	play.connect("pressed", self, "_on_Play_pressed")
	playspeedx2.connect("pressed", self, "_on_PlaySpeedx2_pressed")
	
#	bayernButton.connect("pressed", self, "_on_TextureButton_pressed")
	
	timer.set_wait_time(0.1)
	timer.connect("timeout", self, "_on_Time_timeout")
	
	

	
	bayern = State.new("Bayern", 10000, get_node("Map/BayernButton"))
	bawu = State.new("Baden-Württemberg", 10000, get_node("Map/BaWuButton"))
	thur = State.new("Thüringen", 10000, get_node("Map/ThuringenButton"))
#	print(bayern.name, " ", bayern.population)
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_TextureButton_pressed():
	label.text = "Bayern"

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
#	pass
#	tenthsec += 1
#	if tenthsec == 10:
#		sec +=1
#		tenthsec = 0
#	label.text = str(sec) + "," + str(tenthsec) + " seconds elapsed since button press"
