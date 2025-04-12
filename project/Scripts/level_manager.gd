extends Node2D

## STATE VARIABLES =================================================================================
var num_enemies : int = 0
var kills := 0
var no_initial_enemies := false 

func _ready() -> void:
	var enemies := get_tree().get_nodes_in_group("enemy")
	num_enemies = enemies.size()
	
	if num_enemies != 0:
		for en in enemies:
			en.connect("enemy_died", _on_enemy_died)
	else:
		no_initial_enemies = true

func _process(delta: float) -> void:
	if ! no_initial_enemies and kills >= num_enemies:
		print("bravo")

func _on_enemy_died() -> void:
	kills += 1
