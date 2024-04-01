extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var mine_timer = $MineTimer
@onready var tree_chop_timer = $TreeChopTimer
@onready var build_timer = $BuildTimer
@onready var area_2d = $Area2D

var placed = false

var SPEED = 5000.0
var destination = Vector2.ZERO

var activity = false
var location = false
var entered = false

var type = "unit"

func _ready():
	modulate = Color(1, 1, 1, 0.5)
	animated_sprite_2d.play("Idle")
	#navigation_agent_2d.velocity_computed.connect(move)
	
func _physics_process(delta):
	if placed:
		if not navigation_agent_2d.is_navigation_finished():
			#if not navigation_agent_2d.is_target_reachable() and not activity:
				#change_activity(position)
			animated_sprite_2d.play("Walk")
			#var direction = global_position.direction_to(navigation_agent_2d.get_next_path_position()) * delta * SPEED
			#var new_velocity = velocity + (direction - velocity)
			#navigation_agent_2d.velocity = new_velocity
			velocity = global_position.direction_to(navigation_agent_2d.get_next_path_position()) * delta * SPEED
			move_and_slide()
		else:
			if activity:
				if activity == "mine" and mine_timer.time_left <= 0.0:
					mine_timer.start()
				elif activity == "chop" and tree_chop_timer.time_left <= 0.0:
					tree_chop_timer.start()
				elif activity == "build" and build_timer.time_left <= 0.0:
					build_timer.start()
				if not entered:
					entered = true
					if location.pawns_using.size() >= location.max_units:
						stop_activity()
						change_activity(position)
					else:
						if activity == "mine":
							hide()
						elif activity == "chop":
							animated_sprite_2d.play("Break")
						elif activity == "build":
							animated_sprite_2d.play("Build")
						location.pawns_using.append(self)
			else:
				entered = false
				animated_sprite_2d.play("Idle")

#func move(new_velocity):
	#velocity = new_velocity
	#move_and_slide()

func change_activity(dest, act=false, loc=false):
	activity = act
	location = loc
	destination = dest
	navigation_agent_2d.target_position = destination

func stop_activity():
	if location:
		location.pawns_using.erase(self)
	activity = false
	location = false
	mine_timer.stop()
	tree_chop_timer.stop()
	build_timer.stop()
	show()

func init():
	change_activity(position)
	modulate = Color(1, 1, 1)
	area_2d.monitoring = false
	area_2d.monitorable = false
	placed = true


func _on_mine_timer_timeout():
	var resource = Globals.resource_scene.instantiate()
	resource.position = position + Vector2(randi_range(-32, 32), randi_range(-32, 32))
	resource.anim = Globals.gold_frames
	resource.add_to_group("Gold")
	get_parent().add_child(resource)

func _on_tree_chop_timer_timeout():
	var resource = Globals.resource_scene.instantiate()
	resource.position = position + Vector2(randi_range(-32, 32), randi_range(-32, 32))
	resource.anim = Globals.wood_frames
	resource.add_to_group("Wood")
	get_parent().add_child(resource)

func _on_build_timer_timeout():
	location.building_stage += 1
	if location.building_stage >= location.building_stage_finished:
		location.build()
		stop_activity()
