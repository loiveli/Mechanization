class_name RobotAttributes
extends Resource

enum partType {ROBOT_LEG, ROBOT_ARM, ROBOT_HEAD, ROBOT_BODY}
enum personalityTrait {OPEN_SOURCE, CLOSED_SOURCE, PROTOTYPE, EOL}

@export var name: String
@export var outputSpeed: int
@export var output: partType
@export var input: partType
@export var personality: personalityTrait

func _init(p_name = "", p_speed = 1, p_output = partType.ROBOT_LEG, p_input = null, p_personality = personalityTrait.OPEN_SOURCE):
	name = p_name
	outputSpeed = p_speed
	output = p_output
	input = p_input
	personality = p_personality
