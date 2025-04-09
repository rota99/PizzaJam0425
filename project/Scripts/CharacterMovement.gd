extends CharacterBody2D

## MOVEMENT PARAMETERS =========================================================
@export var SPEED := 300.0
@export var FRICTION := 0.85

## JUMP PARAMETERS =============================================================
@export var MIN_JUMP_FORCE := -300.0
@export var MAX_JUMP_FORCE := -600.0
@export var MAX_JUMP_CHARGE_TIME := 2.0
@export var JUMP_CHARGE_RATE := 2.0
@export var FALL_GRAVITY_MULTIPLIER := 1.5
@export var STOPPED_THRESHOLD := 3.0  # Soglia per considerare "quasi fermo"

## TONGUE PARAMETERS =============================================================
@export var TONGUE_EXTEND_SPEED := 300.0  # Velocità di estensione
@export var TONGUE_RETRACT_SPEED := 300.0 # Velocità di ritiro
@export var TONGUE_WIDTH := 60.0           # Spessore visuale
@export var MIN_TONGUE_WIDTH := 15.0           # Spessore visuale
@export var MAX_TONGUE_LENGTH := 800.0    # Lunghezza massima
@export var TAG_TONGUABLE_TARGETS := "linguabili"  # Oggetti con questo tag possono essere agganciati dalla lingua

## TONGUE FISICA PARAMETERS =============================================================
@export var SWING_FORCE := 800.0          # Forza di oscillazione
@export var SWING_PULL_FORCE := 46.0    # Forza di richiamo elastico
@export var SWING_TANGENT_FORCE := 48.0  # Forza perpendicolare per oscillazione

#TEST
@export var JOINT_SOFTNESS := 0.1
@export var JOINT_BIAS := 0.5
@export var MAX_SWING_VELOCITY := 450.0

## ACTION BINDINGS =============================================================
@export var jump_action := "jump"
@export var move_left_action := "move_left"
@export var move_right_action := "move_right"
@export var tongue_action := "tongue"

## STATE VARIABLES =============================================================
var _is_charging_jump := false
var _jump_charge_time := 0.0
var _has_control := true #In caso ci serva

var _tongue_hit_point := Vector2.ZERO
enum TongueState {RETRACTED, EXTENDING, ATTACHED, RETRACTING}
var _tongue_state := TongueState.RETRACTED
var _current_tongue_length := 0.0
var _tongue_hit_target: Node2D = null  # Per agganciarsi a oggetti dinamici

# Node references
@export var _jump_charging_bar : ProgressBar
@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D


func _ready() -> void:
	#Debug per development
	assert(_jump_charging_bar != null, "Errore: _jump_charging_bar non dovrebbe essere null.")
		
	_jump_charging_bar.max_value = MAX_JUMP_CHARGE_TIME
	$Tongue.add_point(Vector2.ZERO, 0)
	$Tongue.add_point(Vector2.ZERO, 1)


func _physics_process(delta: float) -> void:
	if not _has_control:
		return
	 
	_apply_gravity(delta)
	_handle_jump_charging(delta)
	_handle_movement_input()
	_update_sprite_direction()
	
	_handle_toungue_shooting()
	_handle_tongue_physics(delta)
	
	
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
			# When moving (whitin threshhold) can't charge jump
			if abs(velocity.x) < STOPPED_THRESHOLD:
				_jump_charging_bar.show()
				_jump_charge_time = min(_jump_charge_time + delta * JUMP_CHARGE_RATE, MAX_JUMP_CHARGE_TIME)
		  
		  # Release jump
		if Input.is_action_just_released(jump_action):
			_jump_charging_bar.hide()
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
	#if _tongue_state == TongueState.ATTACHED:  return # Disabilita movimento normale quando penzola
		
	var direction = Input.get_axis(move_left_action, move_right_action)
	velocity.x = direction * SPEED if direction else lerp(velocity.x, 0.0, FRICTION)

## TONGUE MANAGEMENT ===========================================================

func _handle_toungue_shooting():
	if Input.is_action_just_pressed(tongue_action):
		if _tongue_state != TongueState.RETRACTED: return
		_shoot_tongue()
		_show_tongue()
	
	if Input.is_action_just_released(tongue_action):
		_tongue_state = TongueState.RETRACTING

func _shoot_tongue():
	
	_tongue_state = TongueState.EXTENDING
	$RayCast2D.target_position = global_position.direction_to(get_global_mouse_position()) * (MAX_TONGUE_LENGTH + 1.0)
	#print($RayCast2D.target_position) #TODO togli - DEBUG
	$RayCast2D.force_raycast_update()
	
	if $RayCast2D.is_colliding():
		var collision_point = $RayCast2D.get_collision_point()
		if global_position.distance_to(collision_point) <= MAX_TONGUE_LENGTH:
			_tongue_hit_target = $RayCast2D.get_collider()
			#var test =_tongue_hit_target.name #TODO togli - DEBUG
			_tongue_hit_point = collision_point
		else:
			_tongue_hit_point = global_position + global_position.direction_to(collision_point) * MAX_TONGUE_LENGTH
		
	else:
		_tongue_hit_point = get_global_mouse_position()
	
	# Animazione iniziale
	$TongueTip.position = Vector2.ZERO
	$Tongue.width = TONGUE_WIDTH

