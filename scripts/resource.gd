extends Area2D

@export var anim: SpriteFrames

@onready var animated_sprite_2d = $AnimatedSprite2D


func _ready():
	animated_sprite_2d.sprite_frames = anim
	animated_sprite_2d.play("Spawn")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Spawn":
		animated_sprite_2d.play("Idle")
