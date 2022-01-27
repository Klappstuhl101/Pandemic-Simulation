extends State

class_name Country


var states # dict of states

var beds = []

var vaxProduction


func _init(initStates, initName, initButton).(initName, 0, initButton, [], 0):
	self.states = initStates
	recalculatePop()
	recalculateHospitalBeds()
	
	self.avlbVax = 0
	setVaxProduction(0)
	
	
	# Hospital Bed array zum Anzeigen
	beds.append("Available Hospital-Beds")
	for i in range(CONSTANTS.TRYOUT_DAYS):
		beds.append(hospitalBeds)
	
	rnd.randomize()
	
	
	
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
	for state in states.values():
		var distVax = int(floor(self.avlbVax * (float(state.getPopulation())/float(self.population))))
		state.avlbVax += distVax
		sumVax += distVax
	self.avlbVax -= sumVax

func distributeCommuters():
	for state in states.values():
#		print(state.name)
		
		var commuteCount = int(floor(state.getCommuteRate() * state.getPopulation()))
		var modCommuter = commuteCount % state.neighbors.size()
		commuteCount -= modCommuter
		var neighborIndices = [] # Index in Array neighbors vom Nachbarland
		for neighborstateName in state.neighbors:
#			print(neighborstateName)
			neighborIndices.append(states.get(neighborstateName).neighbors.find(state.name))
		
		while commuteCount > 0:
			var index = 0
			for neighborstate in state.neighbors:
				var avlblCommuters = checkAvlblCommuters(state)
				var rand = rnd.randi_range(0, avlblCommuters.size()-1)
				
				while !avlblCommuters[rand]:
					rand = rnd.randi_range(0, avlblCommuters.size()-1)
					
				match rand:
					# UNGEIMPFT
					0: # aus S
						state.S[0] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][0][0] += 1 
					
					1: 
						state.S[1] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][0][0] += 1 
					
					2: 
						state.I[0] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][1][0] += 1 
					
					3: 
						state.I[1] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][1][0] += 1 
					
					4: 
						state.R[0] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][2][0] += 1 
					
					5: 
						state.R[1] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][2][0] += 1 
					
					
					# 1x GEIMPFT
					6: 
						state.V1eligible[0] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][0][1] += 1 
					
					7: 
						state.V1eligible[1] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][1][1] += 1 
					
					8:
						state.V1eligible[3] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][2][1] += 1 
					
					9:
						state.V2[0] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][0][2] += 1 
					
					10:
						state.V2[1] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][1][2] += 1
					
					11:
						state.V2[3] -= 1
						states.get(neighborstate).visitors[neighborIndices[index]][1][2][2] += 1
					
					
						
				index += 1
				commuteCount -= 1

func checkAvlblCommuters(state):
	var dict = {}
	
	dict[0] = !(state.S[0] == 0)
	dict[1] = !(state.S[1] == 0)
	dict[2] = !(state.I[0] == 0)
	dict[3] = !(state.I[1] == 0)
#	dict[4] = !(state.I[2] == 0)
	dict[4] = !(state.R[0] == 0)
	dict[5] = !(state.R[1] == 0)
#	dict[7] = !(state.R[2] == 0)
	dict[6] = !(state.V1eligible[0] == 0)
	dict[7] = !(state.V1eligible[1] == 0)
	dict[8] = !(state.V1eligible[3] == 0)
	dict[9] = !(state.V2[0] == 0)
	dict[10] = !(state.V2[1] == 0)
	dict[11] = !(state.V2[3] == 0)
	
	return dict

