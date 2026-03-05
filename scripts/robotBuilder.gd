extends Node3D

@export var robots: Array[Robot] = []


@export var robotInventory: Dictionary[Robot,int]
@export var conveyorBelt: Robot

var map:DataMap

var index:int = -1 # Index of structure being built

@export var selector:Node3D # The 'cursor'
@export var selector_container:Node3D # Node that holds a preview of the structure
@export var view_camera:Camera3D # Used for raycasting mouse
@export var selector_collider: Area3D

var plane:Plane # Used for raycasting mouse

# Item source creation
const IronSourceScene = preload("res://scenes/iron_source.tscn")
const ItemEntityScene = preload("res://scenes/item.tscn")
const IronResource = preload("res://resources/iron.tres")

var item_sources = [
	{ "pos": Vector3(-4, 0, 0), "dir": Vector3(0, 0, -1) },
]

func _ready():
	print("selector_container = ", selector_container)
	print("selector = ", selector)
	print("view_camera = ", view_camera)
	robotInventory[conveyorBelt] = 1000
	
	map = DataMap.new()
	plane = Plane(Vector3.UP, Vector3.ZERO)
	# Create new MeshLibrary dynamically, can also be done in the editor
	# See: https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html
	
	var mesh_library = MeshLibrary.new()
	
	for robot in robots:
		robotInventory[robot] = 1
		var id = mesh_library.get_last_unused_item_id()
		
		mesh_library.create_item(id)
		mesh_library.set_item_mesh(id, get_mesh(robot.model))
		mesh_library.set_item_mesh_transform(id, Transform3D())
		
	# Item Sources
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
	
	# Controls
	var gridmap_position = getGridmapPosition()
	action_rotate() # Rotates selection 90 degrees
	 # Toggles between structures
	
	# Map position based on mouse
	
	
	selector.position = lerp(selector.position, gridmap_position, min(delta * 40, 1.0))
	
	action_demolish()

# Retrieve the mesh from a PackedScene, used for dynamically creating a MeshLibrary

func get_mesh(packed_scene):
	var scene_state:SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if(scene_state.get_node_type(i) == "MeshInstance3D"):
			for j in scene_state.get_node_property_count(i):
				var prop_name = scene_state.get_node_property_name(i, j)
				if prop_name == "mesh":
					var prop_value = scene_state.get_node_property_value(i, j)
					
					return prop_value.duplicate()

# Build (place) a structure

func build_robot(currentRobot, gridmap_position):
	var robot = preload("res://scenes/robot.tscn").instantiate()
	robot.initRobot(currentRobot)
	add_child(robot)
	robot.transform.origin = gridmap_position
	robot.rotation = selector.rotation

func action_build(gridmap_position):
	if index<0:
		return
	if Input.is_action_just_pressed("build"):
		var overlapping = selector_collider.get_overlapping_bodies()
		var currentRobot = robotInventory.keys()[index]
		if not overlapping:
			build_robot(currentRobot, gridmap_position)
		else:
			var result = overlapping[0]
			var previousRobot = result.get_parent().get("Robot")
			if previousRobot != currentRobot:
				result.get_parent().queue_free()
				build_robot(currentRobot, gridmap_position)
			
				Audio.play("sounds/placement-a.ogg, sounds/placement-b.ogg, sounds/placement-c.ogg, sounds/placement-d.ogg", -20)

# Demolish (remove) a structure

func action_demolish():
	if Input.is_action_just_pressed("demolish"):
		var overlapping = selector_collider.get_overlapping_bodies()	
		if overlapping:
			var result = overlapping[0]
			var layer = result.get_collision_layer()
			if layer == 2:
				result.get_parent().queue_free()
			
			Audio.play("sounds/removal-a.ogg, sounds/removal-b.ogg, sounds/removal-c.ogg, sounds/removal-d.ogg", -20)

# Rotates the 'cursor' 90 degrees

func action_rotate():
	if Input.is_action_just_pressed("rotate"):
		selector.rotate_y(deg_to_rad(90))
		
		Audio.play("sounds/rotate.ogg", -30)



# Toggle between structures to build

func action_structure_toggle():
	if Input.is_action_just_pressed("structure_next"):
		index = wrap(index + 1, 0, robots.size())
		Audio.play("sounds/toggle.ogg", -30)
	
	if Input.is_action_just_pressed("structure_previous"):
		index = wrap(index - 1, 0, robots.size())
		Audio.play("sounds/toggle.ogg", -30)

	update_structure()

# Update the structure visual in the 'cursor'

func update_structure(robotIndex = index):
	# Clear previous structure preview in selector
	index = robotIndex
	for n in selector_container.get_children():
		selector_container.remove_child(n)
		
	# Create new structure preview in selector
	var _model = robotInventory.keys()[index].model.instantiate()
	selector_container.add_child(_model)
	_model.position.y += 0.25
	print(index)

# Saving/load


func _on_bot_inventory_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	update_structure(index)
