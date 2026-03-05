extends ItemList

@export var robotBuilder: Node3D

func _ready() -> void:
	var robotInventory = robotBuilder.get("robotInventory")
	for robot in robotInventory:
		add_item(robot.attributes.name)

	
