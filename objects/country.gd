extends Object

class_name Country

var name
var realPopulation
var populationBase

var population
var deaths

var states # dict of states

var beds = []
var hospitalBeds # Number of Beds

var vaxProduction
var avlbVax

var mapButton

var lockdown = false

var S
var I
var R
var D
var V1
var V2

var suscept = [CONSTANTS.SUSCEPTIBLE]
var infect = [CONSTANTS.INFECTED]
var recov = [CONSTANTS.RECOVERED]
var dead = [CONSTANTS.DEAD]

var sus0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]	# ungetestet ansteckbar
var sus1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]		# getestet ansteckbar
var sus2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]	# unbewusst ansteckbar (WIRD GESTRICHEN, NICHT MÖGLICH)
var inf0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]		# ungetestet infiziert
var inf1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]		# getestet infiziert
var inf2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.INFECTED]		# unbewusst infiziert
var rec0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# ungetestet genesen 
var rec1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# getestet genesen
var rec2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# unbewusst genesen
var dead0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.DEAD]			# ungetestet tot
var dead1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.DEAD]			# getestet tot
var dead2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.DEAD]			# unbewusst tot

var hosp = [CONSTANTS.HOSPITALISED]										# ungeimpfte Hospitalisierte

var vax1sus = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.SUSCEPTIBLE]	# 1x geimpft ansteckbar
var vax1inf = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.INFECTED]		# 1x geimpft infiziert
var vax1hosp = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.HOSPITALISED]	# 1x geimpft hospitalisiert
var vax1rec = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.RECOVERED]		# 1x geimpft genesen
var vax1dead = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.DEAD]			# 1x geimpft tot
var vax2sus = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.SUSCEPTIBLE]	# 2x geimpft ansteckbar
var vax2inf = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.INFECTED]		# 2x geimpft infiziert
var vax2hosp = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.HOSPITALISED]	# 2x geimpft hospitalisiert
var vax2rec = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.RECOVERED]		# 2x geimpft genesen
var vax2dead = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.DEAD]			# 2x geimpft tot


var rnd = RandomNumberGenerator.new()


func _init(initStates, initName, initButton):
#func _init(initStates, initName, initButton).(initName, 0, initButton, [], 0):
	
	self.name = initName
	self.mapButton = initButton
	
	var res = load("res://resources/map/" + name + ".png")
	var image : Image = res.get_data()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	mapButton.toggle_mode = true
	
	
	
	self.states = initStates
	recalculatePopulation()
	self.populationBase = self.population
	self.deaths = 0
	
	recalculateHospitalBeds()
	
	# ZURÜCKSETZEN BEVOR ABSCHLUSS
	self.avlbVax = 0
#	setVaxProduction(0)
	setVaxProduction(20)
	
	
	# Hospital Bed array zum Anzeigen
	beds.append("Available Hospital-Beds")
	for _i in range(CONSTANTS.TRYOUT_DAYS):
		beds.append(hospitalBeds)
	
	S = [0,0]
	I = [0,0,0,0]
	R = [0,0,0]
	D = [0,0,0]
	V1 = [0,0,0,0,0]
	V2 = [0,0,0,0,0]
	
	getNumbers()
	
	rnd.randomize()
	
	
	
func recalculatePopulation():
	self.population = 0
	self.realPopulation = 0
	for state in states.values():
		self.population += state.getPopulation()
		self.realPopulation += state.getRealPopulation()

func recalculateStatePopulation():
	for state in states.values():
		state.calculateLivingPopulation()

func recalculateDeaths():
	self.deaths = 0
	for state in states.values():
		self.deaths += state.getDeaths()

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
		if !state.getBorderOpen():
			continue
#		print(state.name)
		
		var commuteCount = int(floor(state.getCommuteRate() * state.getPopulation()))
		var openBorderNeighborCount = getOpenBorderNeighborCount(state)
		var modCommuter = 0
		if openBorderNeighborCount != 0:
			modCommuter = commuteCount % openBorderNeighborCount
		commuteCount -= modCommuter
		var neighborIndices = [] # Index in Array neighbors vom Nachbarland
		for neighborstateName in state.neighbors:
#			print(neighborstateName)
			neighborIndices.append(states.get(neighborstateName).neighbors.find(state.name))
		
		while commuteCount > 0:
			var index = 0
			for neighborstate in state.neighbors:
				if states.get(neighborstate).getBorderOpen():
					var avlblCommuters = checkAvlblCommuters(state)
					var rand = rnd.randi_range(0, avlblCommuters.size()-1)
					
					while !avlblCommuters[rand]:
						rand = rnd.randi_range(0, avlblCommuters.size()-1)
						
					match rand:
						# UNGEIMPFT
						0: # aus S
							state.S[0] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][0][0] += 1 
							states.get(neighborstate).population += 1
						
						1: 
							state.S[1] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][0][0] += 1 
							states.get(neighborstate).population += 1
						
						2: 
							state.I[0] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][1][0] += 1 
							states.get(neighborstate).population += 1
						
						3: 
							state.R[0] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][2][0] += 1 
							states.get(neighborstate).population += 1
						
						4: 
							state.R[1] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][2][0] += 1 
							states.get(neighborstate).population += 1
						
						
						# 1x GEIMPFT
						5: 
							state.V1eligible[0] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][0][1] += 1 
							states.get(neighborstate).population += 1
						
						6: 
							state.V1eligible[1] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][1][1] += 1 
							states.get(neighborstate).population += 1
						
						7:
							state.V1eligible[3] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][2][1] += 1 
							states.get(neighborstate).population += 1
						
						8:
							state.V2[0] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][0][2] += 1 
							states.get(neighborstate).population += 1
						
						9:
							state.V2[1] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][1][2] += 1
							states.get(neighborstate).population += 1
						
						10:
							state.V2[3] -= 1
							state.population -= 1
							states.get(neighborstate).visitors[neighborIndices[index]][1][2][2] += 1
							states.get(neighborstate).population += 1
						
					index += 1
					commuteCount -= 1
					
				else:
					index += 1

