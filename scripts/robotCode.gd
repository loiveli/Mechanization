extends Node3D

@export var robot: Robot
@export var selfCollider: StaticBody3D
@export var nearCollider: Area3D
@export var farCollider: Area3D
@export var angryReaction: GPUParticles3D
@export var happyReaction: GPUParticles3D

var personality: RobotAttributes.personalityTrait
var outputSpeed: int
var baseOutputSpeed: int
var magnetModifier: int



func initRobot(robotVariant):
	robot = robotVariant
	personality = robotVariant.attributes.personality
	baseOutputSpeed = robot.attributes.outputSpeed
	outputSpeed = robot.attributes.outputSpeed
	
func _ready():
	var model = robot.model.instantiate()
	calculateMagentism()
	add_child(model)
	

	
func calculateMagentism():
	var nearOverlap = nearCollider.get_overlapping_bodies()
	var farOverlap = farCollider.get_overlapping_bodies()
	var nearMachines = nearOverlap.filter(func(item): return item != selfCollider).map(func(machine): return machine.get_parent())
	var farMachines = farOverlap.filter(func(item):return item not in nearOverlap).map(func(machine): return machine.get_parent())
	var machines = nearMachines + farMachines
	var rival = self.robot.attributes.rivalPersonality
	var matching = self.robot.attributes.matchPersonality
	if machines.size() >0:
		
		var magnetNumber = 0
		
		for machine in nearMachines:
			var personalityTrait = machine.personality
			if personalityTrait == personality:
				magnetNumber += 2
			elif personalityTrait == rival:
				magnetNumber -=2
				
			elif personalityTrait == matching:
				magnetNumber += 3
				
		for machine in farMachines:
			var personalityTrait = machine.personality
			
			if personalityTrait == personality:
				magnetNumber += 1
			elif personalityTrait == rival:
				magnetNumber -=1
				
			elif personalityTrait == matching:
				magnetNumber += 2
		
		var magnetDelta = magnetNumber - magnetModifier
		print("Calculating magnetism for", self.name)
		print("Magnet number: ", magnetNumber, " Magnet modifier: ", magnetModifier, " Magnet Delta: ", magnetDelta)
		if magnetDelta < 0:
			angryReaction.emitting = true
			print("Angry particles from ", self.name)
		if magnetDelta > 0:
			happyReaction.emitting = true
			print("Happy particles ", self.name)

		magnetModifier = magnetNumber
		robot.attributes.outputSpeed = baseOutputSpeed + magnetModifier
	
			
	
	
