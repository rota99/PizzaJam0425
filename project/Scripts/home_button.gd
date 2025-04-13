extends Node2D

@export var mainPageScene:PackedScene

func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_packed(mainPageScene)
