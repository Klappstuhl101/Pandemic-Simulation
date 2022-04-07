extends Object

class_name Country

#var _thread :Thread
#var waitTimer :Timer

var name
var realPopulation :int
var populationBase :int

var populationToRealFactor :float
var populationFactor :float
var population :int
var deaths :int

var states # dict of states

var beds = []
var hospitalBeds :int# Number of Beds
var hospitalBedsDaily

var vaxProduction :int
var avlbVax :int

var mapButton

var lockdown :bool = false
var openBorder :bool

var optionChanged :bool

var selectedMask :int
var selectedHomeOffice :int
var selectedTest :int

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

var unvaxSum
var v1sum
var v2sum


var rnd = RandomNumberGenerator.new()


func _init(initStates, initName, initButton):
#func _init(initStates, initName, initButton).(initName, 0, initButton, [], 0):
	
#	_thread = Thread.new()
#	waitTimer = Timer.new()
#	waitTimer.set_wait_time(0.5)
	
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
	self.populationFactor = float(self.populationBase) / float(self.realPopulation)
	self.populationToRealFactor = float(self.realPopulation) / float(self.populationBase)
	self.deaths = 0
	
	self.hospitalBedsDaily = {0:0}
	setHospitalBeds(0, (27681 + 7436) * populationFactor) # Anzahl Krankenhausbetten in Deutschland, nachgeschauter Wert
	recalculateHospitalBeds()
	self.hospitalBedsDaily = {0:self.hospitalBeds}
	
	self.avlbVax = 0
	setVaxProduction(0)
#	setVaxProduction(20)
	
	
	S = [0,0]
	I = [0,0,0,0]
	R = [0,0,0]
	D = [0,0,0]
	V1 = [0,0,0,0,0]
	V2 = [0,0,0,0,0]
	
	getNumbers()
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
	
	rnd.randomize()
	
	

func getName():
	return self.name

func recalculatePopulation():
	self.population = 0
	self.realPopulation = 0
	for state in states.values():
		self.population += state.getPopulation()
		self.realPopulation += state.getRealPopulation()

func recalculateStatePopulation():
	for state in states.values():
		state.calculateLivingPopulation()

func getPopulationToRealFactor():
	return self.populationToRealFactor

func getPopulationToCalculationFactor():
	return self.populationFactor
	
func recalculateDeaths():
	self.deaths = 0
	for state in states.values():
		self.deaths += state.getDeaths()

func setHospitalBeds(day, value):
#	var avlblBeds = floor(int(value))
	recalculatePopulation()
	for state in states.values():
		var avlblBeds = int(floor(value * (float(state.getPopulation())/float(self.population))))
		state.setHospitalBeds(day, avlblBeds)
		
	recalculateHospitalBeds()

func getAvlbVax():
	var sum = 0
	for state in states.values():
		sum += state.getAvlbVax()
	sum += self.avlbVax
	return sum

func getHospitalBeds(day = 0):
	var keys = self.hospitalBedsDaily.keys()
	if day != 0:
		
		var key = keys.max()
		for i in range(keys.size()):
			if day >= keys[i]:
				key = keys[i]
#				break
		
		return self.hospitalBedsDaily[key]
	else:
		return self.hospitalBedsDaily[keys[keys.size() - 1]]

func recalculateHospitalBeds():
	self.hospitalBeds = 0
	var maxKey = []
	for state in states.values():
		self.hospitalBeds += state.hospitalBeds
		maxKey.append(state.hospitalBedsDaily.keys().max())
	
	var keys = self.hospitalBedsDaily.keys()
	if self.hospitalBedsDaily[keys.max()] != self.hospitalBeds:
		self.hospitalBedsDaily[maxKey.max()] = self.hospitalBeds
	

#func setLockdown(isTrue:bool, lockdownStrictness:float):
#	self.lockdown = isTrue
#	for state in states.values():
#		state.setLockdown(isTrue, lockdownStrictness)

#func imposeLockdown():
#	self.lockdown = true
#	for state in states.values():
#		state.lockdown = true
#
#func stopLockdown():
#	self.lockdown = false
#	for state in states.values():
#		state.lockdown = false
	
func setVaxProduction(value):
	self.vaxProduction = value

func getVaxProduction():
	return self.vaxProduction
	
func produceVax():
	if getAvlbVax() > populationBase * 2:
		setVaxProduction(0)
	self.avlbVax += vaxProduction
	
func distributeVax():
	recalculatePopulation()
	var sumVax = 0
	for state in states.values():
		var distVax = int(floor(self.avlbVax * (float(state.getPopulation())/float(self.population))))
		state.avlbVax += distVax
		sumVax += distVax
	self.avlbVax -= sumVax

func distributeCommuters():
	recalculatePopulation()
	for state in states.values():
		if !state.getBorderOpen():
			continue
