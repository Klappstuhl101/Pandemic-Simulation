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

var timeDifference

var rnd = RandomNumberGenerator.new()


func _init(initName, initPopulation, initButton):
	self.name = initName
	self.population = initPopulation
	self.mapButton = initButton
	
	self.I = 3
	self.S = self.population - self.I
	self.R = 0
	self.D = 0
	
	var image = Image.new()
	image.load("res://resources/map/" + name + ".png")
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	mapButton.texture_click_mask = bitmap
	mapButton.toggle_mode = true
	
	infectRate = 0.2
	recRate = 0.02
	deathRate = 0.01
	
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
	suscept.append(S)
	infect.append(I)
	recov.append(R)
	dead.append(D)

func gillespieIteration(t):
	var r1 = rnd.randf()
	var reactionRates = updateReactionRates()
	var reactTotal = sum(reactionRates)
	
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
		0: # Neu Infizierte
			S-=1
			I+=1
		1: # Genesene
			I-=1
			R+=1
		2: # Tote
			I-=1
			D+=1

func updateReactionRates():
	var rates = []
	rates.append((infectRate/population)*S*I)
	rates.append(recRate*I)
	rates.append(deathRate*I)
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
