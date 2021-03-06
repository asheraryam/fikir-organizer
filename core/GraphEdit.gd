extends GraphEdit



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




func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)
	get_node(from).show_usable_slots()
	get_node(to).show_usable_slots()


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	get_node(from).show_usable_slots()
	get_node(to).show_usable_slots()
