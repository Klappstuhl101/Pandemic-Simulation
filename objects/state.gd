# Class for all the federal states of germany.
extends Object

class_name State

var name
var realPopulation
var populationBase
var neighbors
var visitors
var commuterRate

var mapButton

var population
var deaths

var borderOpen

var suscept = [CONSTANTS.SUSCEPTIBLE]
var infect = [CONSTANTS.INFECTED]
var recov = [CONSTANTS.RECOVERED]
var dead = [CONSTANTS.DEAD]

var S
var I
var R
var D

# Indizierung für SIRD:
# 0: Ungetestet
# 1: Getestet
# 2: Unbewusste Krankheitsänderung
# 3: Hospitalisierte (nur Infizierte)

var V1
var V1eligible
var V2

var vacRate1
var vacRate2
var waitDay = 0

var avlbVax

var infectRate
var recRate
var deathRate

var deathFactorHosp
var infectFactorHosp
var infectFactorV1
var infectFactorV2
var infectTestFactor

var hospitalBeds
var hospitalRate

var baseInfect
var baseRec
var baseDeath
var baseTest
var baseHospital

var lockdown = false
var lockdownStrictness

var testRate
var informationLoss


var sus0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]	# ungetestet ansteckbar
var sus1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]		# getestet ansteckbar
#var sus2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]	# unbewusst ansteckbar (WIRD GESTRICHEN, NICHT MÖGLICH)
var inf0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]		# ungetestet infiziert
var inf1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]		# getestet infiziert
var inf2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.INFECTED]		# unbewusst infiziert
var rec0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# ungetestet genesen 
var rec1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# getestet genesen
var rec2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.RECOVERED]		# unbewusst genesen
var dead0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.DEAD]			# ungetestet tot
var dead1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.DEAD]			# getestet tot
var dead2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.DEAD]			# unbewusst tot
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

var hosp = [CONSTANTS.HOSPITALISED]										# ungeimpfte Hospitalisierte

var timeDifference

var rnd = RandomNumberGenerator.new()

func _init(initName, initRealPopulation, initPopulation, initButton, initNeighbors, initCommuter):
	self.name = initName
	self.realPopulation = initRealPopulation
	self.populationBase = initPopulation
	self.mapButton = initButton
	self.neighbors = initNeighbors
	self.commuterRate = initCommuter
	
	var res = load("res://resources/map/" + name + ".png")
	var image : Image = res.get_data()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	mapButton.toggle_mode = true
	
	baseInfect = 0.2
	baseRec = 0.02
	baseDeath = 0.01
	baseTest = 0.04
	baseHospital = 0.6
	
	self.avlbVax = 0
	self.population = populationBase
	self.deaths = 0
	
#	# Hospitalisierung
	self.I = [3,0,0,0]
	
	
	# für Test und Hospitalisierung
	self.S = [self.populationBase - self.I[0],0]
	self.R = [0,0,0]
	self.D = [0,0,0]
	informationLoss = 0.02
	
	infectFactorHosp = 0.2
	infectFactorV1 = 0.5
	infectFactorV2 = 0.3
	infectTestFactor = 0.7
	
	deathFactorHosp = 0.5
	
	
#	# für Hospitalisierung
	infectRate = [getInfectRate(), getInfectRate(), getInfectRate()*infectFactorHosp, getInfectRate()*infectFactorV1, getInfectRate()*infectFactorV2] 	# Ungetestet, Getestet, Hospitalisiert, 1x Geimpft, 2x Geimpft
	recRate = [baseRec, baseRec*1.2, baseRec*1.3, baseRec*1.6] 																# Ungeimpft, Hospitalisiert, 1x Geimpft, 2x Geimpft
	deathRate = [baseDeath, baseDeath*deathFactorHosp, baseDeath*0.2, baseDeath*0.1]														# Ungeimpft, Hospitalisiert, 1x Geimpft, 2x Geimpft
	testRate = [baseTest, baseTest, baseTest]
	hospitalBeds = 20
	hospitalRate = [baseHospital, baseHospital*0.2, baseHospital*0.1]
	
