extends AnimatableBody2D

var direction = -1
@export var speed = 100.0
@export var left_limit_x := -300
@export var right_limit_x := -175

func _physics_process(delta):
	position.x += direction * speed * delta

	if position.x <= left_limit_x:
		direction = 1
	elif position.x >= right_limit_x:
		direction = -1
