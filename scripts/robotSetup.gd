extends Node3D

@export var robot: Robot

func initRobot(initRobot):
	robot = initRobot

func _ready():
	var model = robot.model.instantiate()
	add_child(model)