#	# für Lockdown
	lockdownStrictness = 0.9
	
	self.V1 = [CONSTANTS.zeroes(CONSTANTS.VACDELAY),CONSTANTS.zeroes(CONSTANTS.VACDELAY),CONSTANTS.zeroes(CONSTANTS.VACDELAY),CONSTANTS.zeroes(CONSTANTS.VACDELAY),CONSTANTS.zeroes(CONSTANTS.VACDELAY)]
	self.V1eligible = [0,0,0,0,0]
	
	
	self.V2 = [0,0,0,0,0]
	
	# Indizierung V1, V1eligible und V2 (zweimal geimpft)
	# 0: Ansteckbar (S)
	# 1: Infiziert (I)
	# 2: Hospitalisiert (H)
	# 3: Genesen (R)
	# 4: Gestorben (D)
	
	# Indizierung Visitors of Neighbors
	# 0,1,2,3,... Auswahl Nachbar
	# 	0: Name
	# 	1: Array: 1.Stelle	2.Stelle: 0: Ungeimpft, 1: 1x geimpft, 2: 2x geimpft
	#				0: S
	#				1: I
	#				2: R
	#				3: D
	#
	#
	
	visitors = []
	for i in range(neighbors.size()):
		var vis = [CONSTANTS.zeroes(3), CONSTANTS.zeroes(3), CONSTANTS.zeroes(3), CONSTANTS.zeroes(3)]
		var neighborName = neighbors[i]
		var arr = [neighborName, vis]
		visitors.append(arr)
	
	borderOpen = true
	
	vacRate1 = 2
	vacRate2 = 18
	
	
	timeDifference = 0
	
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
	
	vax1sus.append(CONSTANTS.sum(V1[0]) + V1eligible[0])
	vax1inf.append(CONSTANTS.sum(V1[1]) + V1eligible[1])
	vax1hosp.append(CONSTANTS.sum(V1[2]) + V1eligible[2])
	vax1rec.append(CONSTANTS.sum(V1[3]) + V1eligible[3])
	vax1dead.append(CONSTANTS.sum(V1[4]) + V1eligible[4])
	
	vax2sus.append(V2[0])
	vax2inf.append(V2[1])
	vax2hosp.append(V2[2])
	vax2rec.append(V2[3])
	vax2dead.append(V2[4])
	
	hosp.append(I[3])
	
	rnd.randomize()

func getName():
	return self.name

func occupiedBeds():
	return I[3] + CONSTANTS.sum(V1[2]) + V1eligible[2] + V2[2]

func getRealPopulation():
	return self.realPopulation

func getPopulation():
	calculateLivingPopulation()
	return self.population

func calculateLivingPopulation():
	calculateDeaths()
	self.population = self.populationBase - self.deaths

func getDeaths():
	calculateDeaths()
	return self.deaths

func getUnvaxedSum():
	return CONSTANTS.sum(S) + CONSTANTS.sum(I) + CONSTANTS.sum(R)

func getV1Sum():
	return CONSTANTS.sum(V1[0]) + CONSTANTS.sum(V1[1]) + CONSTANTS.sum(V1[2]) + CONSTANTS.sum(V1[3]) + V1eligible[0] + V1eligible[1] + V1eligible[2] + V1eligible[3]

func getV2Sum():
	return V2[0] + V2[1] + V2[2] + V2[3]

func calculateDeaths():
	self.deaths = CONSTANTS.sum(D) + CONSTANTS.sum(V1[4]) + V1eligible[4] + V2[4]

func getInfectRate():
	if lockdown:
		return baseInfect * (1-lockdownStrictness)
	else:
		return baseInfect

func getCommuteRate():
	return commuterRate

func getBorderOpen():
	return borderOpen

func setBorderOpen(open:bool):
	self.borderOpen = open

func simulate():
#	if I <= 0: # pandemic over
#		return
	infectRate = [getInfectRate(), getInfectRate()*infectTestFactor, getInfectRate()*infectFactorHosp, getInfectRate()*infectFactorV1, getInfectRate()*infectFactorV2] # Ungetestet, Getestet, Hospitalisiert, 1x Geimpft, 2x Geimpft
	var t = timeDifference
	while t<1:
		t = gillespieIteration(t)
#		print(t, " S ", S, " I ", I, " R ", R, " D ", D, " ", I+S+R+D)
		if(t>1):
			timeDifference = fmod(t,1)
			continue
			
	
