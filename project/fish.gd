extends CharacterBody2D

@export var speed = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	speed.y -= 100
	speed.x += 100
	
	
