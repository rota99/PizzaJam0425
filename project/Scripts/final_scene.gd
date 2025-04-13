extends Control

@export var mainScene:PackedScene

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(mainScene)