#	simulateV1()
#	print(V1)
	
	waitDay += 1
	waitDay = waitDay % CONSTANTS.VACDELAY
	
	V1eligible[0] += V1[0][waitDay]
	V1eligible[1] += V1[1][waitDay] 
	V1eligible[2] += V1[2][waitDay] 
	V1eligible[3] += V1[3][waitDay] 
	
	V1[0][waitDay] = 0
	V1[1][waitDay] = 0
	V1[2][waitDay] = 0
	V1[3][waitDay] = 0
	
	
	
	
#	suscept.append(S[0] + S[1] + S[2])
	suscept.append(S[0] + S[1] + CONSTANTS.sum(V1[0]) + V1eligible[0] + V2[0])
	infect.append(I[0] + I[1] + I[2] + CONSTANTS.sum(V1[1]) + CONSTANTS.sum(V1[2]) + V1eligible[1] + V1eligible[2] + V2[1] + V2[2])
	recov.append(R[0] + R[1] + R[2] + CONSTANTS.sum(V1[3]) + V1eligible[3] + V2[3])
	dead.append(D[0] + D[1] + D[2] + CONSTANTS.sum(V1[4]) + V1eligible[4] + V2[4])
	
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
	
	vax1sus.append(CONSTANTS.sum(V1[0]) + V1eligible[0])
	vax1inf.append(CONSTANTS.sum(V1[1]) + V1eligible[1])
	vax1hosp.append(CONSTANTS.sum(V1[2]) + V1eligible[2])
	vax1rec.append(CONSTANTS.sum(V1[3]) + V1eligible[3])
	vax1dead.append(CONSTANTS.sum(V1[4]) + V1eligible[4])
	
	vax2sus.append(V2[0])
	vax2inf.append(V2[1])
	vax2hosp.append(V2[2])
	vax2rec.append(V2[3])
	vax2dead.append(V2[4])
	
	hosp.append(I[3])



func gillespieIteration(t):
	var r1 = rnd.randf()
	var reactionRates = updateReactionRates()
	var reactTotal = CONSTANTS.sum(reactionRates)
	
	if reactTotal == 0:
		return 1
		
	var waitTime = -log(r1)/reactTotal
	t = t + waitTime
	
	var r2 = rnd.randf()
	
	var reactionRatesCumSum = CONSTANTS.cumulative_sum(reactionRates)
	for i in range(reactionRatesCumSum.size()):
		reactionRatesCumSum[i] = reactionRatesCumSum[i] / reactTotal
	
	var rule
	for i in range(reactionRatesCumSum.size()):
		if(r2 <= reactionRatesCumSum[i]):
			rule = i
			break
	
	updatePersonNumbers(rule)
	
#	print(t, " t    r ", rule)
	
	return t

