# Class for all the federal states of germany.
extends Object

class_name State

var name
var population
var neighbors
var visitors
var commuterRate

var mapButton


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

var VinfectRate
var VrecRate
var VdeathRate

var infectRate
var recRate
var deathRate

var hospitalBeds
var hospitalRate

var baseInfect
var baseRec
var baseDeath
var baseTest

var lockdown = false
var lockdownStrictness

var testRate
var informationLoss
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

var hosp = [CONSTANTS.HOSPITALISED]		# ungeimpfte Hospitalisierte

var timeDifference
var timeDifferenceV1

var rnd = RandomNumberGenerator.new()

func _init(initName, initPopulation, initButton, initNeighbors, initCommuter):
	self.name = initName
	self.population = initPopulation
	self.mapButton = initButton
	self.neighbors = initNeighbors
	self.commuterRate = initCommuter
	
	var image = Image.new()
	image.load("res://resources/map/" + name + ".png")
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	mapButton.toggle_mode = true
	
#	for neighbor in neighbors.values():
#		pass
	
	baseInfect = 0.2
	baseRec = 0.02
	baseDeath = 0.01
	baseTest = 0.04
	
	self.avlbVax = 0
#	# StandardSimulation
#	self.I = 3
#	self.S = self.population - self.I
#	self.R = 0
#	self.D = 0
	
#	infectRate = baseInfect
#	recRate = 0.02
#	deathRate = 0.005
#	deathRate = 0.01
	
	
#	# Test-Simulation
#	self.I = [3,0,0]
#	self.I = [16000,0,0]
	
#	# Hospitalisierung
	self.I = [3,0,0,0]
	
	
	# für Test und Hospitalisierung
	self.S = [self.population - self.I[0],0]
	self.R = [0,0,0]
	self.D = [0,0,0]
	informationLoss = 0.02
	
#	# nur Test-Simulation
#	infectRate = [baseInfect,baseInfect,baseInfect]
#	recRate = [0.02,0.02,0.02]
#	deathRate = [0.01,0.01,0.01]
#	testRate = [0.04,0.04,0.04]

	
	
	
#	# für Hospitalisierung
	infectRate = [getInfectRate(), getInfectRate(), getInfectRate()*0.5, getInfectRate()*0.4, getInfectRate()*0.2] 	# Ungetestet, Getestet, Hospitalisiert, 1x Geimpft, 2x Geimpft
	recRate = [baseRec, baseRec*1.6, baseRec*1.3, baseRec*1.6] 																# Ungeimpft, Hospitalisiert, 1x Geimpft, 2x Geimpft
	deathRate = [baseDeath, baseDeath*0.5, baseDeath*0.2, baseDeath*0.1]														# Ungeimpft, Hospitalisiert, 1x Geimpft, 2x Geimpft
	testRate = [baseTest, baseTest, baseTest]
	hospitalBeds = 20
	hospitalRate = 0.6
	
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
		var name = neighbors[i]
		var arr = [name, vis]
		visitors.append(arr)
	
	vacRate1 = 2
	vacRate2 = 18
	
	
	timeDifference = 0
	timeDifferenceV1 = 0
	
	rnd.randomize()

func occupiedBeds():
	return I[3] + CONSTANTS.sum(V1[2]) + V1eligible[2] + V2[2]

func getPopulation():
	return self.population

func getInfectRate():
	if lockdown:
		return baseInfect * (1-lockdownStrictness)
	else:
		return baseInfect

func getCommuteRate():
	return commuterRate

func simulate():
#	if I <= 0: # pandemic over
#		return
	infectRate = [getInfectRate(), getInfectRate(), getInfectRate()*0.5, getInfectRate()*0.4, getInfectRate()*0.2] # Ungetestet, Getestet, Hospitalisiert, 1x Geimpft, 2x Geimpft
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
	
	
	