func _handle_tongue_physics(delta):
	match _tongue_state:
		TongueState.EXTENDING:
			# 2.0 è treshold per distanza di contatto tra lingua e oggetto (non puoi metterla a 0.0)
			if  abs($TongueTip.position.distance_to(to_local(_tongue_hit_point))) < 2.0 and _tongue_hit_target != null:
				#Se oggetto non è afferrabile dalla lingua, essa torna indietro
				if _tongue_hit_target.is_in_group(TAG_TONGUABLE_TARGETS):
					_tongue_state = TongueState.ATTACHED
				else:
					_tongue_state = TongueState.RETRACTING
			
			if _current_tongue_length >=  MAX_TONGUE_LENGTH:
				_tongue_state = TongueState.RETRACTING
			else:
				_current_tongue_length += TONGUE_EXTEND_SPEED * delta
		
		TongueState.ATTACHED:
			_apply_swing_physics(delta)
			#_current_tongue_length = (_tongue_hit_point - global_position).length()
		
		TongueState.RETRACTING:
			_current_tongue_length -= TONGUE_RETRACT_SPEED * delta
			if _current_tongue_length <= 0:
				_tongue_state = TongueState.RETRACTED
				_cleanup_tongue()
	
	_update_tongue_visual()
	
#Test TODO DEBUG
func _setup_swing_joint():
	if has_node("TongueJoint"):
		get_node("TongueJoint").queue_free()
	 
	var joint = PinJoint2D.new()
	joint.name = "TongueJoint"
	joint.position = to_local(_tongue_hit_point)
	 
	 # Configura la rigidità del joint
	joint.softness = 0.1
	joint.bias = 0.5
	 
	add_child(joint)
	 
	 # Se l'oggetto è dinamico, connetti il joint
	if _tongue_hit_target is RigidBody2D:
		joint.node_b = _tongue_hit_target.get_path()

func _apply_swing_physics(delta: float) -> void:
	if _tongue_state != TongueState.ATTACHED: return

	# Aggiorna il punto di aggancio se il target è dinamico
	if _tongue_hit_target is Node2D:
		_tongue_hit_point = _tongue_hit_target.global_position + (_tongue_hit_point - _tongue_hit_target.global_position)

	var to_target = _tongue_hit_point - global_position
	var distance = to_target.length()
	var direction = to_target.normalized()

	# Foza elastica per mantenere la lunghezza
	if distance > _current_tongue_length:
		var pull_force = direction * (distance - _current_tongue_length) * SWING_PULL_FORCE
		velocity += pull_force * delta


func _cleanup_tongue():
	if has_node("TongueJoint"):
		get_node("TongueJoint").queue_free()
	
	_tongue_state = TongueState.RETRACTED
	_current_tongue_length = 0.0
	_tongue_hit_target = null
	_tongue_hit_point = Vector2.ZERO
	
	# Resetta la visualizzazione
	$Tongue.set_point_position(1, Vector2.ZERO)
	$Tongue.hide()
	$TongueTip.position = Vector2.ZERO

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

func _show_tongue():
	$Tongue.show()

#TODO bug visivo щ(ಠ益ಠщ)
func _update_tongue_visual():
	if _tongue_state == TongueState.RETRACTED: return
	
	match _tongue_state:
		TongueState.EXTENDING:
			var end_pos = global_position.direction_to(_tongue_hit_point) * _current_tongue_length
			$Tongue.set_point_position(0, Vector2.ZERO)
			$Tongue.set_point_position(1, end_pos)
			$TongueTip.position = end_pos
		
		TongueState.RETRACTING:
			$Tongue.set_point_position(0, Vector2.ZERO)
			var retract_pos = global_position.direction_to(_tongue_hit_point) * _current_tongue_length
			$Tongue.set_point_position(1, retract_pos)
			$TongueTip.position = $TongueTip.position.lerp(retract_pos, 0.2)
			$TongueTip.position = retract_pos
		
		TongueState.ATTACHED:
			$Tongue.set_point_position(1, to_local(_tongue_hit_point))
			$TongueTip.position = to_local(_tongue_hit_point)
	
	$Tongue.width = lerp(TONGUE_WIDTH, MIN_TONGUE_WIDTH, _current_tongue_length/MAX_TONGUE_LENGTH)

## PUBLIC API ==================================================================
func set_character_control(enabled: bool) -> void:
	_has_control = enabled
	if not enabled:
		_reset_jump_state()
