extends Node2D

##################################################################
# Variabili
##################################################################

@export var jump_height: float = 200.0
@export var jump_duration: float = 1.0
@export var delay_between_jumps: float = 2.0

var start_position: Vector2
var time_passed: float = 0.0
var jumping: bool = false # Indica se il pesce sta saltando in questo momento

##################################################################
# FUNZIONI
##################################################################

func _ready():
	start_position = position
	start_jump_timer()

# Aspetta un po' e poi fa partire il salto
func start_jump_timer():
	jumping = false 
	time_passed = 0.0
	await get_tree().create_timer(delay_between_jumps).timeout
	jumping = true

# Movimento verticale del pesce
func _process(delta):
	if jumping:
		time_passed += delta
		var t = time_passed / jump_duration

		if t > 1.0:
			position = start_position
			$Sprite2D.rotation_degrees = 0 # Resetta la rotazione quando tocca l'acqua
			start_jump_timer()
		else:
			# Parabola: simula un salto su e giù
			var height = -4 * jump_height * t * (t - 1)
			position.y = start_position.y - height

# Rotazione realistica: da 0° (salita) a 120° (discesa)
			var angle := 0.0
			if t >= 0.5:
				var t_descend = (t - 0.5) * 2 # Normalizza da 0 a 1 la discesa
				angle = lerp(0.0, -120.0, t_descend)
			$Sprite2D.rotation_degrees = angle
			
# Funzione di collisione e riavvio livello
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().reload_current_scene()
