extends Object

class_name Simulation

var entities
var N
var S
var I
var R
var D

# Recovered nach gewisser Zeit wieder ansteckbar, Impfschutz nachlassen, kann man auch simulieren

func _init(initEntities):
	entities = initEntities
	N = 1000
	I = 3
	S = N - I
	R = 0
	D = 0
	
	
func simulate():
	var t = 0
	while t<1:
		gillespieIteration()
	
	pass

func gillespieIteration():
	pass
