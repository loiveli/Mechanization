extends Node3D

@export var robots: Array[Robot] = []

var map:DataMap

var index:int = 0 # Index of structure being built

@export var selector:Node3D # The 'cursor'
@export var selector_container:Node3D # Node that holds a preview of the structure
@export var view_camera:Camera3D # Used for raycasting mouse


var plane:Plane # Used for raycasting mouse

func _ready():
	
	map = DataMap.new()
	plane = Plane(Vector3.UP, Vector3.ZERO)
	
	# Create new MeshLibrary dynamically, can also be done in the editor
	# See: https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html
	
	var mesh_library = MeshLibrary.new()
	
	for robot in robots:
		
		var id = mesh_library.get_last_unused_item_id()
		
		mesh_library.create_item(id)
		mesh_library.set_item_mesh(id, get_mesh(robot.model))
		mesh_library.set_item_mesh_transform(id, Transform3D())
		
	
	
	update_structure()

func _process(delta):
	
	# Controls
	
	action_rotate() # Rotates selection 90 degrees
	action_structure_toggle() # Toggles between structures
	
	# Map position based on mouse
	
	var world_position = plane.intersects_ray(
		view_camera.project_ray_origin(get_viewport().get_mouse_position()),
		view_camera.project_ray_normal(get_viewport().get_mouse_position()))

	var gridmap_position = Vector3(round(world_position.x), 0, round(world_position.z))
	selector.position = lerp(selector.position, gridmap_position, min(delta * 40, 1.0))
	
	action_build(gridmap_position)
	action_demolish(gridmap_position)

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

func action_build(gridmap_position):
	if Input.is_action_just_pressed("build"):
		
		var camera3d = view_camera
		var space_state = get_world_3d().direct_space_state
		var from = camera3d.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera3d.project_ray_normal(get_viewport().get_mouse_position()) * 100000
		
		var raycast = PhysicsRayQueryParameters3D.create(from,to)
		var result = space_state.intersect_ray(raycast).collider
		
		var currentRobot = robots[index]
		
		if result:
			if currentRobot not in result:
				print(currentRobot)
			
			print(result)
			
			Audio.play("sounds/placement-a.ogg, sounds/placement-b.ogg, sounds/placement-c.ogg, sounds/placement-d.ogg", -20)

# Demolish (remove) a structure

func action_demolish(gridmap_position):
	if Input.is_action_just_pressed("demolish"):
		var camera3d = $Camera3D
		var space_state = get_world_3d().direct_space_state
		var from = camera3d.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera3d.project_ray_normal(get_viewport().get_mouse_position()) * 10
		
		var raycast = PhysicsRayQueryParameters3D.create(from,to)
		var result = space_state.intersect_ray(raycast).collider
		
		if result:
			print(result)
			
			
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

func update_structure():
	# Clear previous structure preview in selector
	for n in selector_container.get_children():
		selector_container.remove_child(n)
		
	# Create new structure preview in selector
	var _model = robots[index].model.instantiate()
	selector_container.add_child(_model)
	_model.position.y += 0.25


# Saving/load
