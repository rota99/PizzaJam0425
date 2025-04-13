extends Node2D

@export var gatheredFlies := 0
@export var totFlies : int = 0
@onready var gatheredLabel : Label = $HBoxContainer/HBoxContainer/Gathered
@onready var totLabel : Label = $HBoxContainer/HBoxContainer/Tot

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	gatheredLabel.text = str(gatheredFlies)
	totLabel.text = str(totFlies)