#		print(state.name)
		
		# Anzahl der Pendler
		var commuteCount = int(floor(state.getCommuteRate() * state.getPopulation()))
		var openBorderNeighborCount = getOpenBorderNeighborCount(state) # Anzahl der Nachbarstaaten, deren Grenze offen ist
		var modCommuter = 0
		if openBorderNeighborCount != 0:
			modCommuter = commuteCount % openBorderNeighborCount
		else:
			continue
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
					
					# PROBLEM: KEINE COMMUTER VEFÜGBAR WENN ALLE ERSTE IMPFUNG BEKOMMEN HABEN UND IM FLIEßBAND SIND
					var randErrorCounter = 0
					while !avlblCommuters[rand]:
						rand += 1
						rand = rand % avlblCommuters.size()
						randErrorCounter += 1
						if randErrorCounter > avlblCommuters.size():
							rand = -1
							break
						
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
#		if states.get(neighborstate).getBorderOpen() and checkAvlblCommuters(state).values().min() == true:
		if states.get(neighborstate).getBorderOpen():
			sum += 1
	return sum
	
func checkAvlblCommuters(state):
	var arr = []
	
	arr.append(!(state.S[0] == 0))
	arr.append(!(state.S[1] == 0))
	arr.append(!(state.I[0] == 0))
	arr.append(!(state.R[0] == 0))
	arr.append(!(state.R[1] == 0))
	arr.append(!(state.V1eligible[0] == 0))
	arr.append(!(state.V1eligible[1] == 0))
	arr.append(!(state.V1eligible[3] == 0))
	arr.append(!(state.V2[0] == 0))
	arr.append(!(state.V2[1] == 0))
	arr.append(!(state.V2[3] == 0))
	
	return arr

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
	
#	recalculateHospitalBeds()
	var startTime = OS.get_ticks_msec()
	
	produceVax()
	distributeVax()
	distributeCommuters()
	
	var endTime = OS.get_ticks_msec()
	var timeDiff = endTime - startTime
	print("%31s Distribution took: " % "", floor(timeDiff/1000.0/60.0/60), ":", int(timeDiff/1000.0/60.0)%60, ":", int(timeDiff/1000.0)%60, ":", int(timeDiff) % 1000)
	
	
	
	startTime = OS.get_ticks_msec()
	
	for state in states.values():
		state._thread.start(self, "simulateState", state.getName())
	
	for state in states.values():
		state._thread.wait_to_finish()
	
	
	endTime = OS.get_ticks_msec()
	timeDiff = endTime - startTime
	print("%28s Main Simulation took: " % "", floor(timeDiff/1000.0/60.0/60), ":", int(timeDiff/1000.0/60.0)%60, ":", int(timeDiff/1000.0)%60, ":", int(timeDiff) % 1000)
	
	
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
	
	unvaxSum = CONSTANTS.sum(S) + CONSTANTS.sum(I) + CONSTANTS.sum(R)
	v1sum = V1[0] + V1[1] + V1[2] + V1[3]
	v2sum = V2[0] + V2[1] + V2[2] + V2[3]
	
	
func simulateState(stateName):
#	print(stateName + "-Simulation Thread started")
	states[stateName].simulate()

