extends Node

class_name CONSTANTS

const BL = " "

const TIMER = "Timer"

#const CALCULATIONTIMER = "CalculationTimer"

#const LINELENGTH = 80

const PROGRESSBAR = "Progressbar"
const PROGRESSPANEL = "ProgressPanel"
const SIMANIMATION = "SimAnimation"
const INTERVENTIONWEIGHT = "InterventionWeight"

const NO = "No"
const LIGHT = "Light"
const MEDIUM = "Medium"
const HEAVY = "Heavy"
const USERDEFINED = "Userdefined"

const ACTIONCONTAINER = "ActionContainer"
const LOCKDOWNOPTION = "LockDownOption"
const MASKOPTION = "MaskOption"
const HOMEOFFICEOPTION = "HomeOfficeOption"
const HOSPITALBEDSPINBOX = "HospitalBedSpinbox"
const VAXPRODUCTIONSPINBOX = "VaxProductionSpinbox"
const TESTOPTION = "TestOption"
const BORDERCONTROL = "BorderControl"
const BORDERTIP = "BorderTip"
const OCCBEDS = "OccBeds"
const AVLBLVAX = "AvailableVax"

const GODMODEBUTTON = "GodmodeButton"
const RESTARTBUTTON = "RestartButton"
const CONFIRMRESTART = "ConfirmRestart"

const OPTIONBUTTON = "OptionButton"
const MENUBUTTON = "MenuButton"

#const LEGEND = "Legend"

const COUNTRYNAME = "Countryname"
const STATCONTAINER = "StatContainer"
const OVERVIEW = "Overview"
const OVERVIEWLEGEND = "OverviewLegend"
const OVERVIEWHEADLINE = "Anzahl getesteter Fälle"
const VAXSTATUS = "Impfstatus"
const VAXSTATUSLEGEND = "VaxStatusLegend"

const DAILYVAXCHANGES = "DailyChanges"
const DAILYLEGEND = "DailyLegend"
const NEWINFECTIONS = "Neuinfektionen"
const NEWINFECTIONSLEGEND = "NewInfectionsLegend"
const DAILYINFECTIONNUMBERS = "DailyInfectionNumbers"

const INCIDENCESCALETITLE = "Inzidenz - Skala"
const INCIDENCELABELS = "IncidenceLabels"

const FIRSTVAX = "Erstimpfungen"
const SECONDVAX = "Zweitimpfungen"


const RVALUE = "R-Wert"
const INCIDENCE = "Inzidenz"
const HOSPBEDS = "Verfügbare Betten"
const BEDSTATUS = "BedStatus"
const HOSPITALALLOCATION = "HospitalAllocation"
const ALLOCATIONPLACEHOLER = "AllocationPlaceHolder"
const ALLOCATIONLEGEND = "AllocationLegend"
const BEDSLEGEND = "BedsLegend"
const DEATHOVERVIEW = "DeathOverview"
const DEATHLEGEND = "DeathLegend"
const DEATHNUMBERS = "DeathNumbers"


const ENDCONTAINER = "EndContainer"
const SUMMARYOVERVIEW = "SummaryOverview"
const SUMMARYOVERVIEWLEGEND = "SummaryOverviewLegend"

const SUMMARY = "Summary"

const VAXSUMMARY = "VaxSummary"
const VAXSUMMARYLEGEND = "VaxSummaryLegend"
const VAXSUMMARYTEXT = "VaxSummaryText"

const DEATHSUMMARY = "DeathSummary"
const DEATHSUMMARYLEGEND = "DeathSummaryLegend"
const DEATHSUMMARYTEXT = "DeathSummaryText"

const CHRONIC = "Chronic"
const CHRONICLEGEND = "ChronicLegend"
const CHRONICSUMMARYTEXT = "ChronicSummaryText"

const ENDRESTART = "EndRestart"


const WEEK = 7
const MONTH = 30
const YEAR = 360
const MAX = int(INF)

const ENDEMICTIMEFACTOR = 2.5

const MAPBACKGROUND = "MapBackground"

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
const ENDMODE = "End"

const STATBUTTON = "StatButton"
const ACTIONBUTTON = "ActionButton"

const PAUSEBUTTON = "PauseButton"
const PLAYBUTTON = "PlayButton"
const PLAYX2BUTTON = "PlayX2Button"

#const TRYOUT_DAYS = 100
const DAYS = "Tag"

const HEALTHSTATUS = "Gesundheitsstatus"
const SUSCEPTIBLE = "Gesund"
const INFECTED = "Infiziert"
const RECOVERED = "Genesen"
const DEAD = "Tot"
const HOSPITALISED = "Hospitalisiert"

const TESTED = "Getestet"
const NTESTED = "Nicht Getestet"
const UNAWARE = "Unbewusst"

const UNVAXED = "Ungeimpft"
const VAX1 = "1x Geimpft"
const VAX2 = "2x Geimpft"

const DIFFERENTSETTINGS = 5

const LOCKDOWNSTRICTNESS = [0, 1-0.816, 1-0.66, 1-0.451]
const MASKFACTORS = [0,1-0.5,1-0.1,1-0.04]
const COMMUTERFACTORS = [1, 1-0.24, 1-0.42, (1 - 0.43) * 0.42]

const TESTRATES = [0.0, 0.001, 0.0025, 0.005]


const SUPERINDICATORSTEPS = [0,10,25,50,100,250,500,1000,2500,5000,10000]

#const VACDELAY = 10
var VACDELAY :int = 21

var POPULATIONFACTOR :float = 0.01

var GODMODE :bool = false

var currentProgress :int


# Calculate sum of an array
static func sum(arr):
	var sum = 0
	for i in range(arr.size()):
		sum += arr[i]
	return sum

#static func sumIndex(arr, index):
#	var sum :float = 0
#	for entry in arr:
#		sum += entry[index]
#	return sum

# Calculate cumulative sum for each entry of an array
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

# Create an empty array with a length
static func zeroes(length : int):
	var arr = []
	for _i in range(length):
		arr.append(0)
	return arr

static func average(arr:Array):
	var sum = sum(arr)
	return float(sum) / float(arr.size())


	
