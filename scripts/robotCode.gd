extends Node3D

@export var robot: Robot
@export var selfCollider: StaticBody3D
@export var nearCollider: Area3D
@export var farCollider: Area3D
@export var angryReaction: PackedScene
@export var happyReaction: PackedScene
@export var particleMagnet: GPUParticlesAttractorBox3D

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
	add_child(model)
	
	var builder = get_tree().get_first_node_in_group("builder")
	await get_tree().physics_frame
	
	var rival = self.robot.attributes.rivalPersonality
	var matching = self.robot.attributes.matchPersonality
	print(rival, matching)
	


func spawnParticlesToward(target: Node3D, scene: PackedScene):
	if scene == null:
		print("ERROR: scene is null!")
		return
	var newParticles = scene.instantiate() as GPUParticles3D
	if newParticles == null:
		print("ERROR: instantiated scene is not a GPUParticles3D!")
		return
	add_child(newParticles)
	newParticles.add_to_group("dynamic_particles")
	var mat = newParticles.process_material.duplicate() as ParticleProcessMaterial
	var dir = (target.global_position - global_position).normalized()
	var localDir = global_transform.basis.inverse() * dir
	var distance = global_position.distance_to(target.global_position)
	var speed = 4.0
	mat.direction = dir
	mat.spread = 0.0
	mat.initial_velocity_min = speed
	mat.initial_velocity_max = speed
	newParticles.process_material = mat
	# Lifetime = distance / speed so particles expire exactly at the target
	newParticles.lifetime = distance / speed
	newParticles.emitting = true

	
func calculateMagnetism(allRobots: Array):
	for child in get_children():
		if child.is_in_group("dynamic_particles"):
			child.queue_free()
	
	var rival = self.robot.attributes.rivalPersonality
	var matching = self.robot.attributes.matchPersonality
	var magnetNumber = 0

	for machine in allRobots:
		if machine == self:
			continue
		var distance = global_position.distance_to(machine.global_position)
		var personalityTrait = machine.personality
		if distance <= 1.9:
			if personalityTrait == personality:
				spawnParticlesToward(machine, happyReaction)
				magnetNumber += 2
			elif personalityTrait == rival:
				spawnParticlesToward(machine, angryReaction)
				magnetNumber -= 2
			elif personalityTrait == matching:
				spawnParticlesToward(machine, happyReaction)
				magnetNumber += 3
		elif distance <= 2.9:
			if personalityTrait == personality:
				spawnParticlesToward(machine, happyReaction)
				magnetNumber += 1
			elif personalityTrait == rival:
				spawnParticlesToward(machine, angryReaction)
				magnetNumber -= 1
			elif personalityTrait == matching:
				spawnParticlesToward(machine, happyReaction)
				magnetNumber += 2

	magnetModifier = magnetNumber
	robot.attributes.outputSpeed = baseOutputSpeed + magnetModifier
