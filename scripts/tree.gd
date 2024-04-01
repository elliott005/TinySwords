extends StaticBody2D

@export var pawns_using: Array[CharacterBody2D] = []
@onready var animated_sprite_2d = $AnimatedSprite2D

var max_units = 1

func _ready():
	animated_sprite_2d.play("default")
