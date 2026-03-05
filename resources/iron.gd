extends Resource
class_name Item

@export var id: String = "iron"         # Machine-readable name
@export var label: String = "Iron"      # Display name
@export var color: Color = Color(0.6, 0.6, 0.65)  # Used to tint the mesh
@export var icon: Texture2D             # Optional: UI icon
