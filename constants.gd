extends Node

class_name CONSTANTS

const BL = " "

const LABEL = "Label"
const PIE = "Pie"
const LINE = "Line"
const LINE2 = "Line2"
const LINE3 = "Line3"
const LINE4 = "Line4"
const LINE5 = "Line5"
const LINE6 = "Line6"

const BAW = "Baden-Württemberg"
const BAY = "Bayern"
const BER = "Berlin"
const BRA = "Brandenburg"
const BRE = "Bremen"
const HAM = "Hamburg"
const HES = "Hessen"
const MVP = "Mecklenburg-Vorpommern"
const NIE = "Niedersachsen"
const NRW = "Nordrhein-Westfalen"
const RLP = "Rheinland-Pfalz"
const SAA = "Saarland"
const SCN = "Sachsen"
const SCA = "Sachsen-Anhalt"
const SLH = "Schleswig-Holstein"
const THU = "Thüringen"

const DEU = "Deutschland"

const STATMODE = "Stats"
const ACTIONMODE = "Action"

const STATBUTTON = "StatButton"

const TRYOUT_DAYS = 100

const SUSCEPTIBLE = "Susceptible"
const INFECTED = "Infected"
const RECOVERED = "Recovered"
const DEAD = "Dead"
const HOSPITALISED = "Hospitalised"

const TESTED = "Tested"
const NTESTED = "Not Tested"
const UNAWARE = "Unaware"

const VAX1 = "1x Vaccinated"
const VAX2 = "2x Vaccinated"

const VACDELAY = 10




static func sum(arr):
	var sum = 0
	for i in range(arr.size()):
		sum += arr[i]
	return sum

static func cumulative_sum(arr):
	for i in range(1,arr.size()):
		arr[i] += arr[i-1]
	return arr

# add the entries of two same length arrays
static func add_arrays(arr1, arr2):
	var new = []
	var counter = 0
	while counter < arr1.size() and counter < arr2.size():
		new.append(arr1[counter] + arr2[counter])
		counter += 1
	return new

static func zeroes(length : int):
	var arr = []
	for i in range(length):
		arr.append(0)
	return arr