func restartAll():
	for state in states.values():
		state.restart()
		
		
	recalculatePopulation()
	self.populationBase = self.population
	self.populationFactor = float(self.populationBase) / float(self.realPopulation)
	self.populationToRealFactor = float(self.realPopulation) / float(self.populationBase)
	self.deaths = 0
	
	self.hospitalBedsDaily = {0:0}
	setHospitalBeds(0, (27681 + 7436) * populationFactor) # Anzahl Krankenhausbetten in Deutschland, nachgeschauter Wert
	recalculateHospitalBeds()
	self.hospitalBedsDaily = {0:self.hospitalBeds}
	
	# ZURÜCKSETZEN BEVOR ABSCHLUSS
	self.avlbVax = 0
	setVaxProduction(0)
	
	suscept.clear()
	infect.clear()
	recov.clear()
	dead.clear()
	
	sus0.clear()
	sus1.clear()
	inf0.clear()
	inf1.clear()
	inf2.clear()
	rec0.clear()
	rec1.clear()
	rec2.clear()
	dead0.clear()
	dead1.clear()
	dead2.clear()
	
	
	vax1sus.clear()
	vax1inf.clear()
	vax1hosp.clear()
	vax1rec.clear()
	vax1dead.clear()
	
	vax2sus.clear()
	vax2inf.clear()
	vax2hosp.clear()
	vax2rec.clear()
	vax2dead.clear()
	
	hosp.clear()
	
	
	suscept = [CONSTANTS.SUSCEPTIBLE]
	infect = [CONSTANTS.INFECTED]
	recov = [CONSTANTS.RECOVERED]
	dead = [CONSTANTS.DEAD]
	
	sus0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]	# ungetestet ansteckbar
	sus1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]		# getestet ansteckbar
	sus2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]	# unbewusst ansteckbar (WIRD GESTRICHEN, NICHT MÖGLICH)
	inf0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]		# ungetestet infiziert
	inf1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]		# getestet infiziert
	inf2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.INFECTED]		# unbewusst infiziert
	rec0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# ungetestet genesen 
	rec1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# getestet genesen
	rec2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# unbewusst genesen
	dead0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.DEAD]			# ungetestet tot
	dead1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.DEAD]			# getestet tot
	dead2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.DEAD]			# unbewusst tot

	hosp = [CONSTANTS.HOSPITALISED]										# ungeimpfte Hospitalisierte

	vax1sus = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.SUSCEPTIBLE]	# 1x geimpft ansteckbar
	vax1inf = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.INFECTED]		# 1x geimpft infiziert
	vax1hosp = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.HOSPITALISED]	# 1x geimpft hospitalisiert
	vax1rec = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.RECOVERED]		# 1x geimpft genesen
	vax1dead = [CONSTANTS.VAX1 + CONSTANTS.BL + CONSTANTS.DEAD]			# 1x geimpft tot

	vax2sus = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.SUSCEPTIBLE]	# 2x geimpft ansteckbar
	vax2inf = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.INFECTED]		# 2x geimpft infiziert
	vax2hosp = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.HOSPITALISED]	# 2x geimpft hospitalisiert
	vax2rec = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.RECOVERED]		# 2x geimpft genesen
	vax2dead = [CONSTANTS.VAX2 + CONSTANTS.BL + CONSTANTS.DEAD]			# 2x geimpft tot
	
	S = [0,0]
	I = [0,0,0,0]
	R = [0,0,0]
	D = [0,0,0]
	V1 = [0,0,0,0,0]
	V2 = [0,0,0,0,0]
	
	getNumbers()
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
	

#func rewindAll():
#	var day = sus0.size() - 1
#	for state in states.values():
#		state.V1[0][state.getWaitDay()]
#
#
#
#
#
#		state.waitDay -= 1
#		if state.getWaitDay() < 0:
#			state.waitDay = Constants.VACDELAY - 1
#
#
#		state.suscept.remove(day)
#		state.infect.remove(day)
#		state.recov.remove(day)
#		state.dead.remove(day)
#
#		state.sus0.remove(day)
#		state.sus1.remove(day)
#		state.inf0.remove(day)
#		state.inf1.remove(day)
#		state.inf2.remove(day)
#		state.rec0.remove(day)
#		state.rec1.remove(day)
#		state.rec2.remove(day)
#		state.dead0.remove(day)
#		state.dead1.remove(day)
#		state.dead2.remove(day)
#
#		state.vax1sus.remove(day)
#		state.vax1inf.remove(day)
#		state.vax1hosp.remove(day)
#		state.vax1rec.remove(day)
#		state.vax1dead.remove(day)
#
#		state.vax2sus.remove(day)
#		state.vax2inf.remove(day)
#		state.vax2hosp.remove(day)
#		state.vax2rec.remove(day)
#		state.vax2dead.remove(day)
#
#		state.hosp.remove(day)
#
#
#	suscept.remove(day)
#	infect.remove(day)
#	recov.remove(day)
#	dead.remove(day)
#
#	sus0.remove(day)
#	sus1.remove(day)
#	inf0.remove(day)
#	inf1.remove(day)
#	inf2.remove(day)
#	rec0.remove(day)
#	rec1.remove(day)
#	rec2.remove(day)
#	dead0.remove(day)
#	dead1.remove(day)
#	dead2.remove(day)
#
#	vax1sus.remove(day)
#	vax1inf.remove(day)
#	vax1hosp.remove(day)
#	vax1rec.remove(day)
#	vax1dead.remove(day)
#
#	vax2sus.remove(day)
#	vax2inf.remove(day)
#	vax2hosp.remove(day)
#	vax2rec.remove(day)
#	vax2dead.remove(day)
#
#	hosp.remove(day)
#
#	S[0] = sus0[day-1]
#	S[1] = sus1[day-1]
#	I[0] = inf0[day-1]
#	I[1] = inf1[day-1]
#	I[2] = inf2[day-1]
#	I[3] = hosp[day-1]
#	R[0] = rec0[day-1]
#	R[1] = rec1[day-1]
#	R[2] = rec2[day-1]
#	D[0] = dead0[day-1]
#	D[1] = dead1[day-1]
#	D[2] = dead2[day-1]
#
	


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
	recalculatePopulation()
	return self.population

func getTestedSum():
	return S[1] + I[1] + R[1]

func getUnvaxedSum():
	return unvaxSum
