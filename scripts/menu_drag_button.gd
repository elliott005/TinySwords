extends Button

@export var frames: SpriteFrames
@export var label_text: String
@export var y_offset = 0.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var label = $Label

var x_offset = -40

func _ready():
	label.text = label_text
	animated_sprite_2d.sprite_frames = frames
	animated_sprite_2d.play("default")
	animated_sprite_2d.position.y += y_offset