func homeCommuters():
	for state in states.values():
		for i in range(state.neighbors.size()):
			var homeState = states.get(state.neighbors[i])
			
			homeState.S[0] += state.visitors[i][1][0][0]
			state.visitors[i][1][0][0] = 0
			homeState.I[0] += state.visitors[i][1][1][0]
			state.visitors[i][1][1][0] = 0
			homeState.R[0] += state.visitors[i][1][2][0]
			state.visitors[i][1][2][0] = 0
			homeState.D[0] += state.visitors[i][1][3][0]
			state.visitors[i][1][3][0] = 0
			
			homeState.V1eligible[0] += state.visitors[i][1][0][1]
			state.visitors[i][1][0][1] = 0
			homeState.V1eligible[1] += state.visitors[i][1][1][1]
			state.visitors[i][1][1][1] = 0
			homeState.V1eligible[3] += state.visitors[i][1][2][1]
			state.visitors[i][1][2][1] = 0
			homeState.V1eligible[4] += state.visitors[i][1][3][1]
			state.visitors[i][1][3][1] = 0
			
			homeState.V2[0] += state.visitors[i][1][0][2]
			state.visitors[i][1][0][2] = 0
			homeState.V2[1] += state.visitors[i][1][1][2]
			state.visitors[i][1][1][2] = 0
			homeState.V2[3] += state.visitors[i][1][2][2]
			state.visitors[i][1][2][2] = 0
			homeState.V2[4] += state.visitors[i][1][3][2]
			state.visitors[i][1][3][2] = 0


func simulateALL():
	S = [0,0,0]
	I = [0,0,0,0]
	R = [0,0,0]
	D = [0,0,0]
	V1 = [0,0,0,0,0]
	V2 = [0,0,0,0,0]
	
	produceVax()
	distributeVax()
	distributeCommuters()
	
	for state in states.values():
		state.simulate()
#		S = CONSTANTS.add_arrays(S, state.S)
#		I = CONSTANTS.add_arrays(I, state.I)
#		R = CONSTANTS.add_arrays(R, state.R)
#		D = CONSTANTS.add_arrays(D, state.D)
#		var stateV1 = [CONSTANTS.sum(state.V1[0]) + state.V1eligible[0], CONSTANTS.sum(state.V1[1]) + state.V1eligible[1], CONSTANTS.sum(state.V1[2]) + state.V1eligible[2], CONSTANTS.sum(state.V1[3]) + state.V1eligible[3], CONSTANTS.sum(state.V1[4]) + state.V1eligible[4]]
#		V1 = CONSTANTS.add_arrays(V1, stateV1)
#		V2 = CONSTANTS.add_arrays(V2, state.V2)
	
	homeCommuters()
	
	getNumbers()
	
#	for state in states.values():
#		S = CONSTANTS.add_arrays(S, state.S)
#		I = CONSTANTS.add_arrays(I, state.I)
#		R = CONSTANTS.add_arrays(R, state.R)
#		D = CONSTANTS.add_arrays(D, state.D)
#		var stateV1 = [CONSTANTS.sum(state.V1[0]) + state.V1eligible[0], CONSTANTS.sum(state.V1[1]) + state.V1eligible[1], CONSTANTS.sum(state.V1[2]) + state.V1eligible[2], CONSTANTS.sum(state.V1[3]) + state.V1eligible[3], CONSTANTS.sum(state.V1[4]) + state.V1eligible[4]]
#		V1 = CONSTANTS.add_arrays(V1, stateV1)
#		V2 = CONSTANTS.add_arrays(V2, state.V2)
		
		
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
	
		
func getNumbers():
	for state in states.values():
		S = CONSTANTS.add_arrays(S, state.S)
		I = CONSTANTS.add_arrays(I, state.I)
		R = CONSTANTS.add_arrays(R, state.R)
		D = CONSTANTS.add_arrays(D, state.D)
		var stateV1 = [CONSTANTS.sum(state.V1[0]) + state.V1eligible[0], CONSTANTS.sum(state.V1[1]) + state.V1eligible[1], CONSTANTS.sum(state.V1[2]) + state.V1eligible[2], CONSTANTS.sum(state.V1[3]) + state.V1eligible[3], CONSTANTS.sum(state.V1[4]) + state.V1eligible[4]]
		V1 = CONSTANTS.add_arrays(V1, stateV1)
		V2 = CONSTANTS.add_arrays(V2, state.V2)
