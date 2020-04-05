extends Control


onready var graph : GraphEdit = $GraphEdit

var initial_node_position := Vector2(80,80)
var additional_offset := Vector2(80,80)
var node_index = 0 

var graph_node = load("res://GraphNode.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		persist.save_game()
		print ("You are quit!")
		get_tree().quit() # default behavior

		
var last_offset = Vector2(0,0)
func _input(event : InputEvent):
#	if event.is_action_released("ui_select"):
#		print(OS.clipboard)
	
	
	if event.is_action_pressed("node_add_wrapper"):
		var new_node : GraphNode = graph_node.instance()
		
		new_node.offset += initial_node_position + (
	#			Vector2(int(node_index/5) * additional_offset.x, 
			Vector2(node_index * additional_offset.x, 
				(node_index % 5) * additional_offset.y))
		
		$GraphEdit.add_child(new_node)
		
		new_node._on_Node_raise_request()
		new_node.set_selected(true)
		
		new_node.init_state()
		
		if event.is_action_pressed("paste_from_clipboard"):
			var image_file_path = ClipBoardUtils.get_image()
			if image_file_path:
				print("Clipboard saved to: " + str(image_file_path))
				new_node.set_image_from_local(image_file_path)
			else:
				new_node.set_link_tools_visible(false)
				var clip_text = ClipBoardUtils.get_text()
				new_node.set_text_from_clipboard(clip_text)
		elif event.is_action_pressed("paste_image_url"):
			var clip_text = ClipBoardUtils.get_text()
#			new_node.get_image(OS.clipboard)
			if clip_text:
				new_node.get_image(clip_text)
		elif event.is_action_pressed("paste_url_with_snapshot"):
			var clip_text = ClipBoardUtils.get_text()
			if clip_text:
				new_node.get_snapshot(clip_text)
		else:
			new_node.set_link_tools_visible(false)
			
		new_node.force_selected()
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


func _on_GraphEdit_gui_input(event :InputEvent):
	if event.is_action_pressed("paste"):
		if is_instance_valid(Selection.current_selected) and Selection.current_selected:
			add_paste_to_selected()
		else:
			create_node_from_paste()
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_RIGHT: 
#			print("Pressed on BG graph")
			if Selection.current_selected:
				print("Deselected node")
				Selection.current_selected.set_node_selected(false)
				Selection.current_selected = null
#		if event.button_index == BUTTON_LEFT: 
##			print("Pressed on BG graph")
#			if Selection.current_selected:
#				print("Deselected node")
#				Selection.current_selected.set_node_selected(false)
#				Selection.current_selected = null

func add_paste_to_selected():
	if not is_instance_valid(Selection.current_selected) or not Selection.current_selected:
		return
		
	# WARNING: This mostly overwrites things
	var image_file_path = ClipBoardUtils.get_image()
	if image_file_path:
		print("Clipboard saved to: " + str(image_file_path))
		Selection.current_selected.set_image_from_local(image_file_path)
		Selection.current_selected.set_link_tools_visible(false)
	else:
		var clip_text = ClipBoardUtils.get_text()
		if clip_text:
			if clip_text.find("http") != -1:
				Selection.current_selected.text_edit.text = clip_text
				Selection.current_selected.text_edit.readonly = true
				Selection.current_selected.get_image(clip_text)
			else:
				# paste text if node is empty, or ask insert at cursor
				pass
#				Selection.current_selected.set_text_from_clipboard(clip_text)
#				Selection.current_selected.set_link_tools_visible(false)
	
func create_node_from_paste():
	print("Create node from paste")
	var new_node : GraphNode = graph_node.instance()
		
	new_node.offset += initial_node_position + (
#			Vector2(int(node_index/5) * additional_offset.x, 
		Vector2(node_index * additional_offset.x, 
			(node_index % 5) * additional_offset.y))
	
	$GraphEdit.add_child(new_node)
	
	new_node._on_Node_raise_request()
	new_node.set_selected(true)
	
	new_node.set_node_empty()
	new_node.set_link_tools_visible(true)
	var image_file_path = ClipBoardUtils.get_image()
	if image_file_path:
		print("Clipboard saved to: " + str(image_file_path))
		new_node.set_image_from_local(image_file_path)
		new_node.set_link_tools_visible(false)
	else:
		var clip_text = ClipBoardUtils.get_text()
		if clip_text:
			if clip_text.find("http") != -1:
				new_node.text_edit.text = clip_text
				new_node.text_edit.readonly = true
				new_node.get_image(clip_text)
			else:
				new_node.set_text_from_clipboard(clip_text)
				new_node.set_link_tools_visible(false)

	new_node.force_selected()
	node_index +=1
