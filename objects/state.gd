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

var infectRate
var recRate
var deathRate

var testRate
var informationLoss
var sus0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]
var sus1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]
var sus2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.SUSCEPTIBLE]
var inf0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]
var inf1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.INFECTED]
var inf2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.INFECTED]
var rec0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]
var rec1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.RECOVERED]
var rec2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.RECOVERED]
var dead0 = [CONSTANTS.NTESTED + CONSTANTS.BL+ CONSTANTS.DEAD]
var dead1 = [CONSTANTS.TESTED + CONSTANTS.BL+ CONSTANTS.DEAD]
var dead2 = [CONSTANTS.UNAWARE + CONSTANTS.BL+ CONSTANTS.DEAD]

var timeDifference

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
	
#	self.I = 3
#	self.S = self.population - self.I
#	self.R = 0
#	self.D = 0
	
	self.I = [3,0,0]
	self.S = [self.population - self.I[0],0,0]
	self.R = [0,0,0]
	self.D = [0,0,0]
	
#	infectRate = 0.2
#	recRate = 0.02
#	deathRate = 0.005
#	deathRate = 0.01
	
	infectRate = [0.2,0.2,0.2]
	recRate = [0.02,0.02,0.02]
	deathRate = [0.01,0.01,0.01]
	
	testRate = [0.04,0.04,0.04]
	informationLoss = 0.02
	
	
	timeDifference = 0
	
	rnd.randomize()


func simulate():
#	if I <= 0: # pandemic over
#		return
	var t = timeDifference
	while t<1:
		t = gillespieIteration(t)
#		print(t, " S ", S, " I ", I, " R ", R, " D ", D, " ", I+S+R+D)
		if(t>1):
			timeDifference = fmod(t,1)
			continue
			
	
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
	
#	# Standardsimulation
#	suscept.append(S)
#	infect.append(I)
#	recov.append(R)
#	dead.append(D)

func gillespieIteration(t):
	var r1 = rnd.randf()
	var reactionRates = updateReactionRates()
	var reactTotal = sum(reactionRates)
	
	if reactTotal == 0:
		return 1
		
	var waitTime = -log(r1)/reactTotal
	t = t + waitTime
	
	var r2 = rnd.randf()
	
	var reactionRatesCumSum = cumulative_sum(reactionRates)
	for i in range(reactionRatesCumSum.size()):
		reactionRatesCumSum[i] = reactionRatesCumSum[i] / reactTotal
	
	var rule
	for i in range(reactionRatesCumSum.size()):
		if(r2 <= reactionRatesCumSum[i]):
			rule = i
			break

	updatePersonNumbers(rule)
	
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
	# 0 1 2 Infektion Ungetestete 
	rates.append((infectRate[0]/population)*S[0]*I[0])
	rates.append((infectRate[0]/population)*S[0]*I[1])
	rates.append((infectRate[0]/population)*S[0]*I[2])
	
	# 3 4 5 Infektion Getestete
	rates.append((infectRate[1]/population)*S[1]*I[0])
	rates.append((infectRate[1]/population)*S[1]*I[1])
	rates.append((infectRate[1]/population)*S[1]*I[2])
	
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
	
	
	
#	Standardmodell
#	rates.append((infectRate/population)*S*I)
#	rates.append(recRate*I)
#	rates.append(deathRate*I)
	
	return rates
	
func sum(arr):
	var sum = 0
	for i in range(arr.size()):
		sum += arr[i]
	return sum

func cumulative_sum(arr):
	for i in range(1,arr.size()):
		arr[i] += arr[i-1]
	return arr
