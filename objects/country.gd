extends State

class_name Country


var states # dict of states

var beds = []


func _init(initStates, initName, initButton).(initName, 0, initButton):
	self.states = initStates
	recalculatePop()
	recalculateHospitalBeds()
	
	
	# Hospital Bed array zum Anzeigen
	for i in range(CONSTANTS.TRYOUT_DAYS):
		beds.append(hospitalBeds)
	
	
	
	
func recalculatePop():
	self.population = 0
	for state in states.values():
		self.population += state.population

func recalculateHospitalBeds():
	self.hospitalBeds = 0
	for state in states.values():
		self.hospitalBeds += state.hospitalBeds

func imposeLockdown():
	self.lockdown = true
	for state in states.values():
		state.lockdown = true

func stopLockdown():
	self.lockdown = false
	for state in states.values():
		state.lockdown = false
	

func simulateALL():
	S = [0,0,0]
	I = [0,0,0,0]
	R = [0,0,0]
	D = [0,0,0]
	
	for state in states.values():
		state.simulate()
		S = CONSTANTS.add_arrays(S, state.S)
		I = CONSTANTS.add_arrays(I, state.I)
		R = CONSTANTS.add_arrays(R, state.R)
		D = CONSTANTS.add_arrays(D, state.D)
	
	suscept.append(S[0] + S[1] + S[2])
	infect.append(I[0] + I[1] + I[2])
	recov.append(R[0] + R[1] + R[2])
	dead.append(D[0] + D[1] + D[2])
	
	sus0.append(S[0])
	sus1.append(S[1])
	sus2.append(S[2])
	inf0.append(I[0])
	inf1.append(I[1])
	inf2.append(I[2])
	rec0.append(R[0])
	rec1.append(R[1])
	rec2.append(R[2])
	dead0.append(D[0])
	dead1.append(D[1])
	dead2.append(D[2])
	
	hosp.append(I[3])
	
#	# Standardsimulation
#	S = 0
#	I = 0
#	R = 0
#	D = 0
#
#	for state in states.values():
#		state.simulate()
#		S += state.S
#		I += state.I
#		R += state.R
#		D += state.D
#
#	suscept.append(S)
#	infect.append(I)
#	recov.append(R)
#	dead.append(D)
	
	
