# DIESE KLASSE WIRD NICHT MEHR GEBRAUCHT, BLEIBT ABER TROTZDEM ZUM NACHSCHAUEN NOCH DA


extends Object

class_name Simulation

var entities
var N
var S
var I
var R
var D

var days = ["Days"]
var sStats = ["S"]
var iStats = ["I"]
var rStats = ["R"]
var dStats = ["D"]


var infectRate
var recRate
var deathRate

var timeDifference

var rnd = RandomNumberGenerator.new()

# Recovered nach gewisser Zeit wieder ansteckbar, Impfschutz nachlassen, kann man auch simulieren

func _init(initEntities):
	entities = initEntities
	N = 1000
	I = 3
	S = N - I
	R = 0
	D = 0
	
	for i in range(CONSTANTS.TRYOUT_DAYS):
		days.append(i)
		
	infectRate = 0.2
	recRate = 0.02
	deathRate = 0.01
	
	timeDifference = 0
	
	rnd.randomize()
	
	
#func simulate():
##	if I <= 0: # pandemic over
##		return
#	var t = timeDifference
#	while t<1:
#		t = gillespieIteration(t)
#		print(t, " S ", S, " I ", I, " R ", R, " D ", D, " ", I+S+R+D)
#		if(t>1):
#			timeDifference = fmod(t,1)
#			continue
##		print(t, " S ", S, " I ", I, " R ", R, " D ", D, " ", I+S+R+D)
#	sStats.append(S)
#	iStats.append(I)
#	rStats.append(R)
#	dStats.append(D)
#
#func gillespieIteration(t):
#	var r1 = rnd.randf()
#	var reactionRates = updateReactionRates()
#	var reactTotal = sum(reactionRates)
#
#	var waitTime = -log(r1)/reactTotal
#	t = t + waitTime
#
#	var r2 = rnd.randf()
#
#	var reactionRatesCumSum = cumulative_sum(reactionRates)
#	for i in range(reactionRatesCumSum.size()):
#		reactionRatesCumSum[i] = reactionRatesCumSum[i] / reactTotal
#
##	print(r2," ", reactTotal, " ",reactionRates, " ", reactionRatesCumSum)
##	läuft noch nicht hier, die reactionRates noch umrechnen auf passendes Intervall
#
## ZEIT OVERFLOW MITNEHMEN IN NÄCHSTEN TAG, EVENT NOCH AUSFÜHREN
#
#	var rule
#	for i in range(reactionRatesCumSum.size()):
#		if(r2 <= reactionRatesCumSum[i]):
#			rule = i
#			break
#
#	updatePersonNumbers(rule)
#
#	return t
#
#func updatePersonNumbers(rule):
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
#
#func updateReactionRates():
#	var rates = []
#	rates.append((infectRate/N)*S*I)
#	rates.append(recRate*I)
#	rates.append(deathRate*I)
#	return rates
#
#func sum(arr):
#	var sum = 0
#	for i in range(arr.size()):
#		sum += arr[i]
#	return sum
#
#func cumulative_sum(arr):
#	for i in range(1,arr.size()):
#		arr[i] += arr[i-1]
#	return arr
