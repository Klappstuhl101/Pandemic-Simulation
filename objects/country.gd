extends State

class_name Country


var states


func _init(initStates).(name, population, mapButton, ui_output):
	self.states = initStates
	recalculatePop()
	
	
	
func recalculatePop():
	self.population = 0
	for state in states:
		self.population += self.population + state.population
