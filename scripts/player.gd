extends Node2D

@onready var units = $Units
@onready var mouse_radius = $MouseRadius
@onready var mouse_radius_timer = $MouseRadiusTimer
@onready var menu_top_left = $MenuTopLeft
@onready var menu_bottom_right = $MenuBottomRight
@onready var camera_2d = $Camera2D
@onready var gold_label = %GoldLabel
@onready var wood_label = %WoodLabel
@onready var navigation_region_2d = $".."

var menuRect: Rect2

var zoom_speed = 0.2
var min_zoom = 0.1
var max_zoom = 2
var mouse_sensitivity = 0.02
var velocity = Vector2.ZERO

var dragging = false
var dragging_unit
var pressed_select_once = false
var double_clicked = false

var changing_unit_activity = false
var selected_unit

var pawn = preload("res://scenes/actors/pawn.tscn")
var house = preload("res://scenes/actors/house.tscn")

var resources = {
	"gold": 0,
	"wood": 0
}

func _ready():
	menuRect = Rect2(menu_top_left.position, menu_bottom_right.position - menu_top_left.position)
	mouse_radius.monitoring = false

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	handle_click()
	handle_drag()
	
	handle_zoom()
	
	position += velocity / camera_2d.zoom
	velocity = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("move"):
			velocity = -event.relative

func handle_drag():
	if dragging:
		dragging_unit.position = get_global_mouse_position()
		if dragging_unit.area_2d.has_overlapping_bodies():
			dragging_unit.modulate = Color(1, 0.5, 0.5, 0.5)
		else:
			dragging_unit.modulate = Color(1, 1, 1, 0.5)
			if Input.is_action_just_pressed("select"):
				if pressed_select_once:
					pressed_select_once = false
					dragging = false
					if menuRect.has_point(get_local_mouse_position() + get_viewport().get_visible_rect().size / 2):
						#units.remove_child(dragging_unit)
						dragging_unit.queue_free()
					else:
						dragging_unit.init()
						if dragging_unit.type == "structure":
							navigation_region_2d.bake_navigation_polygon()
			else:
				pressed_select_once = true

func handle_click():
	if mouse_radius_timer.time_left > 0.0:
		if Input.is_action_just_pressed("select"):
			double_clicked = true
	else:
		double_clicked = false
	if Input.is_action_just_pressed("select") and not dragging:
		var mouse_pos = get_local_mouse_position()
		#print(menuRect, to_local(mouse_pos) + get_viewport().get_visible_rect().size / 2)
		if not menuRect.has_point(mouse_pos + get_viewport().get_visible_rect().size / 2):
			mouse_radius_start()

func handle_zoom():
	if Input.is_action_just_pressed("zoom_in"):
		camera_2d.zoom.x = move_toward(camera_2d.zoom.x, max_zoom, zoom_speed * max((sign(camera_2d.zoom.x) - camera_2d.zoom.x), 0.1))
		camera_2d.zoom.y = move_toward(camera_2d.zoom.y, max_zoom, zoom_speed * max((sign(camera_2d.zoom.y) - camera_2d.zoom.y), 0.1))
	elif Input.is_action_just_pressed("zoom_out"):
		camera_2d.zoom.x = move_toward(camera_2d.zoom.x, min_zoom, zoom_speed * max((sign(camera_2d.zoom.x) - camera_2d.zoom.x), 0.1))
		camera_2d.zoom.y = move_toward(camera_2d.zoom.y, min_zoom, zoom_speed * max((sign(camera_2d.zoom.y) - camera_2d.zoom.y), 0.1))

func mouse_radius_start():
	var mouse_pos = get_global_mouse_position()
	mouse_radius.global_position = mouse_pos
	mouse_radius.monitoring = true
	mouse_radius_timer.start()

func _on_pawn_button_button_down():
	if not dragging:
		var instance = pawn.instantiate()
		instance.position = get_global_mouse_position()
		dragging_unit = instance
		units.add_child(instance)
		dragging = true

func _on_house_button_button_down():
	if not dragging:
		var instance = house.instantiate()
		instance.position = get_global_mouse_position()
		dragging_unit = instance
		units.add_child(instance)
		dragging = true

func _on_mouse_radius_timer_timeout():
	if not changing_unit_activity:
		var stop = false
		var areas = mouse_radius.get_overlapping_areas()
		for area in areas:
			if area.is_in_group("Gold"):
				resources["gold"] += 1
				gold_label.text = ": " + str(resources["gold"])
				area.queue_free()
				stop = true
				break
			elif area.is_in_group("Wood"):
				resources["wood"] += 1
				wood_label.text = ": " + str(resources["wood"])
				area.queue_free()
				stop = true
				break
			elif area.is_in_group("Mines") or area.is_in_group("Trees") or area.is_in_group("Buildings"):
				if double_clicked:
					for unit in area.get_parent().pawns_using:
						unit.stop_activity()
					stop = true
					break
		if not stop:
			var bodies = mouse_radius.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group("Units"):
					selected_unit = body
					changing_unit_activity = true
					selected_unit.modulate = Color(1, 0.5, 0.5)
					break
	else:
		var mouse_pos = get_global_mouse_position()
		var areas = mouse_radius.get_overlapping_areas()
		changing_unit_activity = false
		selected_unit.modulate = Color(1, 1, 1)
		var activity = false
		for area in areas:
			if area.is_in_group("Mines"):
				var parent = area.get_parent()
				if parent.pawns_using.size() < parent.max_units:
					activity = true
					selected_unit.change_activity(mouse_pos, "mine", parent)
			elif area.is_in_group("Trees"):
				var parent = area.get_parent()
				if parent.pawns_using.size() < parent.max_units:
					activity = true
					selected_unit.change_activity(mouse_pos, "chop", parent)
			elif area.is_in_group("Buildings"):
				var parent = area.get_parent()
				if parent.pawns_using.size() < parent.max_units:
					activity = true
					selected_unit.change_activity(mouse_pos, "build", parent)
		if not activity:
			selected_unit.change_activity(mouse_pos)
	mouse_radius.monitoring = false
