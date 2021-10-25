extends State

class_name Country


var states # dict of states


func _init(initStates, initName, initButton, initOutput).(initName, 0, initButton, initOutput):
	self.states = initStates
	recalculatePop()
	
	
	
func recalculatePop():
	self.population = 0
	for state in states.values():
		self.population += state.population
