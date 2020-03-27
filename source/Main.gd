extends Control


onready var graph : GraphEdit = $GraphEdit

var initial_node_position := Vector2(80,80)
var additional_offset := Vector2(80,80)
var node_index = 0 

var graph_node = load("res://GraphNode.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var last_offset = Vector2(0,0)
func _input(event : InputEvent):
	if event.is_action_pressed("add_node"):
		var new_node = graph_node.instance()
		
		new_node.offset += initial_node_position + (
#			Vector2(int(node_index/5) * additional_offset.x, 
			Vector2(node_index * additional_offset.x, 
			(node_index % 5) * additional_offset.y))
		
		$GraphEdit.add_child(new_node)
		
		node_index +=1
	
	if event.is_pressed():
		if event is InputEventKey:
			if event.scancode == KEY_CONTROL and not event.is_echo():
				last_offset = $GraphEdit.scroll_offset
		
		if event is InputEventMouseButton:
			if Input.is_key_pressed(KEY_CONTROL):
				if event.button_index == BUTTON_WHEEL_UP:
			#			zoom_pos = get_global_mouse_position()
					$GraphEdit.zoom +=0.1
				if event.button_index == BUTTON_WHEEL_DOWN:
			#			zoom_pos = get_global_mouse_position()
					$GraphEdit.zoom -=0.1


#func _process(delta):
#	if Input.is_key_pressed(KEY_CONTROL):
#		$GraphEdit.scroll_offset = last_offset

func _on_GraphEdit_scroll_offset_changed(ofs):
#	pass
	if Input.is_key_pressed(KEY_CONTROL):
		$GraphEdit.scroll_offset = last_offset
		yield(get_tree(),"idle_frame")
		$GraphEdit.scroll_offset = last_offset
