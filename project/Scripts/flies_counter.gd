extends Node2D

@export var gatheredFlies:String
@export var totFlies:String
@export var gatheredLabel:Label
@export var totLabel:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gatheredLabel.text = gatheredFlies
	totLabel.text = totFlies


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
