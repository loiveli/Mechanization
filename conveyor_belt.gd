extends Node3D

@export var model: PackedScene
@export var belt_speed: float = 2.0
var tracked_items: Array = []

var belt_direction: Vector3 = Vector3(0, 0, -1)
var area: Area3D

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

	area = Area3D.new()
	area.monitoring = true
	area.monitorable = true
	area.set_collision_mask_value(3, true)
	var area_shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(0.6, 1.0, 0.6)
	area_shape.position = Vector3(0, 0.5, 0)
	area_shape.shape = box
	area.add_child(area_shape)
	add_child(area)

func init_belt(direction: Vector3) -> void:
	belt_direction = direction.normalized()
	_draw_direction_arrow()

func _draw_direction_arrow() -> void:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.YELLOW
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	# Always built along local -Z (forward), rotation handles the rest
	var forward = Vector3(0, 0, -1)
	var right = Vector3(1, 0, 0) * 0.1

	var tip = forward * 0.4
	var base = -forward * 0.3
	var wing_base = forward * 0.1
	var head_right = Vector3(1, 0, 0) * 0.25

	# Shaft
	immediate_mesh.surface_add_vertex(base + right)
	immediate_mesh.surface_add_vertex(base - right)
	immediate_mesh.surface_add_vertex(wing_base + right)

	immediate_mesh.surface_add_vertex(base - right)
	immediate_mesh.surface_add_vertex(wing_base - right)
	immediate_mesh.surface_add_vertex(wing_base + right)

	# Arrowhead
	immediate_mesh.surface_add_vertex(wing_base + head_right)
	immediate_mesh.surface_add_vertex(wing_base - head_right)
	immediate_mesh.surface_add_vertex(tip)

	immediate_mesh.surface_end()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.material_override = material
	mesh_instance.position = Vector3(0, 0.55, 0)
	add_child(mesh_instance)

func _physics_process(delta: float) -> void:
	if area == null:
		return
	var current_bodies = area.get_overlapping_bodies()
	
	for body in tracked_items:
		if not is_instance_valid(body):
			continue
		if body not in current_bodies:
			if body.has_method("exit_conveyor"):
				body.exit_conveyor()
				
	for body in current_bodies:
		if not is_instance_valid(body):
			continue
		if body.has_method("enter_conveyor"):
			body.enter_conveyor(belt_direction)
			body.move_speed = belt_speed

	tracked_items = current_bodies

func get_mesh(packed_scene: PackedScene) -> Mesh:
	var scene_state: SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if scene_state.get_node_type(i) == "MeshInstance3D":
			for j in scene_state.get_node_property_count(i):
				if scene_state.get_node_property_name(i, j) == "mesh":
					return scene_state.get_node_property_value(i, j).duplicate()
	return null