func updatePersonNumbers(rule):
	match rule:
		0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12: # Infektion Ungetestete Ungeimpfte
			S[0] -= 1
			I[0] += 1
		
		13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25: # Infektion Getestete Ungeimpfte
			S[1] -= 1
			I[2] += 1
			
		26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38: # Infektion V1
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[0][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[0][randomDay] -= 1
			V1[1][randomDay] += 1
		
		39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51: # Infektion V1eligible
			V1eligible[0] -= 1
			V1eligible[1] += 1
		
		52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64: # Infektion V2
			V2[0] -= 1
			V2[1] += 1
		
		# Infektion Pendler
		65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77: # Infektion ungeimpfte Pendler
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][0][0] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][0][0] -= 1
			visitors[randomNeighbor][1][1][0] += 1
		
		78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90: # Infektion 1x geimpfte Pendler
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][0][1] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][0][1] -= 1
			visitors[randomNeighbor][1][1][1] += 1
			
		91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103: # Infektion 2x geimpfte Pendler
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][0][2] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][0][2] -= 1
			visitors[randomNeighbor][1][1][2] += 1
		
		# Genesung Infizierte I
		104:
			I[0] -= 1
			R[0] += 1
			
		105:
			I[1] -= 1
			R[2] += 1
			
		106:
			I[2] -= 1
			R[2] += 1
		
		107:
			I[3] -= 1
			R[1] += 1
		
		# Genesung Infizierte V1
		108:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[1][randomDay] -= 1
			V1[3][randomDay] += 1
		
		109:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[2][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[2][randomDay] -= 1
			V1[3][randomDay] += 1
		
		# Genesung Infizierte V1eligible
		110:
			V1eligible[1] -= 1
			V1eligible[3] += 1
			
		111:
			V1eligible[2] -= 1
			V1eligible[3] += 1
		
		# Genesung Infizierte V2
		112:
			V2[1] -= 1
			V2[3] += 1
		
		113:
			V2[2] -= 1
			V2[3] += 1
		
		# Genesung Pendler
		# Genesung ungeimpfte Pendler
		114: 
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][1][0] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][1][0] -= 1
			visitors[randomNeighbor][1][2][0] += 1
		
		# Genesung 1x geimpfte Pendler
		115:
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][1][1] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][1][1] -= 1
			visitors[randomNeighbor][1][2][1] += 1
		
		# Genesung 2x geimpfter Pendler
		116:
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][1][2] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][1][2] -= 1
			visitors[randomNeighbor][1][2][2] += 1
			
		# Tod Infizierte I
		117:
			I[0] -= 1
			D[0] += 1
		
		118:
			I[1] -= 1
			D[1] += 1
		
		119:
			I[2] -= 1
			D[2] += 1
		
		120:
			I[3] -= 1
			D[1] += 1
		
		# Tod Infizierte V1
		121:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[1][randomDay] -= 1
			V1[4][randomDay] += 1
			
		122:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[2][randomDay] -= 1
			V1[4][randomDay] += 1
		
		# Tod Infizierte V1eligible
		123:
			V1eligible[1] -= 1
			V1eligible[4] += 1
		
		124:
			V1eligible[2] -= 1
			V1eligible[4] += 1
		
		# Tod Infizierte V2
		125:
			V2[1] -= 1
			V2[4] += 1
		
		126:
			V2[2] -= 1
			V2[4] += 1
		
		# Tod Pendler
		# Tod ungeimpfter Pendler
		127:
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][1][0] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][1][0] -= 1
			visitors[randomNeighbor][1][3][0] += 1
			
		# Tod 1x geimpfter Pendler
		128:
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][1][1] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][1][1] -= 1
			visitors[randomNeighbor][1][3][1] += 1
		
		# Tod 2x geimpfter Pendler
		129:
			var randomNeighbor = rnd.randi_range(0, visitors.size() - 1)
			while true:
				if visitors[randomNeighbor][1][1][2] != 0:
					break
				else:
					randomNeighbor += 1
					randomNeighbor = randomNeighbor % visitors.size()
			
			visitors[randomNeighbor][1][1][2] -= 1
			visitors[randomNeighbor][1][3][2] += 1
		
		# Tests von Ungeimpften
		130:
			S[0] -= 1
			S[1] += 1
		
		131:
			I[0] -= 1
			I[1] += 1
		
		132:
			R[0] -= 1
			R[1] += 1
		
		# Verlust Getestetenstatus
		133:
			S[1] -= 1
			S[0] += 1
		
		134:
			I[1] -= 1
			I[0] += 1
		
		135:
			R[1] -= 1
			R[0] += 1
		
		# Hospitalisierungen
		# Hospitalisierung Ungeimpfte
		136:
			I[0] -= 1
			I[3] += 1
		
		137:
			I[1] -= 1
			I[3] += 1
		
		138:
			I[2] -= 1
			I[3] += 1
		
		# Hospitalisierung V1
		139:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
					
			V1[1][randomDay] -= 1
			V1[2][randomDay] += 1
		
		# Hospitalisierung V1eligible
		140:
			V1eligible[1] -= 1
			V1eligible[2] += 1
		
		# Hospitalisierung V2
		141:
			V2[1] -= 1
			V2[2] += 1
		
		# Impfungen
		# ERSTE IMPFUNG
		# von S zu V1
		142:
			S[0] -= 1
			V1[0][waitDay] += 1
			self.avlbVax -= 1
		
		143:
			S[1] -= 1
			V1[0][waitDay] += 1
			self.avlbVax -= 1
		
		# von R zu V1
		144:
			R[0] -= 1
			V1[3][waitDay] += 1
			self.avlbVax -= 1
		
		145:
			R[1] -= 1
			V1[3][waitDay] += 1
			self.avlbVax -= 1
		
		146:
			R[2] -= 1
			V1[3][waitDay] += 1
			self.avlbVax -= 1
		# ZWEITE IMPFUNG
		# Impfung nur für gesunde und genesene, während Infektion keine Impfung
		147:
			V1eligible[0] -= 1
			V2[0] += 1
			self.avlbVax -= 1
		
		148:
			V1eligible[2] -= 1
			V2[2] += 1
			self.avlbVax -= 1
		
		149:
			V1eligible[3] -= 1
			V2[3] += 1
			self.avlbVax -= 1
		

