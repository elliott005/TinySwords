extends StaticBody2D

@export var pawns_using: Array[CharacterBody2D] = []
@onready var sprite_2d = $Sprite2D

var max_units = 2


func _process(delta):
	if pawns_using.size() > 0:
		sprite_2d.texture = Globals.mine_active
	else:
		sprite_2d.texture = Globals.mine_inactive
