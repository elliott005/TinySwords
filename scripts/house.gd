extends StaticBody2D

@onready var area_2d = $Area2D
@onready var sprite_2d = $Sprite2D

var type = "structure"

@export var pawns_using: Array[CharacterBody2D] = []
var max_units = 2

var building_stage = 0
var building_stage_finished = 3

func init():
	modulate = Color(1, 1, 1)
	collision_layer = 3

func build():
	sprite_2d.texture = Globals.house_built
