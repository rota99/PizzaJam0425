extends Node2D

## MOVEMENT VARIABLES ==============================================================================
@export var MOVEMENT_SPEED := 30.0
@export var PATH : Curve2D

## INTERNAL VARIABLES =================================================================================
@onready var path_follower := $Path2D/PathFollow2D
@onready var animated_sprite := $Path2D/PathFollow2D/RigidBody2D/AnimatedSprite2D
var has_path : bool

func _ready() -> void:
	$Path2D.curve = PATH
	has_path = PATH != null
	animated_sprite.play("fly_normal")

func _process(delta: float) -> void:
	#Sezione path posiziont update
	if ! has_path: return
	path_follower.progress += delta * MOVEMENT_SPEED
