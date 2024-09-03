extends CanvasLayer

@onready var selection_visual = $Selection
var selected_item : int = 0
@onready var menu = $UI/MarginContainer/PanelContainer/MarginContainer/HBoxContainer

func _ready():
	get_viewport().connect("size_changed", _on_viewport_resized)

func change_selection(selection : int) -> void:
	selected_item = selection
	selection_visual.global_position = menu.get_child(selection).global_position

func _on_viewport_resized():
	selection_visual.global_position = menu.get_child(selected_item).global_position
	await get_tree().create_timer(0.1).timeout
