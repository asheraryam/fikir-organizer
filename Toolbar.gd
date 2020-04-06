extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Transparent_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	get_tree().get_root().set_transparent_background(button_pressed) 

var last_pressed_position : Vector2
var pointer_pressed = false
var state = "toolbar_bottom"
func _on_ToolbarPanel_gui_input(event : InputEvent):
	if event.is_action_pressed("pointer"):
		pointer_pressed = true
		last_pressed_position = event.position
	if event.is_action_released("pointer"):
		pointer_pressed = false
	if event is InputEventMouseMotion and pointer_pressed:
		var change = last_pressed_position.y - event.position.y
		if  abs(change)> 50:
			if change > 0:
				if state != "toolbar_top":
					state = "toolbar_top"
					$AnimationPlayer.play(state)
				else:
					last_pressed_position = event.position
					
			else:
				if state != "toolbar_bottom":
					state = "toolbar_bottom"
					$AnimationPlayer.play(state)
				else:
					last_pressed_position = event.position
					
