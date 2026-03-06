class_name RobotAttributes
extends Resource

enum partType {STEEL,ROBOTLEG, ROBOTARM, ROBOTHEAD, ROBOTBODY, ROBOT}
enum personalityTrait {OPEN_SOURCE, CLOSED_SOURCE, PROTOTYPE, EOL}
var rivalMap = [1,0,3,2]
var matchMap = [3,2,1,0]


@export var name: String
@export var outputSpeed: int
@export var output: partType
@export var input: Array[partType]

var rivalPersonality: personalityTrait
var matchPersonality: personalityTrait


# Now the setter can reference them
@export var personality: personalityTrait:
	set(value):
		personality = value
		rivalPersonality = personalityTrait.values()[rivalMap[value]]
		matchPersonality = personalityTrait.values()[matchMap[value]]

func _init():
	name = ""
	outputSpeed = 1
	output = partType.STEEL
	input = [] as Array[partType]
	personality = personalityTrait.OPEN_SOURCE
	
