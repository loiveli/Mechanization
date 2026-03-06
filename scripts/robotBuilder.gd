extends Node3D

@export var robots: Array[Robot] = []



@export var robotInventory: Dictionary[Robot,int]
#@export var conveyorBelt: Robot
var robotList: Array[Node3D]

signal robot_spawned


var map: DataMap

var index: int = -1 # Index of robot being built



enum PlacementMode { ROBOT, BELT }
var placement_mode: PlacementMode = PlacementMode.ROBOT

@export var selector: Node3D
@export var selector_container: Node3D
@export var view_camera: Camera3D
@export var selector_collider: Area3D

#@export var conveyor_belt_scene: Camera3D




var plane:Plane # Used for raycasting mouse


# Item source creation
const IronSourceScene = preload("res://scenes/iron_source.tscn")
const ItemEntityScene = preload("res://scenes/item.tscn")
const IronResource = preload("res://resources/iron.tres")

var conveyor_belt_scene = preload("res://scenes/conveyor_belt.tscn")


var item_sources = [
	{ "pos": Vector3(-4, 0, 0), "dir": Vector3(0, 0, -1) },
]

func _ready():
	print(get_path())
	print(conveyor_belt_scene)
	#robotInventory[conveyor_belt_scene] = 1000
	print("selector_container = ", selector_container)
	print("selector = ", selector)
	print("view_camera = ", view_camera)
	add_to_group("builder")
	map = DataMap.new()
	plane = Plane(Vector3.UP, Vector3.ZERO)

	var mesh_library = MeshLibrary.new()

	for robot in robots:
		robotInventory[robot] = 1
		
		
	# Item Sources
		var id = mesh_library.get_last_unused_item_id()
		mesh_library.create_item(id)
		mesh_library.set_item_mesh(id, get_mesh(robot.model))
		mesh_library.set_item_mesh_transform(id, Transform3D())


	for data in item_sources:
		var source = IronSourceScene.instantiate()
		add_child(source)
		source.setup(data.pos, data.dir)


	
func _unhandled_input(event: InputEvent) -> void:
	var gridmap_position = getGridmapPosition()
	action_build(gridmap_position)
	
func getGridmapPosition():


	var world_position = plane.intersects_ray(
		view_camera.project_ray_origin(get_viewport().get_mouse_position()),
		view_camera.project_ray_normal(get_viewport().get_mouse_position()))

	var gridmap_position = Vector3(round(world_position.x), 0, round(world_position.z))
	return gridmap_position



func _process(delta):
	action_toggle_placement_mode()

	
	# Controls
	var gridmap_position = getGridmapPosition()
	action_rotate() # Rotates selection 90 degrees
	 # Toggles between structures
	
	# Map position based on mouse
	
	
	selector.position = lerp(selector.position, gridmap_position, min(delta * 40, 1.0))


	action_demolish()



func action_toggle_placement_mode():
	if Input.is_action_just_pressed("toggle_belt_mode"):
		if placement_mode == PlacementMode.ROBOT:
			placement_mode = PlacementMode.BELT
			print("Switched to BELT placement mode")
		else:
			placement_mode = PlacementMode.ROBOT
			print("Switched to ROBOT placement mode")
		update_structure(index)

func action_build(gridmap_position):
	if Input.is_action_just_pressed("build"):
		var overlapping = selector_collider.get_overlapping_bodies()
		
		var blocking = overlapping.filter(func(body):
			return not selector_container.is_ancestor_of(body)
			)
			
		if placement_mode == PlacementMode.BELT:
			if not blocking:
				build_belt(gridmap_position)
		else:
			var currentRobot = robotInventory.keys()[index]
			if not blocking:
				build_robot(currentRobot, gridmap_position)
			else:
				var result = blocking[0]
				var previousRobot = result.get_parent().get("Robot")
				if previousRobot != currentRobot:
					result.get_parent().queue_free()
					build_robot(currentRobot, gridmap_position)
					Audio.play("sounds/placement-a.ogg, sounds/placement-b.ogg, sounds/placement-c.ogg, sounds/placement-d.ogg", -20)

func build_robot(currentRobot, gridmap_position):
	var robot = preload("res://scenes/robot.tscn").instantiate()
	robot.initRobot(currentRobot)
	add_child(robot)
	robotList.append(robot)
	robot.transform.origin = gridmap_position
	robot.rotation = selector.rotation
	await get_tree().physics_frame
	for r in robotList:
		r.calculateMagnetism(robotList)


func build_belt(gridmap_position):
	print(conveyor_belt_scene)
	if conveyor_belt_scene == null:
		push_error("conveyor_belt_scene is not assigned in the Inspector!")
		return

	var belt = conveyor_belt_scene.instantiate()
	add_child(belt)
	belt.transform.origin = gridmap_position
	belt.rotation = selector.rotation

	# Derive belt direction from the selector's facing direction (forward = -Z rotated)
	var direction = -selector.global_transform.basis.z
	belt.init_belt(direction)

	Audio.play("sounds/placement-a.ogg, sounds/placement-b.ogg, sounds/placement-c.ogg, sounds/placement-d.ogg", -20)




# Demolish (remove) a structure

func action_demolish():
	if Input.is_action_just_pressed("demolish"):
		var overlapping = selector_collider.get_overlapping_bodies()
		if overlapping:
			var result = overlapping[0]
			var layer = result.get_collision_layer()
			if layer == 2:
				robotList.erase(result.get_parent())
				result.get_parent().queue_free()
			Audio.play("sounds/removal-a.ogg, sounds/removal-b.ogg, sounds/removal-c.ogg, sounds/removal-d.ogg", -20)

func action_rotate():
	if Input.is_action_just_pressed("rotate"):
		selector.rotate_y(deg_to_rad(90))
		Audio.play("sounds/rotate.ogg", -30)




# Toggle between structures to build

func action_structure_toggle():
	if placement_mode != PlacementMode.ROBOT:
		return

	if Input.is_action_just_pressed("structure_next"):
		index = wrap(index + 1, 0, robots.size())
		Audio.play("sounds/toggle.ogg", -30)

	if Input.is_action_just_pressed("structure_previous"):
		index = wrap(index - 1, 0, robots.size())
		Audio.play("sounds/toggle.ogg", -30)

	update_structure(index)




func _on_bot_inventory_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	update_structure(index)

func update_structure(robotIndex):
	# Clear previous structure preview in selector
	index = robotIndex
	for n in selector_container.get_children():
		selector_container.remove_child(n)

	if placement_mode == PlacementMode.BELT:
		if conveyor_belt_scene != null:
			var preview = conveyor_belt_scene.instantiate()
			selector_container.add_child(preview)
			preview.position.y += 0.25
	else:
		var _model = robotInventory.keys()[index].model.instantiate()
		selector_container.add_child(_model)
		_model.position.y += 0.25


func get_mesh(packed_scene):
	var scene_state: SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if scene_state.get_node_type(i) == "MeshInstance3D":
			for j in scene_state.get_node_property_count(i):
				var prop_name = scene_state.get_node_property_name(i, j)
				if prop_name == "mesh":
					var prop_value = scene_state.get_node_property_value(i, j)
					return prop_value.duplicate()
