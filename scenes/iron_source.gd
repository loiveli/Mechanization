extends Node3D

@export var model: PackedScene
@export var item_scene: PackedScene
@export var spawn_interval: float = 5

var _eject_direction: Vector3 = Vector3.ZERO
var _timer: float = 0.0

func _ready() -> void:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = get_mesh(model)
	add_child(mesh_instance)

	var area = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = mesh_instance.mesh.create_convex_shape()
	area.add_child(shape)
	add_child(area)

func setup(world_position: Vector3, eject_direction: Vector3) -> void:
	global_position = world_position
	_eject_direction = eject_direction.normalized()
	_spawn_item()

func _process(delta: float) -> void:
	if _eject_direction == Vector3.ZERO:
		return
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
	if Input.is_action_just_pressed("spawn_object"):
		_spawn_item()

func _spawn_item() -> void:
	var entity = item_scene.instantiate()
	get_tree().current_scene.add_child(entity)
	entity.global_position = global_position + Vector3(0, 0.1, 0)
	entity.rotation.y = randf_range(0.0, PI * 2.0)

# Pulls the first Mesh resource out of a PackedScene — mirrors robotPlacement.gd
	entity.setup(global_position + Vector3(0, 2, 0))

func get_mesh(packed_scene: PackedScene) -> Mesh:
	var scene_state: SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if scene_state.get_node_type(i) == "MeshInstance3D":
			for j in scene_state.get_node_property_count(i):
				if scene_state.get_node_property_name(i, j) == "mesh":
					return scene_state.get_node_property_value(i, j).duplicate()
	return null
