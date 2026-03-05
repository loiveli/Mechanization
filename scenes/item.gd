extends CharacterBody3D

@export var model: PackedScene
@export var move_speed: float = 2.0

var on_conveyor: bool = false
var conveyor_direction: Vector3 = Vector3.ZERO
var _collected: bool = false

func setup(world_position: Vector3) -> void:
	global_position = world_position

	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = get_mesh(model)
	add_child(mesh_instance)

	var shape = CollisionShape3D.new()
	shape.shape = mesh_instance.mesh.create_convex_shape()
	add_child(shape)
	
	var area = Area3D.new()
	var area_shape = CollisionShape3D.new()
	area_shape.shape = mesh_instance.mesh.create_convex_shape()
	area.add_child(area_shape)
	add_child(area)

func _physics_process(delta: float) -> void:
	if _collected:
		return

	# Always apply gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	# Apply conveyor movement on X/Z only
	if on_conveyor:
		velocity.x = conveyor_direction.normalized().x * move_speed
		velocity.z = conveyor_direction.normalized().z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

func collect() -> void:
	if _collected:
		return
	_collected = true
	on_conveyor = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(queue_free)

func enter_conveyor(direction: Vector3) -> void:
	print("enter_conveyor called! direction = ", direction)
	on_conveyor = true
	conveyor_direction = direction

func exit_conveyor() -> void:
	on_conveyor = false
	conveyor_direction = Vector3.ZERO

func get_mesh(packed_scene: PackedScene) -> Mesh:
	var scene_state: SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if scene_state.get_node_type(i) == "MeshInstance3D":
			for j in scene_state.get_node_property_count(i):
				if scene_state.get_node_property_name(i, j) == "mesh":
					return scene_state.get_node_property_value(i, j).duplicate()
	return null
