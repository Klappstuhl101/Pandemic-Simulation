extends State

class_name Country


var states # dict of states

var beds = []

var vaxProduction


func _init(initStates, initName, initButton).(initName, 0, initButton):
	self.states = initStates
	recalculatePop()
	recalculateHospitalBeds()
	
	self.avlbVax = 0
	setVaxProduction(0)
	
	
	# Hospital Bed array zum Anzeigen
	beds.append("Available Hospital-Beds")
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
	
func setVaxProduction(value):
	self.vaxProduction = value
	
func produceVax():
	self.avlbVax += vaxProduction
	
func distributeVax():
	var sumVax = 0
	var distVax = 0
	for state in states.values():
#		var anteilPopulation = state.getPopulation()/self.population
#		var vorFloor = self.avlbVax * anteilPopulation
		distVax = int(floor(self.avlbVax * (float(state.getPopulation())/float(self.population))))
#		distVax = floor(vorFloor)
		state.avlbVax += distVax
		sumVax += distVax
	self.avlbVax -= sumVax
	

func simulateALL():
	S = [0,0,0]
	I = [0,0,0,0]
	R = [0,0,0]
	D = [0,0,0]
	V1 = [0,0,0,0,0]
	V2 = [0,0,0,0,0]
	
	produceVax()
	distributeVax()
	
	for state in states.values():
		state.simulate()
		S = CONSTANTS.add_arrays(S, state.S)
		I = CONSTANTS.add_arrays(I, state.I)
		R = CONSTANTS.add_arrays(R, state.R)
		D = CONSTANTS.add_arrays(D, state.D)
		var stateV1 = [CONSTANTS.sum(state.V1[0]) + state.V1eligible[0], CONSTANTS.sum(state.V1[1]) + state.V1eligible[1], CONSTANTS.sum(state.V1[2]) + state.V1eligible[2], CONSTANTS.sum(state.V1[3]) + state.V1eligible[3], CONSTANTS.sum(state.V1[4]) + state.V1eligible[4]]
		V1 = CONSTANTS.add_arrays(V1, stateV1)
		V2 = CONSTANTS.add_arrays(V2, state.V2)
	
	# für Gesamtübersicht
#	suscept.append(S[0] + S[1] + S[2])
	suscept.append(S[0] + S[1])
	infect.append(I[0] + I[1] + I[2])
	recov.append(R[0] + R[1] + R[2])
	dead.append(D[0] + D[1] + D[2])
	
	sus0.append(S[0])
	sus1.append(S[1])
#	sus2.append(S[2])
	inf0.append(I[0])
	inf1.append(I[1])
	inf2.append(I[2])
	rec0.append(R[0])
	rec1.append(R[1])
	rec2.append(R[2])
	dead0.append(D[0])
	dead1.append(D[1])
	dead2.append(D[2])
	
#	vax1sus.append(CONSTANTS.sum(V1[0]) + V1eligible[0])
#	vax1inf.append(CONSTANTS.sum(V1[1]) + V1eligible[1])
#	vax1hosp.append(CONSTANTS.sum(V1[2]) + V1eligible[2])
#	vax1rec.append(CONSTANTS.sum(V1[3]) + V1eligible[3])
#	vax1dead.append(CONSTANTS.sum(V1[4]) + V1eligible[4])
	
	vax1sus.append(V1[0])
	vax1inf.append(V1[1])
	vax1hosp.append(V1[2])
	vax1rec.append(V1[3])
	vax1dead.append(V1[4])
	
	vax2sus.append(V2[0])
	vax2inf.append(V2[1])
	vax2hosp.append(V2[2])
	vax2rec.append(V2[3])
	vax2dead.append(V2[4])
	
	hosp.append(I[3])
	