#	return CONSTANTS.sum(S) + CONSTANTS.sum(I) + CONSTANTS.sum(R)

func getV1Sum():
	return v1sum
#	return V1[0] + V1[1] + V1[2] + V1[3]

func getV2Sum():
	return v2sum
#	return V2[0] + V2[1] + V2[2] + V2[3]

func getDailyInfections(day:int, godmode:bool):
	var difference = 0
	for state in states.values():
		difference += state.getDailyInfections(day, godmode)
#	var difference = infect[day] - infect[day - 1] # zum Testen des Overlay
#	var difference = inf1[day] - inf1[day-1] # später für Coronatests only
	return difference if difference > 0 else 0

func getDailyV1Difference(day:int):
	if day == 1:
		return (vax1sus[day] + vax1inf[day] + vax1hosp[day] + vax1rec[day])
	else:
		var difference = (vax1sus[day] + vax1inf[day] + vax1hosp[day] + vax1rec[day]) - (vax1sus[day-1] + vax1inf[day-1] + vax1hosp[day-1] + vax1rec[day-1])
		return difference if difference > 0 else 0

func getDailyV2Difference(day:int):
	if day == 1:
		return (vax2sus[day] + vax2inf[day] + vax2hosp[day] + vax2rec[day])
	else:
		var difference = (vax2sus[day] + vax2inf[day] + vax2hosp[day] + vax2rec[day]) - (vax2sus[day-1] + vax2inf[day-1] + vax2hosp[day-1] + vax2rec[day-1])
		return difference if difference > 0 else 0

func getDailyOccupiedBeds(day):
	if day < 1:
		return 0
	else:
		return hosp[day] + vax1hosp[day] + vax2hosp[day]

func getHospitalAllocation(day):
	return [hosp[day], vax1hosp[day], vax2hosp[day]]

func get7DayIncidence(godmode = false):
	var incidenceSum :float = 0
	for state in states.values():
		incidenceSum += state.get7DayIncidence(godmode)
	
	return stepify(incidenceSum/states.values().size(), 0.01)

func setBorderOpen(open:bool):
	for state in states.values():
		state.setBorderOpen(open)

func getBorderOpen():
	var value = states[CONSTANTS.BAW].getBorderOpen()
	for state in states.values():
		if value != state.getBorderOpen():
			return CONSTANTS.DIFFERENTSETTINGS
	self.openBorder = value
	return self.openBorder

func setTestRates(index:int):
	self.selectedTest = index
	for state in states.values():
		state.setTestRates(index)

func setSelectedMask(index:int):
	self.selectedMask = index
	for state in states.values():
		state.setSelectedMask(index)
		
func setSelectedHomeOffice(index:int):
	self.selectedHomeOffice = index
	for state in states.values():
		state.setSelectedHomeOffice(index)

func getSelectedMask():
	var value = states[CONSTANTS.BAW].getSelectedMask()
	for state in states.values():
		if value != state.getSelectedMask():
			return CONSTANTS.DIFFERENTSETTINGS
	self.selectedMask = value
	return self.selectedMask

func getSelectedHomeOffice():
	var value = states[CONSTANTS.BAW].getSelectedHomeOffice()
	for state in states.values():
		if value != state.getSelectedHomeOffice():
			return CONSTANTS.DIFFERENTSETTINGS
	self.selectedHomeOffice = value
	return self.selectedHomeOffice

func getSelectedTestRates():
	var value = states[CONSTANTS.BAW].getSelectedTestRates()
	for state in states.values():
		if value != state.getSelectedTestRates():
			return CONSTANTS.DIFFERENTSETTINGS
	self.selectedTest = value
	return self.selectedTest

func setOptionChanged(isTrue:bool):
	self.optionChanged = isTrue
#	for state in states.values():
#		state.setOptionChanged(isTrue)

func getOptionChanged():
	var value = states[CONSTANTS.BAW].getOptionChanged()
	for state in states.values():
		if value != state.getOptionChanged():
			return true
#	self.optionChanged = value
	return self.optionChanged

func getMaskAverage():
	var sum = 0
	for state in states.values():
		sum += state.getSelectedMask()
	return sum / float(states.values().size())

func getHomeOfficeAverage():
	var sum = 0
	for state in states.values():
		sum += state.getSelectedHomeOffice()
	return sum / float(states.values().size())

func getTestAverage():
	var sum = 0
	for state in states.values():
		sum += state.getSelectedTestRates()
	return sum / float(states.values().size())
	
func getBorderAverage():
	var sum = 0
	for state in states.values():
		sum += int(!state.getBorderOpen())
	return sum / float(states.values().size())

func getUnvaxedDead(day):
	return dead0[day] + dead1[day] + dead2[day]

func getVax1Dead(day):
	return vax1dead[day]

func getVax2Dead(day):
	return vax2dead[day]
