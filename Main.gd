extends Control


onready var graph : GraphEdit = $GraphEdit

var initial_node_position := Vector2(80,80)
var additional_offset := Vector2(80,80)
var node_index = 0 

var graph_node = load("res://GraphNode.tscn")
onready var clipboard = $Clipboard

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().set_transparent_background(true) 
	Selection.clipboard = $Clipboard

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		persist.save_game()
		print ("You are quit!")
		get_tree().quit() # default behavior

		
var last_offset = Vector2(0,0)
func _input(event : InputEvent):
	
	if event.is_action_pressed("node_add_wrapper"):
		var new_node : GraphNode = graph_node.instance()
		
		new_node.offset += get_sequential_offset()
		
		$GraphEdit.add_child(new_node)
		
		new_node._on_Node_raise_request()
		new_node.set_selected(true)
		
		new_node.init_state()
		
		if event.is_action_pressed("paste_from_clipboard"):
			var image_file_path = clipboard.get_image()
			if image_file_path:
				print("Clipboard saved to: " + str(image_file_path))
				new_node.set_image_from_local(image_file_path)
			else:
				new_node.set_link_tools_visible(false)
				var clip_text = clipboard.get_text()
				new_node.set_text_from_clipboard(clip_text)
		elif event.is_action_pressed("paste_image_url"):
			var clip_text = clipboard.get_text()
#			new_node.get_image(OS.clipboard)
			if clip_text:
				new_node.get_image(clip_text)
		elif event.is_action_pressed("paste_url_with_snapshot"):
			var clip_text = clipboard.get_text()
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
				if event.button_index == BUTTON_MIDDLE:
					$GraphEdit.zoom = 1


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
			Selection.current_selected.add_paste_to_selected()
		else:
			create_node_from_paste()
	
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_RIGHT:
			print("right click add node")
			add_basic_node(event.position + $GraphEdit.scroll_offset)

func get_sequential_offset():
	return $GraphEdit.scroll_offset + initial_node_position + (
#			Vector2(int(node_index/5) * additional_offset.x, 
		Vector2(node_index * additional_offset.x, 
			(node_index % 5) * additional_offset.y))
	
func create_node_from_paste():
	print("Create node from paste")
	var new_node : GraphNode = graph_node.instance()
		
	new_node.offset += get_sequential_offset()
	
	$GraphEdit.add_child(new_node)
	
	new_node._on_Node_raise_request()
	new_node.set_selected(true)
	
	new_node.set_node_empty()
	new_node.set_link_tools_visible(true)
	var image_file_path = clipboard.get_image()
	if image_file_path:
		print("Clipboard saved to: " + str(image_file_path))
		new_node.set_image_from_local(image_file_path)
		new_node.set_link_tools_visible(false)
	else:
		var clip_text = clipboard.get_text()
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


func _on_Transparent_toggled(button_pressed):
	$Background.visible = not button_pressed
#	ProjectSettings.set_setting("display/window/size/always_on_top", button_pressed)
#	ProjectSettings.save()


func _on_AddBasic_pressed():
	add_basic_node()

func add_basic_node(p_offset = Vector2()):
	var new_node : GraphNode = graph_node.instance()
	var new_offset = p_offset
	if not p_offset:
		new_offset = get_sequential_offset()
		node_index +=1
		
	new_node.offset += new_offset
	
	$GraphEdit.add_child(new_node)
	
	new_node._on_Node_raise_request()
	new_node.set_selected(true)
	
	new_node.init_state()
	
	new_node.set_link_tools_visible(false)
		
	new_node.force_selected()



func _on_GraphEdit_node_selected(node):
	pass # Replace with function body.


func _on_GraphEdit_node_unselected(node):
	if is_instance_valid(Selection.current_selected) and Selection.current_selected and node == Selection.current_selected:
		print("Deselected node")
		Selection.current_selected.set_node_selected(false)
		Selection.current_selected = null


func _on_Quit_pressed():
	persist.save_game()
	get_tree().quit()
