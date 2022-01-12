# Class for all the federal states of germany.
extends Object

class_name State

var name
var population
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

var hosp = [CONSTANTS.HOSPITALISED]		# Hospitalisierte

var timeDifference
var timeDifferenceV1

var rnd = RandomNumberGenerator.new()

func _init(initName, initPopulation, initButton):
	self.name = initName
	self.population = initPopulation
	self.mapButton = initButton
	
	var image = Image.new()
	image.load("res://resources/map/" + name + ".png")
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	mapButton.toggle_mode = true
	
	
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
	infectRate = [getInfectRate(), getInfectRate(), getInfectRate()*0.5, getInfectRate()*0.4, getInfectRate()*0.2]
	recRate = [baseRec, baseRec, baseRec, baseRec*1.2]
	deathRate = [baseDeath, baseDeath, baseDeath, baseDeath/10]
	testRate = [baseTest, baseTest, baseTest]
	hospitalBeds = 20
	hospitalRate = 0.6
	
#	# für Lockdown
	lockdownStrictness = 0.9
	
	var vacDelayArr = CONSTANTS.zeroes(CONSTANTS.VACDELAY)
	# für Impfung
	self.V1 = [vacDelayArr,vacDelayArr,vacDelayArr,vacDelayArr] # "Förderband-Methode" für vacDelay um genau zu tracken
	self.V1eligible = [0,0,0,0]
	
	# Indizierung V1 (einmal geimpft): (Infizierte werden nicht geimpft)
	# 0: Ansteckbar (S)
	# 1: Infiziert (I)
	# 2: Genesen (nur erste Impfung, danach Genesene ganz normal zu zweimal Geimpften zählen) (R)
	# 3: Gestorben (D)
	
	self.V2 = [0,0,0,0,0]
	
	# Indizierung V1eligible und V2 (zweimal geimpft)
	# 0: Ansteckbar (S)
	# 1: Infiziert (I)
	# 2: Hospitalisiert (H)
	# 3: Genesen (R)
	# 4: Gestorben (D)
	
#	VinfectRate = [baseInfect, baseInfect, baseInfect]
#	VdeathRate = [baseDeath, baseDeath, baseDeath]
#	VrecRate = [baseRec, baseRec, baseRec]
	
	vacRate1 = 2
	vacRate2 = 18
	
	
	timeDifference = 0
	timeDifferenceV1 = 0
	
	rnd.randomize()

func getInfectRate():
	if lockdown:
		return baseInfect * (1-lockdownStrictness)
	else:
		return baseInfect

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
			
	
	simulateV1()
	print(V1)
	
	V1eligible[0] += V1[0][waitDay]
	V1eligible[1] += V1[1][waitDay] 
	V1eligible[2] += V1[2][waitDay] 
	V1eligible[3] += V1[3][waitDay] 
	
	V1[0][waitDay] = 0
	V1[1][waitDay] = 0
	V1[2][waitDay] = 0
	V1[3][waitDay] = 0
	
	waitDay += 1
	if waitDay == CONSTANTS.VACDELAY - 1:
		waitDay = 0
	
	
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
		0, 1, 2:
			S[0] -= 1
			I[0] += 1
		
		3, 4, 5:
			S[1] -= 1
			I[2] += 1
		
		6:
			I[0] -= 1
			R[0] += 1
		
		7:
			I[1] -= 1
			R[1] += 1
		
		8:
			I[2] -= 1
			R[2] += 1
		
		9:
			I[0] -= 1
			D[0] += 1
		
		10:
			I[1] -= 1
			D[1] += 1
		
		11:
			I[2] -= 1
			D[2] += 1
		
		12:
			S[0] -= 1
			S[1] += 1
		
		13:
			I[0] -= 1
			I[1] += 1
		
		14:
			R[0] -= 1
			R[1] += 1
		
		15:
			S[1] -= 1
			S[0] += 1
		
		16:
			I[2] -= 1
			I[0] += 1
		
		17:
			R[2] -= 1
			R[0] += 1
		
		18:
			S[0] -= 1
			I[0] += 1
		
		19:
			S[1] -= 1
			I[1] += 1
		
		20:
			S[2] -= 1
			I[2] += 1
		
		21:
			I[0] -= 1
			I[3] += 1
		
		22:
			I[1] -= 1
			I[3] += 1
		
		23:
			I[2] -= 1
			I[3] += 1
		
		24:
			I[3] -= 1
			R[1] += 1
		
		25:
			I[3] -= 1
			D[1] += 1
	
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
#	Modell mit Tests
	# 0 1 2 Infektion Ungetestete  Hier Raten anpassen mit V2?
	rates.append((infectRate[0]/population)*S[0]*I[0])
	rates.append((infectRate[0]/population)*S[0]*I[1])
	rates.append((infectRate[0]/population)*S[0]*I[2])
#	rates.append((infectRate[0]/population)*S[0]*V1eligible[1])
#	rates.append((infectRate[0]/population)*S[0]*V2[1])
	
	# 3 4 5 Infektion Getestete
	rates.append((infectRate[1]/population)*S[1]*I[0])
	rates.append((infectRate[1]/population)*S[1]*I[1])
	rates.append((infectRate[1]/population)*S[1]*I[2])
