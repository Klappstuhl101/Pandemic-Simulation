extends Object

class_name Simulation

var entities
var N
var S
var I
var R
var D

var infectRate
var recRate
var deathRate

var rnd = RandomNumberGenerator.new()

# Recovered nach gewisser Zeit wieder ansteckbar, Impfschutz nachlassen, kann man auch simulieren

func _init(initEntities):
	entities = initEntities
	N = 1000
	I = 3
	S = N - I
	R = 0
	D = 0
	
	infectRate = 0.2
	recRate = 0.02
	deathRate = 0.01
	
	rnd.randomize()
	
	
func simulate():
	if I <= 0: # pandemic over
		return
	var t = 0
#	var args = [t,S,I,R,D]
	while t<1:
		t = gillespieIteration(t)
#		t = args[0]
#		S = args[1]
#		I = args[2]
#		R = args[3]
#		D = args[4]
#		args = [t,S,I,R,D]
		print(t, " S ", S, " I ", I, " R ", R, " D ", D, " ", I+S+R+D)
		

func gillespieIteration(t):
	var r1 = rnd.randf()
	var reactionRates = updateReactionRates()
	var reactTotal = sum(reactionRates)
	
	var waitTime = -log(r1)/reactTotal
	t = t + waitTime
	
	
	reactionRates.sort()
	var r2 = rnd.randf()
	
	var reactionRatesCumSum = cumulative_sum(reactionRates)
	for i in range(reactionRatesCumSum.size()):
		reactionRatesCumSum[i] = reactionRatesCumSum[i] / reactTotal
	print(r2, " ",reactionRates, " ", reactionRatesCumSum)
#	läuft noch nicht hier, die reactionRates noch umrechnen auf passendes Intervall
	
	var rule
	for i in range(reactionRates.size()):
		if(r2 <= reactionRates[i]):
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
	rates.append((infectRate/N)*S*I)
	rates.append(recRate*I)
	rates.append(deathRate*I)
	return rates
	
func sum(arr):
	var sum = 0
	for i in range(arr.size()):
		sum += arr[i]
	return sum

func cumulative_sum(arr):
	for i in range(arr.size()):
		for j in range(i+1):
			print("cumsum", arr[i])
			arr[i] += arr[j]
	return arr