func updateReactionRates():
	var rates = []
	
	# 0 1 2 3 4 5 6 7 8 9 10 11 12 Infektion Ungetestete
	rates.append((infectRate[0]/population)*S[0]*I[0]) 									# Ansteckung an Ungetestet Infizierten
	rates.append((infectRate[1]/population)*S[0]*I[1]) 									# Ansteckung an Getestet Infizierten
	rates.append((infectRate[0]/population)*S[0]*I[2]) 									# Ansteckung an Unbewusst Infizierten (ungetestet)
	rates.append((infectRate[2]/population)*S[0]*I[3]) 									# Ansteckung an Ungeimpften Hospitalisierten
	rates.append((infectRate[3]/population)*S[0]*CONSTANTS.sum(V1[1])) 					# Ansteckung an einfach Geimpften (noch ohne Zulassung zweite Impfung)
	rates.append((infectFactorHosp*infectRate[3]/population)*S[0]*CONSTANTS.sum(V1[2]))	# Ansteckung an einfach Geimpften Hospitalisierten (noch ohne Zulassung zweite Impfung)
	rates.append((infectRate[3]/population)*S[0]*V1eligible[1]) 						# Ansteckung an einfach Geimpften
	rates.append((infectFactorHosp*infectRate[3]/population)*S[0]*V1eligible[2])		# Ansteckung an einfach Geimpften Hospitalisierten
	rates.append((infectRate[4]/population)*S[0]*V2[1]) 								# Ansteckung an zweifach Geimpften
	rates.append((infectFactorHosp*infectRate[4]/population)*S[0]*V2[2])				# Ansteckung an zweifach Geimpften Hospitalisierten
	rates.append((infectRate[0]/population)*S[0]*sumVisitors(1,0))						# Ansteckung an ungeimpften, infizierten Pendlern
	rates.append((infectRate[3]/population)*S[0]*sumVisitors(1,1))						# Ansteckung an 1x geimpften, infizierten Pendlern
	rates.append((infectRate[4]/population)*S[0]*sumVisitors(1,2))						# Ansteckung an 2x geimpften, infizierten Pendlern
	
	# 13 14 15 16 17 18 19 20 21 22 23 24 25 Infektion Getestete, also unbewusste Krankheitsänderung
	rates.append((infectRate[0]/population)*S[1]*I[0])
	rates.append((infectRate[1]/population)*S[1]*I[1])
	rates.append((infectRate[0]/population)*S[1]*I[2])
	rates.append((infectRate[2]/population)*S[1]*I[3])
	rates.append((infectRate[3]/population)*S[1]*CONSTANTS.sum(V1[1]))
	rates.append((infectFactorHosp*infectRate[3]/population)*S[1]*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*S[1]*V1eligible[1])
	rates.append((infectFactorHosp*infectRate[3]/population)*S[1]*V1eligible[2])
	rates.append((infectRate[4]/population)*S[1]*V2[1])
	rates.append((infectFactorHosp*infectRate[4]/population)*S[1]*V2[2])
	rates.append((infectRate[0]/population)*S[1]*sumVisitors(1,0))
	rates.append((infectRate[3]/population)*S[1]*sumVisitors(1,1))
	rates.append((infectRate[4]/population)*S[1]*sumVisitors(1,2))
	
	# 26 27 28 29 30 31 32 33 34 35 36 37 38 Infektion V1
	rates.append((infectRate[0]/population)*CONSTANTS.sum(V1[0])*I[0])
	rates.append((infectRate[1]/population)*CONSTANTS.sum(V1[0])*I[1])
	rates.append((infectRate[0]/population)*CONSTANTS.sum(V1[0])*I[2])
	rates.append((infectRate[2]/population)*CONSTANTS.sum(V1[0])*I[3])
	rates.append((infectRate[3]/population)*CONSTANTS.sum(V1[0])*CONSTANTS.sum(V1[1]))
	rates.append((infectFactorHosp*infectRate[3]/population)*CONSTANTS.sum(V1[0])*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*CONSTANTS.sum(V1[0])*V1eligible[1])
	rates.append((infectFactorHosp*infectRate[3]/population)*CONSTANTS.sum(V1[0])*V1eligible[2])
	rates.append((infectRate[4]/population)*CONSTANTS.sum(V1[0])*V2[1])
	rates.append((infectFactorHosp*infectRate[4]/population)*CONSTANTS.sum(V1[0])*V2[2])
	rates.append((infectRate[0]/population)*CONSTANTS.sum(V1[0])*sumVisitors(1,0))
	rates.append((infectRate[3]/population)*CONSTANTS.sum(V1[0])*sumVisitors(1,1))
	rates.append((infectRate[4]/population)*CONSTANTS.sum(V1[0])*sumVisitors(1,2))

	# 39 40 41 42 43 44 45 46 47 48 49 50 51 Infektion V1eligible
	rates.append((infectRate[0]/population)*V1eligible[0]*I[0])
	rates.append((infectRate[1]/population)*V1eligible[0]*I[1])
	rates.append((infectRate[0]/population)*V1eligible[0]*I[2])
	rates.append((infectRate[2]/population)*V1eligible[0]*I[3])
	rates.append((infectRate[3]/population)*V1eligible[0]*CONSTANTS.sum(V1[1]))
	rates.append((infectFactorHosp*infectRate[3]/population)*V1eligible[1]*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*V1eligible[0]*V1eligible[1])
	rates.append((infectFactorHosp*infectRate[3]/population)*V1eligible[1]*V1eligible[2])
	rates.append((infectRate[4]/population)*V1eligible[0]*V2[1])
	rates.append((infectFactorHosp*infectRate[4]/population)*V1eligible[1]*V2[2])
	rates.append((infectRate[0]/population)*V1eligible[0]*sumVisitors(1,0))
	rates.append((infectRate[3]/population)*V1eligible[0]*sumVisitors(1,1))
	rates.append((infectRate[4]/population)*V1eligible[0]*sumVisitors(1,2))

	# 52 53 54 55 56 57 58 59 60 61 62 63 64 Infektion V2
	rates.append((infectRate[0]/population)*V2[0]*I[0])
	rates.append((infectRate[1]/population)*V2[0]*I[1])
	rates.append((infectRate[0]/population)*V2[0]*I[2])
	rates.append((infectRate[2]/population)*V2[0]*I[3])
	rates.append((infectRate[3]/population)*V2[0]*CONSTANTS.sum(V1[1]))
	rates.append((infectFactorHosp*infectRate[3]/population)*V2[1]*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*V2[0]*V1eligible[1])
	rates.append((infectFactorHosp*infectRate[3]/population)*V2[1]*V1eligible[2])
	rates.append((infectRate[4]/population)*V2[0]*V2[1])
	rates.append((infectFactorHosp*infectRate[4]/population)*V2[1]*V2[2])
	rates.append((infectRate[0]/population)*V2[0]*sumVisitors(1,0))
	rates.append((infectRate[3]/population)*V2[0]*sumVisitors(1,1))
	rates.append((infectRate[4]/population)*V2[0]*sumVisitors(1,2))
	
	# Infektion Pendler/Visitors
	# 65 66 67 68 69 70 71 72 73 74 75 76 77 Infektion ungeimpfte Pendler
	rates.append((infectRate[0]/population)*sumVisitors(0,0)*I[0])
	rates.append((infectRate[1]/population)*sumVisitors(0,0)*I[1])
	rates.append((infectRate[0]/population)*sumVisitors(0,0)*I[2])
	rates.append((infectRate[2]/population)*sumVisitors(0,0)*I[3])
	rates.append((infectRate[3]/population)*sumVisitors(0,0)*CONSTANTS.sum(V1[1]))
	rates.append((infectFactorHosp*infectRate[3]/population)*sumVisitors(0,0)*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*sumVisitors(0,0)*V1eligible[1])
	rates.append((infectFactorHosp*infectRate[3]/population)*sumVisitors(0,0)*V1eligible[2])
	rates.append((infectRate[4]/population)*sumVisitors(0,0)*V2[1])
	rates.append((infectFactorHosp*infectRate[4]/population)*sumVisitors(0,0)*V2[2])
	rates.append((infectRate[0]/population)*sumVisitors(0,0)*sumVisitors(1,0))
	rates.append((infectRate[3]/population)*sumVisitors(0,0)*sumVisitors(1,1))
	rates.append((infectRate[4]/population)*sumVisitors(0,0)*sumVisitors(1,2))


	# 78 79 80 81 82 83 84 85 86 87 88 89 90 Infektion 1x geimpfte Pendler
	rates.append((infectRate[0]/population)*sumVisitors(0,1)*I[0])
	rates.append((infectRate[1]/population)*sumVisitors(0,1)*I[1])
	rates.append((infectRate[0]/population)*sumVisitors(0,1)*I[2])
	rates.append((infectRate[2]/population)*sumVisitors(0,1)*I[3])
	rates.append((infectRate[3]/population)*sumVisitors(0,1)*CONSTANTS.sum(V1[1]))
	rates.append((infectFactorHosp*infectRate[3]/population)*sumVisitors(0,1)*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*sumVisitors(0,1)*V1eligible[1])
	rates.append((infectFactorHosp*infectRate[3]/population)*sumVisitors(0,1)*V1eligible[2])
	rates.append((infectRate[4]/population)*sumVisitors(0,1)*V2[1])
	rates.append((infectFactorHosp*infectRate[4]/population)*sumVisitors(0,0)*V2[2])
	rates.append((infectRate[0]/population)*sumVisitors(0,1)*sumVisitors(1,0))
	rates.append((infectRate[3]/population)*sumVisitors(0,1)*sumVisitors(1,1))
	rates.append((infectRate[4]/population)*sumVisitors(0,1)*sumVisitors(1,2))

	# 91 92 93 94 95 96 97 98 99 100 101 102 103 Infektion 2x geimpfte Pendler
	rates.append((infectRate[0]/population)*sumVisitors(0,2)*I[0])
	rates.append((infectRate[1]/population)*sumVisitors(0,2)*I[1])
	rates.append((infectRate[0]/population)*sumVisitors(0,2)*I[2])
	rates.append((infectRate[2]/population)*sumVisitors(0,2)*I[3])
	rates.append((infectRate[3]/population)*sumVisitors(0,2)*CONSTANTS.sum(V1[1]))
	rates.append((infectFactorHosp*infectRate[3]/population)*sumVisitors(0,2)*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*sumVisitors(0,2)*V1eligible[1])
	rates.append((infectFactorHosp*infectRate[3]/population)*sumVisitors(0,2)*V1eligible[2])
	rates.append((infectRate[4]/population)*sumVisitors(0,2)*V2[1])
	rates.append((infectFactorHosp*infectRate[4]/population)*sumVisitors(0,0)*V2[2])
	rates.append((infectRate[0]/population)*sumVisitors(0,2)*sumVisitors(1,0))
	rates.append((infectRate[3]/population)*sumVisitors(0,2)*sumVisitors(1,1))
	rates.append((infectRate[4]/population)*sumVisitors(0,2)*sumVisitors(1,2))
	
	# 104 105 106 107 Genesung Infizierte I
	rates.append(recRate[0]*I[0])
	rates.append(recRate[0]*I[1])
	rates.append(recRate[0]*I[2])
	rates.append(recRate[1]*I[3])
	
	# 108 109 Genesung Infizierte V1
	rates.append(recRate[2]*CONSTANTS.sum(V1[1]))
	rates.append(((recRate[1]+recRate[2])/2) * CONSTANTS.sum(V1[2]))
	
	# 110 111 Genesung Infizierte V1eligible
	rates.append(recRate[2]*V1eligible[1])
	rates.append(((recRate[1]+recRate[2])/2) * V1eligible[2])
	
	# 112 113 Genesung Infizierte V2
	rates.append(recRate[3]*V2[1])
	rates.append(((recRate[1]+recRate[3])/2) * V2[2])
	
	# Genesung Pendler/Visitors
	# 114 Genesung ungeimpfte Pendler
	rates.append(recRate[0]*sumVisitors(1,0))
	
	# 115 Genesung 1x geimpfte Pendler
	rates.append(recRate[2]*sumVisitors(1,1))
	
	# 116 Genesung 2x geimpfte Pendler 
	rates.append(recRate[3]*sumVisitors(1,2))
	
	
	# 117 118 119 120 Tod Inifizierte I
	rates.append(deathRate[0]*I[0])
	rates.append(deathRate[0]*I[1])
	rates.append(deathRate[0]*I[2])
	rates.append(deathRate[1]*I[3])
	
	# 121 122 Tod Infizierte V1
	rates.append(deathRate[2] * CONSTANTS.sum(V1[1]))
	rates.append(deathRate[2] * deathFactorHosp * CONSTANTS.sum(V1[2]))

	# 123 124 Tod Infizierte V1eligible
	rates.append(deathRate[2] * V1eligible[1])
	rates.append(deathRate[2] * deathFactorHosp * V1eligible[2])

	# 125 126 Tod Infizierte V2
	rates.append(deathRate[3] * V2[1])
	rates.append(deathRate[3] * deathFactorHosp * V2[2])
	
	# Tod Pendler/Visitors
	# 127 Tod ungeimpfte Pendler
	rates.append(deathRate[0] * sumVisitors(1,0))
	
	# 128 Tod 1x geimpfte Pendler
	rates.append(deathRate[2] * sumVisitors(1,1))
	
	# 129 Tod 2x geimpfte Pendler
	rates.append(deathRate[3] * sumVisitors(1,2))
	
	# 130 131 132 Testraten
	rates.append(testRate[0]*S[0])
	rates.append(testRate[1]*I[0])
	rates.append(testRate[2]*R[0])
	
	# 133 134 135 Loss of information, Getestete verlieren Getestetenstatus
	rates.append(informationLoss*S[1])
	rates.append(informationLoss*I[1])
	rates.append(informationLoss*R[1])
	
	
	var occBeds = occupiedBeds()
	# 136 137 138 139 140 141 Hospitalisierungsrate
	rates.append(hospitalRate[0]*(hospitalBeds-occBeds)/population * I[0])									# Hospitalisierung Ungeimpfte
	rates.append(hospitalRate[0]*(hospitalBeds-occBeds)/population * I[1])									# Hospitalisierung Ungeimpfte
	rates.append(hospitalRate[0]*(hospitalBeds-occBeds)/population * I[2])									# Hospitalisierung Ungeimpfte
	rates.append(hospitalRate[1]*(hospitalBeds-occBeds)/population * CONSTANTS.sum(V1[1])) 					# Hospitalisierung 1x Geimpfte
	rates.append(hospitalRate[1]*(hospitalBeds-occBeds)/population * V1eligible[1])							# Hospitalisierung 1x Geimpfte
	rates.append(hospitalRate[2]*(hospitalBeds-occBeds)/population * V2[1])									# Hospitalisierung 2x Geimpfte
	
	
	# Impfungen
	# Übergang zu erster Impfung
	# 142 143 von S zu V1
	rates.append(vacRate1*avlbVax*S[0])
	rates.append(vacRate1*avlbVax*S[1])
	
	# 144 145 146 von R zu V1
	rates.append(vacRate1*avlbVax*R[0])
	rates.append(vacRate1*avlbVax*R[1])
	rates.append(vacRate1*avlbVax*R[2])

	# 147 148 149 von V1eligible zu V2 (nur noch nicht Angesteckte und Genesene bekommen zweite Impfung)
	rates.append(vacRate2*avlbVax*V1eligible[0])
	rates.append(vacRate2*avlbVax*V1eligible[2])
	rates.append(vacRate2*avlbVax*V1eligible[3])
	
	return rates
	
	
func sumVisitors(condition, vaxStatus): # condition: Krankheitsstatus, Impfstatus
	var sum = 0
	for visitor in visitors:
		sum += visitor[1][condition][vaxStatus]
	return sum

