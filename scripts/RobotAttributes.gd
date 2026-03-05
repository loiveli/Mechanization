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
@export var personality: personalityTrait
var rivalPersonality: personalityTrait
var matchPersonality: personalityTrait

func _init(p_name = "", p_speed = 1, p_output = partType.STEEL, p_input = [] as Array[partType], p_personality = personalityTrait.values().pick_random() ):
	name = p_name
	outputSpeed = p_speed
	output = p_output
	input = p_input
	personality = p_personality
	rivalPersonality = personalityTrait.values()[rivalMap[personality]]
	matchPersonality = personalityTrait.values()[matchMap[personality]]
	
