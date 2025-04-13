extends Node2D

## STATE VARIABLES =================================================================================
var num_enemies : int = 0
var kills := 0
var no_initial_enemies := false 
var fliesCounterNode : Node2D = null
var door : Area2D

func _ready() -> void:
	
	assert(has_node("Door") != null, "NO Door trovata in livello! :(")
	
	door = find_child("Door")
	
	assert(has_node("FliesCounter") != null, "NO Flies counter trovato in livello! :(")
	fliesCounterNode = find_child("FliesCounter")
	
	var enemies := get_tree().get_nodes_in_group("enemy")
	num_enemies = enemies.size()
	
	if num_enemies != 0:
		for en in enemies:
			en.connect("enemy_died", _on_enemy_died)
	else:
		no_initial_enemies = true
	
	fliesCounterNode.totFlies = num_enemies

func _process(delta: float) -> void:
	if ! no_initial_enemies and kills >= num_enemies:
		door.open_door()

func _on_enemy_died() -> void:
	kills += 1
	fliesCounterNode.gatheredFlies = kills
