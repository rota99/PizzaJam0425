extends Node2D

## MOVEMENT VARIABLES ==============================================================================
@export var MOVEMENT_SPEED := 30.0
@export var PATH : Curve2D

## STATE VARIABLES =================================================================================
@export var VITA := 1 ## DEVE essere interi. Rappresenta le linguate che può subire prima di morire

## COSTANTS =============================================================
const tag_nemici := "lickable" #Tag degli oggetti feribili con la funzione API get_licked()(questo deve averlo per essere feribile)

## SIGNALS =============================================================
signal enemy_died

## INTERNAL VARIABLES =================================================================================
@onready var path_follower := $Path2D/PathFollow2D
@onready var animated_sprite := $Path2D/PathFollow2D/RigidBody2D/AnimatedSprite2D
var has_path : bool
var condammed := false

func _ready() -> void:
	$Path2D.curve = PATH
	has_path = PATH != null
	animated_sprite.play("fly_normal")

func _process(delta: float) -> void:
	
	if (VITA <= 0) and ! condammed:
		_die()
		condammed = true
		
		
	#Sezione path posiziont update
	if ! has_path: return
	path_follower.progress += delta * MOVEMENT_SPEED

func _die() -> void:
	emit_signal("enemy_died")
	animated_sprite.play("fly_dies")
	$DieSound.play()

func _on_animated_sprite_2d_animation_looped() -> void:
	if condammed:
		queue_free()

## PUBLIC API ======================================================================================
# OBBLIGATORIA PER TAG!

func get_licked(damage := 1) -> void:
	if ! (tag_nemici in $Path2D/PathFollow2D/RigidBody2D.get_groups()): return 
	VITA -= damage
