extends Panel

var startButton

var popContainer
var populationFactor
var populationDescription

var vaxWaitDayContainer
var vaxWaitDay
var vaxWaitDayDescription

var godmodeButton
var godmodeDescription

var exitButton


# Called when the node enters the scene tree for the first time.
func _ready():
	exitButton = get_node("ExitButton")
	
	startButton = get_node("GridContainer/GridContainer/StartButton")
	
	popContainer = get_node("GridContainer/PopContainer")
	populationFactor = get_node("GridContainer/PopContainer/populationFactor")
	populationDescription = get_node("ImageTexture/Infocontainer/PopulationDescription")
	
	vaxWaitDayContainer = get_node("GridContainer/VaxWaitDayContainer")
	vaxWaitDay = get_node("GridContainer/VaxWaitDayContainer/vaxWaitDay")
	vaxWaitDayDescription = get_node("ImageTexture/Infocontainer/VaxWaitDayDescription")
	
	godmodeButton = get_node("GridContainer/GodmodeButton")
	godmodeDescription = get_node("ImageTexture/Infocontainer/GodmodeDescription")
	
	_hide_godmodeDescription()
	_hide_popDescription()
	_hide_vaxWaitDescription()
	
	connectSignals()
	
	
	vaxWaitDay.value = Constants.VACDELAY
	populationFactor.value = Constants.POPULATIONFACTOR


func _on_start_pressed():
	return get_tree().change_scene_to(load("res://Dash.tscn"))
	

func _on_populationFactor_changed(value:float):
	Constants.POPULATIONFACTOR = value
	
func _on_vaxWaitDay_changed(value:float):
	Constants.VACDELAY = int(value)

func _on_godmode_toggled(pressed:bool):
	Constants.GODMODE = pressed


func _on_exit_pressed():
	get_tree().quit()

func _show_popDescription():
	populationDescription.visible = true

func _hide_popDescription():
	populationDescription.visible = false

func _show_vaxWaitDescription():
	vaxWaitDayDescription.visible = true

func _hide_vaxWaitDescription():
	vaxWaitDayDescription.visible = false

func _show_godmodeDescription():
	godmodeDescription.visible = true

func _hide_godmodeDescription():
	godmodeDescription.visible = false


func connectSignals():
	
	exitButton.connect("pressed", self, "_on_exit_pressed")
	startButton.connect("pressed", self, "_on_start_pressed")
	
	populationFactor.connect("value_changed", self, "_on_populationFactor_changed")
	popContainer.connect("mouse_entered", self, "_show_popDescription")
	popContainer.connect("mouse_exited", self, "_hide_popDescription")
	populationFactor.connect("mouse_entered", self, "_show_popDescription")
	populationFactor.connect("mouse_exited", self, "_hide_popDescription")
	
	vaxWaitDay.connect("value_changed", self, "_on_vaxWaitDay_changed")
	vaxWaitDayContainer.connect("mouse_entered", self, "_show_vaxWaitDescription")
	vaxWaitDayContainer.connect("mouse_exited", self, "_hide_vaxWaitDescription")
	vaxWaitDay.connect("mouse_entered", self, "_show_vaxWaitDescription")
	vaxWaitDay.connect("mouse_exited", self, "_hide_vaxWaitDescription")
	
	godmodeButton.connect("toggled", self, "_on_godmode_toggled")
	godmodeButton.connect("mouse_entered", self, "_show_godmodeDescription")
	godmodeButton.connect("mouse_exited", self, "_hide_godmodeDescription")
	
	
	print("Main Menu Signals connected")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
