extends Area2D

@export var next_scene : PackedScene = null
@export var open := false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_entered()

func player_entered() -> void:
	if open and next_scene:
		get_tree().change_scene_to_packed(next_scene)