#	# Standardsimulation
#	suscept.append(S)
#	infect.append(I)
#	recov.append(R)
#	dead.append(D)

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
		0, 1, 2, 3, 4, 5, 6, 7, 8, 9:
			S[0] -= 1
			I[0] += 1
		
		10, 11, 12, 13, 14, 15, 16, 17, 18, 19:
			S[1] -= 1
			I[2] += 1
			
		20, 21, 22, 23, 24, 25, 26, 27, 28, 29:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[0][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[0][randomDay] -= 1
			V1[1][randomDay] += 1
		
		30, 31, 32, 33, 34, 35, 36, 37, 38, 39:
			V1eligible[0] -= 1
			V1eligible[1] += 1
		
		40, 41, 42, 43, 44, 45, 46, 47, 48, 49:
			V2[0] -= 1
			V2[1] += 1
		
		50:
			I[0] -= 1
			R[0] += 1
			
		51:
			I[1] -= 1
			R[2] += 1
			
		52:
			I[2] -= 1
			R[2] += 1
		
		53:
			I[3] -= 1
			R[1] += 1
		
		54:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[1][randomDay] -= 1
			V1[3][randomDay] += 1
		
		55:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[2][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[2][randomDay] -= 1
			V1[3][randomDay] += 1
			
		56:
			V1eligible[1] -= 1
			V1eligible[3] += 1
			
		57:
			V1eligible[2] -= 1
			V1eligible[3] += 1
		
		58:
			V2[1] -= 1
			V2[3] += 1
		
		59:
			V2[2] -= 1
			V2[3] += 1
		
		60:
			I[0] -= 1
			D[0] += 1
		
		61:
			I[1] -= 1
			D[1] += 1
		
		62:
			I[2] -= 1
			D[2] += 1
		
		63:
			I[3] -= 1
			D[1] += 1
		
		64:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[1][randomDay] -= 1
			V1[4][randomDay] += 1
			
		65:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
			
			V1[2][randomDay] -= 1
			V1[4][randomDay] += 1
		
		66:
			V1eligible[1] -= 1
			V1eligible[4] += 1
		
		67:
			V1eligible[2] -= 1
			V1eligible[4] += 1
			
		68:
			V2[1] -= 1
			V2[4] += 1
		
		69:
			V2[2] -= 1
			V2[4] += 1
		
		70:
			S[0] -= 1
			S[1] += 1
		
		71:
			I[0] -= 1
			I[1] += 1
		
		72:
			R[0] -= 1
			R[1] += 1
		
		73:
			S[1] -= 1
			S[0] += 1
		
		74:
			I[2] -= 1
			I[0] += 1
		
		75:
			R[2] -= 1
			R[0] += 1
		
		76:
			I[0] -= 1
			I[3] += 1
		
		77:
			I[1] -= 1
			I[3] += 1
		
		78:
			I[2] -= 1
			I[3] += 1
		
		79:
			var randomDay = rnd.randi() % CONSTANTS.VACDELAY # random einem Block im Fließband zuweisen, bei dem V1[0], also Ansteckbare nicht null sind
			while true:
				if V1[1][randomDay] != 0:
					break
				else:
					randomDay += 1
					randomDay = randomDay % CONSTANTS.VACDELAY
					
			V1[1][randomDay] -= 1
			V1[2][randomDay] += 1
		
		80:
			V1eligible[1] -= 1
			V1eligible[2] += 1
		
		81:
			V2[1] -= 1
			V2[2] += 1
			
		82:
			S[0] -= 1
			V1[0][waitDay] += 1
			self.avlbVax -= 1
		
		83:
			S[1] -= 1
			V1[0][waitDay] += 1
			self.avlbVax -= 1
		
		84:
			R[0] -= 1
			V1[3][waitDay] += 1
			self.avlbVax -= 1
		
		85:
			R[1] -= 1
			V1[3][waitDay] += 1
			self.avlbVax -= 1
		
		86:
			V1eligible[0] -= 1
			V2[0] += 1
			self.avlbVax -= 1
		
		87:
			V1eligible[2] -= 1
			V2[2] += 1
			self.avlbVax -= 1
		
		
		
#		0, 1, 2:
#			S[0] -= 1
#			I[0] += 1
#
#		3, 4, 5:
#			S[1] -= 1
#			I[2] += 1
#
#		6:
#			I[0] -= 1
#			R[0] += 1
#
#		7:
#			I[1] -= 1
#			R[1] += 1
#
#		8:
#			I[2] -= 1
#			R[2] += 1
#
#		9:
#			I[0] -= 1
#			D[0] += 1
#
#		10:
#			I[1] -= 1
#			D[1] += 1
#
#		11:
#			I[2] -= 1
#			D[2] += 1
#
#		12:
#			S[0] -= 1
#			S[1] += 1
#
#		13:
#			I[0] -= 1
#			I[1] += 1
#
#		14:
#			R[0] -= 1
#			R[1] += 1
#
#		15:
#			S[1] -= 1
#			S[0] += 1
#
#		16:
#			I[2] -= 1
#			I[0] += 1
#
#		17:
#			R[2] -= 1
#			R[0] += 1
#
#		18:
#			S[0] -= 1
#			I[0] += 1
#
#		19:
#			S[1] -= 1
#			I[1] += 1
#
#		20:
#			S[2] -= 1
#			I[2] += 1
#
#		21:
#			I[0] -= 1
#			I[3] += 1
#
#		22:
#			I[1] -= 1
#			I[3] += 1
#
#		23:
#			I[2] -= 1
#			I[3] += 1
#
#		24:
#			I[3] -= 1
#			R[1] += 1
#
#		25:
#			I[3] -= 1
#			D[1] += 1
	
#	# Standardmodell
#	match rule:
#		0: # Neu Infizierte
#			S-=1
#			I+=1
#		1: # Genesene
#			I-=1
#			R+=1
#		2: # Tote
#			I-=1
#			D+=1

func updateReactionRates():
	var rates = []
	
	# 0 1 2 3 4 5 6 7 8 9 Infektion Ungetestete
	rates.append((infectRate[0]/population)*S[0]*I[0]) 									# Ansteckung an Ungetestet Infizierten
	rates.append((infectRate[1]/population)*S[0]*I[1]) 									# Ansteckung an Getestet Infizierten
	rates.append((infectRate[0]/population)*S[0]*I[2]) 									# Ansteckung an Unbewusst Infizierten (ungetestet)
	rates.append((infectRate[2]/population)*S[0]*I[3]) 									# Ansteckung an Ungeimpften Hospitalisierten
	rates.append((infectRate[3]/population)*S[0]*CONSTANTS.sum(V1[1])) 					# Ansteckung an einfach Geimpften (noch ohne Zulassung zweite Impfung)
	rates.append((infectRate[2]*infectRate[3]/population)*S[0]*CONSTANTS.sum(V1[2]))	# Ansteckung an einfach Geimpften Hospitalisierten (noch ohne Zulassung zweite Impfung)
	rates.append((infectRate[3]/population)*S[0]*V1eligible[1]) 						# Ansteckung an einfach Geimpften
	rates.append((infectRate[2]*infectRate[3]/population)*S[0]*V1eligible[2])			# Ansteckung an einfach Geimpften Hospitalisierten
	rates.append((infectRate[4]/population)*S[0]*V2[1]) 								# Ansteckung an zweifach Geimpften
	rates.append((infectRate[2]*infectRate[4]/population)*S[0]*V2[2])					# Ansteckung an zweifach Geimpften Hospitalisierten
	
	# 10 11 12 13 14 15 16 17 18 19 Infektion Getestete
	rates.append((infectRate[0]/population)*S[1]*I[0])
	rates.append((infectRate[1]/population)*S[1]*I[1])
	rates.append((infectRate[0]/population)*S[1]*I[2])
	rates.append((infectRate[2]/population)*S[1]*I[3])
	rates.append((infectRate[3]/population)*S[1]*CONSTANTS.sum(V1[1]))
	rates.append((infectRate[2]*infectRate[3]/population)*S[1]*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*S[1]*V1eligible[1])
	rates.append((infectRate[2]*infectRate[3]/population)*S[1]*V1eligible[2])
	rates.append((infectRate[4]/population)*S[1]*V2[1])
	rates.append((infectRate[2]*infectRate[4]/population)*S[1]*V2[2])
	
	# 20 21 22 23 24 25 26 27 28 29 Infektion V1
	rates.append((infectRate[0]/population)*CONSTANTS.sum(V1[0])*I[0])
	rates.append((infectRate[1]/population)*CONSTANTS.sum(V1[0])*I[1])
	rates.append((infectRate[0]/population)*CONSTANTS.sum(V1[0])*I[2])
	rates.append((infectRate[2]/population)*CONSTANTS.sum(V1[0])*I[3])
	rates.append((infectRate[3]/population)*CONSTANTS.sum(V1[0])*CONSTANTS.sum(V1[1]))
	rates.append((infectRate[2]*infectRate[3]/population)*CONSTANTS.sum(V1[0])*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*CONSTANTS.sum(V1[0])*V1eligible[1])
	rates.append((infectRate[2]*infectRate[3]/population)*CONSTANTS.sum(V1[0])*V1eligible[2])
	rates.append((infectRate[4]/population)*CONSTANTS.sum(V1[0])*V2[1])
	rates.append((infectRate[2]*infectRate[4]/population)*CONSTANTS.sum(V1[0])*V2[2])

	# 30 31 32 33 34 35 36 37 38 39 Infektion V1eligible
	rates.append((infectRate[0]/population)*V1eligible[0]*I[0])
	rates.append((infectRate[1]/population)*V1eligible[0]*I[1])
	rates.append((infectRate[0]/population)*V1eligible[0]*I[2])
	rates.append((infectRate[2]/population)*V1eligible[0]*I[3])
	rates.append((infectRate[3]/population)*V1eligible[0]*CONSTANTS.sum(V1[1]))
	rates.append((infectRate[2]*infectRate[3]/population)*V1eligible[1]*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*V1eligible[0]*V1eligible[1])
	rates.append((infectRate[2]*infectRate[3]/population)*V1eligible[1]*V1eligible[2])
	rates.append((infectRate[4]/population)*V1eligible[0]*V2[1])
	rates.append((infectRate[2]*infectRate[4]/population)*V1eligible[1]*V2[2])

	# 40 41 42 43 44 45 46 47 48 49 Infektion V2
	rates.append((infectRate[0]/population)*V2[0]*I[0])
	rates.append((infectRate[1]/population)*V2[0]*I[1])
	rates.append((infectRate[0]/population)*V2[0]*I[2])
	rates.append((infectRate[2]/population)*V2[0]*I[3])
	rates.append((infectRate[3]/population)*V2[0]*CONSTANTS.sum(V1[1]))
	rates.append((infectRate[2]*infectRate[3]/population)*V2[1]*CONSTANTS.sum(V1[2]))
	rates.append((infectRate[3]/population)*V2[0]*V1eligible[1])
	rates.append((infectRate[2]*infectRate[3]/population)*V2[1]*V1eligible[2])
	rates.append((infectRate[4]/population)*V2[0]*V2[1])
	rates.append((infectRate[2]*infectRate[4]/population)*V2[1]*V2[2])
	
	
	# 50 51 52 53 Genesung Infizierte I
	rates.append(recRate[0]*I[0])
	rates.append(recRate[0]*I[1])
	rates.append(recRate[0]*I[2])
	rates.append(recRate[1]*I[3])
	
	# 54 55 Genesung Infizierte V1
	rates.append(recRate[2]*CONSTANTS.sum(V1[1]))
	rates.append(((recRate[1]+recRate[2])/2) * CONSTANTS.sum(V1[2]))
	
	# 56 57 Genesung Infizierte V1eligible
	rates.append(recRate[2]*V1eligible[1])
	rates.append(((recRate[1]+recRate[2])/2) * V1eligible[2])

	# 58 59 Genesung Infizierte V2
	rates.append(recRate[3]*V2[1])
	rates.append(((recRate[1]+recRate[3])/2) * V2[2])



	# 60 61 62 63 Tod Inifizierte I
	rates.append(deathRate[0]*I[0])
	rates.append(deathRate[0]*I[1])
	rates.append(deathRate[0]*I[2])
	rates.append(deathRate[1]*I[3])
	
	# 64 65 Tod Infizierte V1
	rates.append(deathRate[2] * CONSTANTS.sum(V1[1]))
	rates.append(deathRate[2] * deathRate[1] * CONSTANTS.sum(V1[2]))

	# 66 67 Tod Infizierte V1eligible
	rates.append(deathRate[2] * V1eligible[1])
	rates.append(deathRate[2] * deathRate[1] * V1eligible[2])

	# 68 69 Tod Infizierte V2
	rates.append(deathRate[3] * V2[1])
	rates.append(deathRate[3] * deathRate[1] * V2[2])
	
	
	
	# 70 71 72 Testraten BLEIBT
	rates.append(testRate[0]*S[0])
	rates.append(testRate[1]*I[0])
	rates.append(testRate[2]*R[0])
	
	# 73 Loss of information, Getestete verlieren Getestetenstatus BLEIBT
	rates.append(informationLoss*S[1])
	
	# 74 75 unbemerkt Angesteckte und Genesene BLEIBT
	rates.append(informationLoss*I[2])
	rates.append(informationLoss*R[2])
	

	# Ab hier Raten für Hospitalisierung
	# Davon ausgehen 100% Testrate im Krankenhaus, Genesene aus Krankenhaus in Getestet/Genesen stecken
#	# 18 19 20 Ansteckungen an Hospitalisierten KOMMT RAUS
#	rates.append((infectRate[2]/population)*S[0]*I[3])
#	rates.append((infectRate[2]/population)*S[1]*I[3])
##	rates.append((infectRate[2]/population)*S[2]*I[3])
#	rates.append(0) # ist noch hier, dass die Nummern der Regeln passen, da keine unbemerkt wieder Susceptible werden können
	
	
	var occBeds = occupiedBeds()
	# 76 77 78 79 80 81 Hospitalisierungsrate
	rates.append(hospitalRate*(hospitalBeds-occBeds)/population * I[0])									# Hospitalisierung Ungeimpfte
	rates.append(hospitalRate*(hospitalBeds-occBeds)/population * I[1])									# Hospitalisierung Ungeimpfte
	rates.append(hospitalRate*(hospitalBeds-occBeds)/population * I[2])									# Hospitalisierung Ungeimpfte
	rates.append(hospitalRate*recRate[2]*(hospitalBeds-occBeds)/population * CONSTANTS.sum(V1[1])) 		# Hospitalisierung 1x Geimpfte
	rates.append(hospitalRate*recRate[2]*(hospitalBeds-occBeds)/population * V1eligible[1])				# Hospitalisierung 1x Geimpfte
	rates.append(hospitalRate*recRate[3]*(hospitalBeds-occBeds)/population * V2[1])						# Hospitalisierung 2x Geimpfte
	

#	# 24 Genesung Hospitalisierte KOMMT WEG
#	rates.append(recRate[1]*I[3])
#
#	# 25 Tod Hospitalisierte KOMMT WEG
#	rates.append(deathRate[1]*I[3])
	
	
	# Impfungen
	# Übergang zu erster Impfung
	# 82 83 von S zu V1
	rates.append(vacRate1*avlbVax*S[0])
	rates.append(vacRate1*avlbVax*S[1])
	
	# 84 85 von R zu V1
	rates.append(vacRate1*avlbVax*R[0])
	rates.append(vacRate1*avlbVax*R[1])

	# 86 87 von V1eligible zu V2 (nur noch nicht Angesteckte und Genesene bekommen zweite Impfung)
	rates.append(vacRate2*avlbVax*V1eligible[0])
	rates.append(vacRate2*avlbVax*V1eligible[2])
	
	
#	Standardmodell RAUS
#	rates.append((infectRate/population)*S*I)
#	rates.append(recRate*I)
#	rates.append(deathRate*I)
	
	return rates
	
	

	
	
#func simulateV1():
#	infectRate = [getInfectRate(), getInfectRate(), getInfectRate()*0.5, getInfectRate()*0.4, getInfectRate()*0.2]
#	var t = timeDifferenceV1
#	for i in V1.size():
#		while t < 1:
#			t = gillespieV1(t, i)
#			if(t>1):
#				timeDifferenceV1 = fmod(t,1)
#				continue
#
#
#func gillespieV1(t, block):
#	var r1 = rnd.randf()
#	var reactionRates = updateReactionRatesV1()
#	var reactTotal = CONSTANTS.sum(reactionRates)
#
#	if reactTotal == 0:
#		return 1
#
#	var waitTime = -log(r1)/reactTotal
#	t = t + waitTime
#
#	var r2 = rnd.randf()
#
#	var reactionRatesCumSum = CONSTANTS.cumulative_sum(reactionRates)
#	for i in range(reactionRatesCumSum.size()):
#		reactionRatesCumSum[i] = reactionRatesCumSum[i] / reactTotal
#
#	var rule
#	for i in range(reactionRatesCumSum.size()):
#		if(r2 <= reactionRatesCumSum[i]):
#			rule = i
#			break
#
#	updatePersonNumbersV1(rule, block)
#
##	print(t, " t    r ", rule)
#
#	return t
#
#
## TODO HIER GESCHEITE REGELN AUFSTELLEN BZW GESCHEITE RATEN 
#func updateReactionRatesV1():
#	var rates = []
#	# 1 gesunde zu Infizierten NOCH ANDERE INFECTRATE
#	# Summe von allen normalen S, allen einaml geimpften S, und zweimal Geimpften
#	rates.append((infectRate[0]/population) * (CONSTANTS.sum(S)+CONSTANTS.sum(V1[0]) + V1eligible[0] + V2[0]) * (CONSTANTS.sum(I) + CONSTANTS.sum(V1[1]) + V1eligible[1] + V2[1]))
#
#	# 2 Genesung von Infizierten
#	rates.append(recRate[0] * (CONSTANTS.sum(I) + CONSTANTS.sum(V1[1]) + V1eligible[1] + V2[1] + V2[2]))
#
#	# 3 Tode von Infizierten
#	rates.append(deathRate[0] * (CONSTANTS.sum(I) + CONSTANTS.sum(V1[1]) + V1eligible[1] + V2[1] + V2[2]))
#
#
#	return rates
#
#
#func updatePersonNumbersV1(rule, block):
#	match rule:
#		1:
#			V1[0][block] -= 1
#			V1[1][block] += 1
#		2:
#			V1[1][block] -= 1
#			V1[2][block] += 1
#		3:
#			V1[1][block] -= 1
#			V1[3][block] += 1



