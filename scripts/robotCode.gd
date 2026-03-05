extends Node3D

@export var robot: Robot
@export var selfCollider: StaticBody3D
@export var nearCollider: Area3D
@export var farCollider: Area3D
var personality: RobotAttributes.personalityTrait
var outputSpeed: int
var baseOutputSpeed: int
var magnetModifier: int

func initRobot(robotVariant):
	robot = robotVariant
	personality = robot.attributes.personality
	baseOutputSpeed = robot.attributes.outputSpeed
	outputSpeed = robot.attributes.outputSpeed
func _ready():
	var model = robot.model.instantiate()
	calculateMagentism()
	add_child(model)

func _physics_process(delta: float) -> void:
	calculateMagentism()

func calculateMagentism():
	var nearOverlap = nearCollider.get_overlapping_bodies()
	var farOverlap = farCollider.get_overlapping_bodies()
	var nearMachines = nearOverlap.filter(func(item): return item != selfCollider).map(func(machine): return machine.get_parent())
	var farMachines = farOverlap.filter(func(item):return item not in nearOverlap).map(func(machine): return machine.get_parent())
	var machines = nearMachines + farMachines
	if machines.size() >0:
		
		var magnetNumber = 0
		
		for machine in nearMachines:
			var personalityTrait = machine.personality
			if personalityTrait == 0:
				return
			elif personalityTrait == personality:
				magnetNumber += 2
			elif personalityTrait == (personality -1) % RobotAttributes.personalityTrait.size():
				magnetNumber -=2
			elif personalityTrait == (personality +2) % RobotAttributes.personalityTrait.size():
				magnetNumber += 3
				
		for machine in farMachines:
			var personalityTrait = machine.personality
			if personalityTrait == 0:
				return
			elif personalityTrait == personality:
				magnetNumber += 1
			elif personalityTrait == (personality -1) % RobotAttributes.personalityTrait.size():
				magnetNumber -=1
			elif personalityTrait == (personality +2) % RobotAttributes.personalityTrait.size():
				magnetNumber += 2
		magnetModifier = magnetNumber
		robot.attributes.outputSpeed = baseOutputSpeed + magnetModifier
			
	
	
