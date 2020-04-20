extends GraphEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)

func save():
	return {
		"path": get_path(),
		"use_snap":use_snap,
		"snap_distance":snap_distance,
		"zoom":zoom,
		"data": {
		"offset_x" :scroll_offset.x, 
		"offset_y" :scroll_offset.y, }
	}

func load_more(data):
	
	if "offset_x" in data:
		scroll_offset.x = data["offset_x"]
	if "offset_x" in data:
		scroll_offset.y = data["offset_y"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#func _unhandled_input(event :InputEvent):
#	if event.is_action_pressed("paste"):
#		if Selection.current_selected:
#			pass
#		else:
#			get_parent().create_node_from_paste()
#	if event is InputEventMouseButton and event.is_pressed():
#		if event.button_index == BUTTON_LEFT: 
##			print("Pressed on BG graph")
#			if Selection.current_selected:
#				print("Deselected node")
#				Selection.current_selected.set_node_selected(false)
#				Selection.current_selected = null