func getOpenBorderNeighborCount(state:State):
	var sum = 0
	for neighborstate in state.neighbors:
		if states.get(neighborstate).getBorderOpen():
			sum += 1
	return sum
	
func checkAvlblCommuters(state):
	var dict = {}
	
	dict[0] = !(state.S[0] == 0)
	dict[1] = !(state.S[1] == 0)
	dict[2] = !(state.I[0] == 0)
	dict[3] = !(state.R[0] == 0)
	dict[4] = !(state.R[1] == 0)
	dict[5] = !(state.V1eligible[0] == 0)
	dict[6] = !(state.V1eligible[1] == 0)
	dict[7] = !(state.V1eligible[3] == 0)
	dict[8] = !(state.V2[0] == 0)
	dict[9] = !(state.V2[1] == 0)
	dict[10] = !(state.V2[3] == 0)
	
	return dict

func homeCommuters():
	for state in states.values():
		for i in range(state.neighbors.size()):
			var homeState = states.get(state.neighbors[i])
			
			homeState.S[0] += state.visitors[i][1][0][0]
			homeState.population += state.visitors[i][1][0][0]
			state.population -= state.visitors[i][1][0][0]
			state.visitors[i][1][0][0] = 0
			
			homeState.I[0] += state.visitors[i][1][1][0]
			homeState.population += state.visitors[i][1][1][0]
			state.population -= state.visitors[i][1][1][0]
			state.visitors[i][1][1][0] = 0
			
			homeState.R[0] += state.visitors[i][1][2][0]
			homeState.population += state.visitors[i][1][2][0]
			state.population -= state.visitors[i][1][2][0]
			state.visitors[i][1][2][0] = 0
			
			homeState.D[0] += state.visitors[i][1][3][0]
			homeState.population += state.visitors[i][1][3][0]
			state.population -= state.visitors[i][1][3][0]
			state.visitors[i][1][3][0] = 0
			
			
			homeState.V1eligible[0] += state.visitors[i][1][0][1]
			homeState.population += state.visitors[i][1][0][1]
			state.population -= state.visitors[i][1][0][1]
			state.visitors[i][1][0][1] = 0
			
			homeState.V1eligible[1] += state.visitors[i][1][1][1]
			homeState.population += state.visitors[i][1][1][1]
			state.population -= state.visitors[i][1][1][1]
			state.visitors[i][1][1][1] = 0
			
			homeState.V1eligible[3] += state.visitors[i][1][2][1]
			homeState.population += state.visitors[i][1][2][1]
			state.population -= state.visitors[i][1][2][1]
			state.visitors[i][1][2][1] = 0
			
			homeState.V1eligible[4] += state.visitors[i][1][3][1]
			homeState.population += state.visitors[i][1][3][1]
			state.population -= state.visitors[i][1][3][1]
			state.visitors[i][1][3][1] = 0
			
			
			homeState.V2[0] += state.visitors[i][1][0][2]
			homeState.population += state.visitors[i][1][0][2]
			state.population -= state.visitors[i][1][0][2]
			state.visitors[i][1][0][2] = 0
			
			homeState.V2[1] += state.visitors[i][1][1][2]
			homeState.population += state.visitors[i][1][1][2]
			state.population -= state.visitors[i][1][1][2]
			state.visitors[i][1][1][2] = 0
			
			homeState.V2[3] += state.visitors[i][1][2][2]
			homeState.population += state.visitors[i][1][2][2]
			state.population -= state.visitors[i][1][2][2]
			state.visitors[i][1][2][2] = 0
			
			homeState.V2[4] += state.visitors[i][1][3][2]
			homeState.population += state.visitors[i][1][3][2]
			state.population -= state.visitors[i][1][3][2]
			state.visitors[i][1][3][2] = 0
			


func simulateALL():
	S = [0,0]
	I = [0,0,0,0]
	R = [0,0,0]
	D = [0,0,0]
	V1 = [0,0,0,0,0]
	V2 = [0,0,0,0,0]
	
	produceVax()
	distributeVax()
	distributeCommuters()
	
	for state in states.values():
#		CONSTANTS.currentState = state.getName()
		state.simulate()
	
	homeCommuters()
	
	
	getNumbers()
	
	recalculateStatePopulation()
	
	# für Gesamtübersicht
	suscept.append(S[0] + S[1] + V1[0] + V2[0])
	infect.append(I[0] + I[1] + I[2] + I[3] + V1[1] + V1[2] + V2[1] + V2[2])
	recov.append(R[0] + R[1] + R[2] + V1[3] + V2[3])
	dead.append(D[0] + D[1] + D[2] + V1[4] + V2[4])
	
	sus0.append(S[0])
	sus1.append(S[1])
	inf0.append(I[0])
	inf1.append(I[1])
	inf2.append(I[2])
	rec0.append(R[0])
	rec1.append(R[1])
	rec2.append(R[2])
	dead0.append(D[0])
	dead1.append(D[1])
	dead2.append(D[2])
	
	
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

func getPopulation():
	return self.population

func getUnvaxedSum():
	return CONSTANTS.sum(S) + CONSTANTS.sum(I) + CONSTANTS.sum(R)

func getV1Sum():
	return V1[0] + V1[1] + V1[2] + V1[3]

func getV2Sum():
	return V2[0] + V2[1] + V2[2] + V2[3]