#	rates.append((infectRate[1]/population)*S[1]*V1eligible[1])
#	rates.append((infectRate[1]/population)*S[1]*V2[1])
	
	# 6 7 8 Genesung
	rates.append(recRate[0]*I[0])
	rates.append(recRate[1]*I[1])
	rates.append(recRate[2]*I[2])
	
	# 9 10 11 Tod
	rates.append(deathRate[0]*I[0])
	rates.append(deathRate[1]*I[1])
	rates.append(deathRate[2]*I[2])
	
	# 12 13 14 Testraten
	rates.append(testRate[0]*S[0])
	rates.append(testRate[1]*I[0])
	rates.append(testRate[2]*R[0])
	
	# 15 Loss of information, Getestete verlieren Getestetenstatus
	rates.append(informationLoss*S[1])
	
	# 16 17 unbemerkt Angesteckte und Genesene
	rates.append(informationLoss*I[2])
	rates.append(informationLoss*R[2])
	

	# Ab hier Raten für Hospitalisierung
	# Davon ausgehen 100% Testrate im Krankenhaus, Genesene aus Krankenhaus in Getestet/Genesen stecken
	# 18 19 20 Ansteckungen an Hospitalisierten
	rates.append((infectRate[2]/population)*S[0]*I[3])
	rates.append((infectRate[2]/population)*S[1]*I[3])
#	rates.append((infectRate[2]/population)*S[2]*I[3])
	rates.append(0) # ist noch hier, dass die Nummern der Regeln passen, da keine unbemerkt wieder Susceptible werden können

	# 21 22 23 Hospitalisierungsrate
	rates.append(hospitalRate*(hospitalBeds-I[3])/population * I[0])
	rates.append(hospitalRate*(hospitalBeds-I[3])/population * I[1])
	rates.append(hospitalRate*(hospitalBeds-I[3])/population * I[2])

	# 24 Genesung Hospitalisierte
	rates.append(recRate[3]*I[3])

	# 25 Tod Hospitalisierte
	rates.append(deathRate[3]*I[3])
	
	# Übergang zu erster Impfung
	# 26 27 von S zu V1
#	rates.append(vacRate1*avlbVax*S[0])
#	rates.append(vacRate1*avlbVax*S[1])
	
	# 28 29	30 von R zu V1
#	rates.append(vacRate1*avlbVax*R[0])
#	rates.append(vacRate1*avlbVax*R[1])
#	rates.append(vacRate1*avlbVax*R[2])
#
#	# 31 32 von V1eligible zu V2 (nur noch nicht Angesteckte und Genesene bekommen zweite Impfung)
#	rates.append(vacRate2*avlbVax*V1eligible[0])
#	rates.append(vacRate2*avlbVax*V1eligible[2])
	
	# Modell für V1eligible
	# 33 34 35 Infektion einmal Geimpfter
#	rates.append((infectRate[3]/population)*V1eligible[0]*I[0])
#	rates.append((infectRate[3]/population)*V1eligible[0]*I[1])
#	rates.append((infectRate[3]/population)*V1eligible[0]*I[2])
#
#	# Modell für zweimal Geimpfte
#	# 33 34 35 Infektion Ansteckbarer zweifach Geimpfter
#	rates.append((infectRate[4]/population)*V2[0]*I[0])
#	rates.append((infectRate[4]/population)*V2[0]*I[1])
#	rates.append((infectRate[4]/population)*V2[0]*I[2])
#
#	# 36 Genesung zweifach Geimpfter
#	rates.append()
#
#	# 37 Hospitalisierung zweifach Geimpfter
#	rates.append()
	
#	Standardmodell
#	rates.append((infectRate/population)*S*I)
#	rates.append(recRate*I)
#	rates.append(deathRate*I)
	
	return rates
	


func simulateV1():
	infectRate = [getInfectRate(), getInfectRate(), getInfectRate()*0.5, getInfectRate()*0.4, getInfectRate()*0.2]
	var t = timeDifferenceV1
	for i in V1.size():
		while t < 1:
			t = gillespieV1(t, i)
			if(t>1):
				timeDifferenceV1 = fmod(t,1)
				continue
		
	
func gillespieV1(t, block):
	var r1 = rnd.randf()
	var reactionRates = updateReactionRatesV1()
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
	
	updatePersonNumbersV1(rule, block)
	
#	print(t, " t    r ", rule)
	
	return t


# TODO HIER GESCHEITE REGELN AUFSTELLEN BZW GESCHEITE RATEN 
func updateReactionRatesV1():
	var rates = []
	# 1 gesunde zu Infizierten NOCH ANDERE INFECTRATE
	# Summe von allen normalen S, allen einaml geimpften S, und zweimal Geimpften
	rates.append((infectRate[0]/population) * (CONSTANTS.sum(S)+CONSTANTS.sum(V1[0]) + V1eligible[0] + V2[0]) * (CONSTANTS.sum(I) + CONSTANTS.sum(V1[1]) + V1eligible[1] + V2[1]))
	
	# 2 Genesung von Infizierten
	rates.append(recRate[0] * (CONSTANTS.sum(I) + CONSTANTS.sum(V1[1]) + V1eligible[1] + V2[1] + V2[2]))
	
	# 3 Tode von Infizierten
	rates.append(deathRate[0] * (CONSTANTS.sum(I) + CONSTANTS.sum(V1[1]) + V1eligible[1] + V2[1] + V2[2]))
	
	
	return rates
	

func updatePersonNumbersV1(rule, block):
	match rule:
		1:
			V1[0][block] -= 1
			V1[1][block] += 1
		2:
			V1[1][block] -= 1
			V1[2][block] += 1
		3:
			V1[1][block] -= 1
			V1[3][block] += 1


