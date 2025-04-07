extends CharacterBody2D

## MOVEMENT PARAMETERS =========================================================
@export var SPEED := 300.0
@export var FRICTION := 0.85

## JUMP PARAMETERS =============================================================
@export var MIN_JUMP_FORCE := -300.0
@export var MAX_JUMP_FORCE := -600.0
@export var MAX_JUMP_CHARGE_TIME := 1.0
@export var JUMP_CHARGE_RATE := 2.0
@export var FALL_GRAVITY_MULTIPLIER := 1.5

## ACTION BINDINGS =============================================================
@export var jump_action := "jump"
@export var move_left_action := "move_left"
@export var move_right_action := "move_right"

## STATE VARIABLES =============================================================
var _is_charging_jump := false
var _jump_charge_time := 0.0
var _has_control := true #In caso ci serva

# Node references
@export var _jump_charging_bar : ProgressBar
@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D


func _ready() -> void:
	#Debug per development
	assert(_jump_charging_bar != null, "Errore: my_variable non dovrebbe essere null.")
		
	_jump_charging_bar.max_value = MAX_JUMP_CHARGE_TIME


func _physics_process(delta: float) -> void:
	if not _has_control:
		return
	 
	_apply_gravity(delta)
	_handle_jump_charging(delta)
	_handle_movement_input()
	_update_sprite_direction()
	 
	move_and_slide()


## INPUT HANDLING ==============================================================
func _update_input_actions() -> void:
	 # Implement custom input mapping logic here if needed
	pass


## MOVEMENT LOGIC ==============================================================
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var gravity = get_gravity()
		gravity *= FALL_GRAVITY_MULTIPLIER if velocity.y > 0 else 1.0
		velocity += gravity * delta


func _handle_jump_charging(delta: float) -> void:
	if is_on_floor():
		  # Start charging
		if Input.is_action_just_pressed(jump_action):
			_is_charging_jump = true
			_jump_charge_time = 0.0
		  
		  # Continue charging
		if _is_charging_jump and Input.is_action_pressed(jump_action):
			_jump_charge_time = min(_jump_charge_time + delta * JUMP_CHARGE_RATE, MAX_JUMP_CHARGE_TIME)
		  
		  # Release jump
		if Input.is_action_just_released(jump_action):
			_execute_jump()
			
		_update_charging_jump_bar()
	else:
		_is_charging_jump = false


func _execute_jump() -> void:
	var charge_ratio = _jump_charge_time / MAX_JUMP_CHARGE_TIME
	velocity.y = lerp(MIN_JUMP_FORCE, MAX_JUMP_FORCE, charge_ratio)
	_reset_jump_state()


func _reset_jump_state() -> void:
	_is_charging_jump = false
	_jump_charge_time = 0.0


func _handle_movement_input() -> void:
	var direction = Input.get_axis(move_left_action, move_right_action)
	velocity.x = direction * SPEED if direction else lerp(velocity.x, 0.0, FRICTION)


## VISUAL MANAGEMENT ===========================================================
func _update_sprite_direction() -> void:
	if not _animated_sprite:
		return
	 
	var direction = Input.get_axis(move_left_action, move_right_action)
	if direction != 0:
		_animated_sprite.flip_h = direction > 0

func _update_charging_jump_bar() -> void:
	if not _has_control:
		return
		
	_jump_charging_bar.update_bar(_jump_charge_time)

## PUBLIC API ==================================================================
func set_character_control(enabled: bool) -> void:
	_has_control = enabled
	if not enabled:
		_reset_jump_state()
