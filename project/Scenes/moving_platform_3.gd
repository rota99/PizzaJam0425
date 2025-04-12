extends AnimatableBody2D

var direction = -1
@export var speed = 100.0
@export var down_limit_y := 0
@export var up_limit_y := -200

func _physics_process(delta):
	position.y += direction * speed * delta

	if position.y >= down_limit_y:
		direction = -1
	elif position.y <= up_limit_y:
		direction = 1
