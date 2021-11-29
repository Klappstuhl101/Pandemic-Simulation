extends State

class_name Country


var states # dict of states


func _init(initStates, initName, initButton).(initName, 0, initButton):
	self.states = initStates
	recalculatePop()
	
	
	
func recalculatePop():
	self.population = 0
	for state in states.values():
		self.population += state.population


func simulateALL():
	S = 0
	I = 0
	R = 0
	D = 0
	
	for state in states.values():
		state.simulate()
		S += state.S
		I += state.I
		R += state.R
		D += state.D
	
	suscept.append(S)
	infect.append(I)
	recov.append(R)
	dead.append(D)
	
	
