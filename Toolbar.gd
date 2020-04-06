extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



var last_pressed_position : Vector2
var pointer_pressed = false
var state = "toolbar_pos_top"
var allow_move = true
func _on_ToolbarPanel_gui_input(event : InputEvent):
	if event.is_action_pressed("pointer"):
		pointer_pressed = true
		last_pressed_position = event.position
	if event.is_action_released("pointer"):
		pointer_pressed = false
	if event is InputEventMouseMotion and pointer_pressed:
		var change = last_pressed_position.y - event.position.y
		if  abs(change)> 50 and allow_move:
			last_pressed_position = event.position
			if change > 0:
				if state != "toolbar_pos_top":
					state = "toolbar_pos_top"
					rect_position.y = 0
					allow_move = false
					yield(get_tree().create_timer(0.2),"timeout")
					allow_move = true
#					$AnimationPlayer.play(state)
					
			else:
				if state != "toolbar_pos_bottom":
					state = "toolbar_pos_bottom"
					rect_position.y = OS.get_window_size().y - 39
					allow_move = false
					yield(get_tree().create_timer(0.2),"timeout")
					allow_move = true
#					$AnimationPlayer.play(state)
					
