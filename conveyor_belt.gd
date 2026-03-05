extends Node3D

@export var model: PackedScene
@export var belt_speed: float = 2.0

var belt_direction: Vector3 = Vector3(0, 0, -1)

func _ready() -> void:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = get_mesh(model)
	add_child(mesh_instance)

	var body = StaticBody3D.new()
	body.set_collision_layer_value(2, true)
	var shape = CollisionShape3D.new()
	shape.shape = mesh_instance.mesh.create_convex_shape()
	body.add_child(shape)
	add_child(body)

	# Area3D to detect items passing over the belt
	var area = Area3D.new()
	var area_shape = CollisionShape3D.new()
	area_shape.shape = mesh_instance.mesh.create_convex_shape()
	area.add_child(area_shape)
	area.body_entered.connect(_on_item_entered)
	area.body_exited.connect(_on_item_exited)
	add_child(area)

func init_belt(direction: Vector3) -> void:
	belt_direction = direction.normalized()

func _on_item_entered(body: Node3D) -> void:
	if body.has_method("enter_conveyor"):
		body.enter_conveyor(belt_direction)
		body.move_speed = belt_speed

func _on_item_exited(body: Node3D) -> void:
	if body.has_method("exit_conveyor"):
		body.exit_conveyor()

func get_mesh(packed_scene: PackedScene) -> Mesh:
	var scene_state: SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if scene_state.get_node_type(i) == "MeshInstance3D":
			for j in scene_state.get_node_property_count(i):
				if scene_state.get_node_property_name(i, j) == "mesh":
					return scene_state.get_node_property_value(i, j).duplicate()
	return null
