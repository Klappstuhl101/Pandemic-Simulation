extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startButton
var populationFactor
var vaxWaitDay

var exitButton


# Called when the node enters the scene tree for the first time.
func _ready():
	exitButton = get_node("ExitButton")
	
	startButton = get_node("Button")
	populationFactor = get_node("populationFactor")
	vaxWaitDay = get_node("vaxWaitDay")
	
	exitButton.connect("pressed", self, "_on_exit_pressed")
	
	startButton.connect("pressed", self, "_on_start_pressed")
	populationFactor.connect("value_changed", self, "_on_populationFactor_changed")
	vaxWaitDay.connect("value_changed", self, "_on_vaxWaitDay_changed")
	
	vaxWaitDay.value = Constants.VACDELAY
	populationFactor.value = Constants.POPULATIONFACTOR


func _on_start_pressed():
	return get_tree().change_scene_to(load("res://Dash.tscn"))
	

func _on_populationFactor_changed(value:float):
	Constants.POPULATIONFACTOR = value
	
func _on_vaxWaitDay_changed(value:float):
	Constants.VACDELAY = int(value)


func _on_exit_pressed():
	get_tree().quit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
