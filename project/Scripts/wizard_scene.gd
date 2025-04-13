extends Node2D

@export var nextLevel:PackedScene

func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_packed(nextLevel)
