extends Area2D

@export var next_scene : PackedScene = null
var _open := false
@export var opened_texture : Texture2D

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_entered()

func _player_entered() -> void:
	if _open and next_scene:
		get_tree().change_scene_to_packed(next_scene)

func open_door() -> void:
	assert(opened_texture != null, "Manca la texture di porta aperta!")
	$Sprite2D.texture = opened_texture
	_open = true
