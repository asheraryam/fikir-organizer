extends GraphNode

const ENABLE_TOOLS = false


export (Vector2) var MIN_TEX_SIZE := Vector2(160, 160)


onready var text_edit = $HBoxContainer/ImageSettings/TextEdit
onready var lock_btn = $HBoxContainer/ImageSettings/LockButton
onready var url_label = $HBoxContainer/ImageSettings/URL_Label
onready var body_textedit = $CaptionContainer/BodyContainer/BodyText
onready var rich_text = $CaptionContainer/RichTextContainer/RichText

onready var texture_rect: TextureButton = get_node("ImageContainer/TextureRect")


func _ready():
	set_image_loader()
	if not texture_rect:
		texture_rect = load("res://ImageTextureRect.tscn").instance()

	
	set_rich_text_visible(true)
	texture_rect.connect("pressed", self, "_on_TextureRect_pressed")

var image_loader
func set_image_loader():
	if has_node("ImageLoader"):
		image_loader = get_node("ImageLoader")
	else:
		image_loader = load("core/ImageLoader.tscn").instance()
		image_loader.name = "ImageLoader"
		add_child(image_loader)
	

func _on_Node_resize_request(new_minsize):
	if texture_rect.rect_min_size.x > 0:
		var new_tex_size = texture_rect.rect_min_size + (new_minsize - rect_size)
		texture_rect.rect_min_size = Vector2(
			max(MIN_TEX_SIZE.x, new_tex_size.x), max(MIN_TEX_SIZE.y, new_tex_size.y)
		)
	rect_size = new_minsize


func _on_Node_dragged(from, to):
	get_node('../').lastNodePosition = to


func _on_Node_resized():
	pass


#	get_node("Lines").rect_min_size.y = self.get_rect().size.y - 45


func _on_Node_text_changed():
	pass
#	update_rich_label_from_textbox()


func _on_Node_line_changed(text):
	var length = text.length()


func get_text(name):
	if self.has_node('Lines'):
		return self.get_node('Lines').get_child(0).get_text()
	else:
		return ''


func _on_Node_raise_request():
	if is_instance_valid(Selection.current_selected) and Selection.current_selected and Selection.current_selected != self:
		if Selection.current_selected.has_method("set_node_selected"):
			Selection.current_selected.set_node_selected(false)

	set_node_selected(true)
	Selection.current_selected = self


func set_node_selected(is_selected):
	if is_selected:
		title = ">> SELECTED"
		raise()
		set_rich_text_visible(false)
	else:
		title = ""
		set_selected(false)
		set_rich_text_visible(true)


func set_rich_text_visible(is_visible):
	if is_visible:
		body_textedit.get_parent().visible = false
		rich_text.get_parent().visible = true
	else:
		update_rich_label_from_textbox()
		body_textedit.get_parent().visible = true
		rich_text.get_parent().visible = false
		yield(get_tree().create_timer(1), "timeout")
		call_deferred("update_rich_label_from_textbox")


func update_rich_label_from_textbox():
	rich_text.bbcode_text = body_textedit.text
#	print("Update RTL with %s" % rich_text.bbcode_text)
#	body_textedit.rect_size = rich_text.rect_size
#	rich_text.rect_min_size = body_textedit.rect_size
#	print("Rich text updated %s" % rich_text.bbcode_text)


#	rich_text.rect_min_size.x = body_textedit.rect_size.x
#	rich_text.rect_min_size.y = body_textedit.rect_size.y *1.5


func _on_TextEdit_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT and text_edit.readonly:
			var url = text_edit.text.trim_suffix("\n")
			if url and url.find("http") != -1:
				OS.shell_open(url)
			print("Open link in browser")
	if event.is_action_released("ui_accept"):
		call_deferred("check_for_image")




func _on_TextEdit_text_changed():
	pass


#	call_deferred("check_for_image")


func set_node_empty():
	$ImageContainer/TextureRect.texture_normal = null
	#	$ImageContainer.remove_child(texture_rect)
	$ImageContainer.hide()

	texture_rect.rect_min_size = Vector2(0, 0)
	rect_size = rect_min_size

func set_link_tools_visible(is_visible):
	if ENABLE_TOOLS and is_visible:
		$HBoxContainer/ImageSettings.visible = true
		url_label.visible = false
		lock_btn.visible = true
	else:
		$HBoxContainer/ImageSettings.visible = false
		lock_btn.visible = false
		url_label.visible = true


func set_node_has_image():
	url_label.visible = false
	#		$ImageContainer.add_child(texture_rect)
	$ImageContainer.visible = true
	texture_rect.rect_min_size = Vector2(160, 160)

	if texture_rect.expand:
		rect_size = rect_min_size


func force_selected():
	#	selected= true
	body_textedit.grab_focus()


func _on_Scale_Size_Button_toggled(button_pressed):
	if button_pressed:
		texture_rect.expand = false
	else:
		texture_rect.expand = true
		rect_size = rect_min_size


func _on_TextureRect_pressed():
	if texture_rect.expand:
		set_texture_rect_expand(false)
	else:
		set_texture_rect_expand(true)

func set_texture_rect_expand(expand):
	if expand:
		texture_rect.expand = true
		rect_size = rect_min_size
	else:
		if texture_rect.texture_normal:
			texture_rect.expand = false

func _on_LockButton_toggled(button_pressed):
	text_edit.readonly = button_pressed

func set_text_from_clipboard(clip_text: String):
	print("Set text edit from clipboard" + clip_text)
	body_textedit.text = clip_text
	body_textedit._on_ExpandingText_text_changed()


func get_text_in_box():
	return text_edit.text

func image_show_success(texture, path):
	image_loader.image_path = path

	text_edit.text = path
	texture_rect.texture_normal = texture
	set_link_tools_visible(true)
	lock_btn.pressed = true
	text_edit.readonly = true

	if texture:
		set_node_has_image()
	else:
		set_node_empty()


func _on_Node_close_request():
	queue_free()
	print('removing node')

func init_state():
	set_node_empty()
	set_link_tools_visible(true)

func save():
	return {
		"filename": get_filename(),
		"parent": get_parent().get_path(),

		"data": {"text_body": body_textedit.text,
			"offset_x" :offset.x, 
			"offset_y" :offset.y,
			"image_path": image_loader.image_path,
			"is_image_local": image_loader.is_image_local,
			"local_img_cache": image_loader.local_img_cache,
			"texture_size": var2str(texture_rect.rect_min_size),
			"texture_expand": var2str(texture_rect.expand),
			"str2var":{
					"rect_size": var2str(rect_size),
					"rect_min_size": var2str(rect_min_size),
					"rect_position": var2str(rect_position),
				}
		 }
	}


func load_more(data):
	
	if "image_path" in data:
		image_loader.image_path = data["image_path"]
	if "is_image_local" in data:
		image_loader.is_image_local = data["is_image_local"]
	if "local_img_cache" in data:
		image_loader.local_img_cache = data["local_img_cache"]
			
	init_state()
	
	set_link_tools_visible(false)
	
	if "offset_x" in data:
		offset.x = data["offset_x"]
	if "offset_x" in data:
		offset.y = data["offset_y"]

	image_loader.load_image_from_persistance()
				
	if "str2var" in data:
		for i in data["str2var"].keys():
			set(i, str2var(data["str2var"][i]))
	
	if "text_body" in data:
		body_textedit.text = data["text_body"]
		body_textedit._on_ExpandingText_text_changed()
		
		update_rich_label_from_textbox()
	
#	_on_Node_resize_request(rect_min_size)
	if image_loader.image_path:
		if "texture_expand" in data:
			set_texture_rect_expand(str2var(data["texture_expand"]))
		if "texture_size" in data:
			var tmp_size = str2var(data["texture_size"])
			if tmp_size is Vector2:
				texture_rect.rect_min_size = tmp_size
				
	


func _on_RichText_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			print("Pressed on RTL")
			set_selected(true)
			_on_Node_raise_request()
			body_textedit.grab_focus()


func _on_CaptionContainer_mouse_entered():
	return


func _on_CaptionContainer_mouse_exited():
	return


func _on_BodyText_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			print("Pressed on Body text")
			set_selected(true)
			_on_Node_raise_request()
			body_textedit.grab_focus()
	if event.is_action_pressed("paste"):
		if is_instance_valid(Selection.current_selected) and Selection.current_selected:
			Selection.current_selected.add_paste_to_selected()
				
func add_paste_to_selected(only_image = false):
		
	# WARNING: This mostly overwrites things
	var image_file_path = Selection.clipboard.get_image()
	if image_file_path:
		print("Clipboard saved to: " + str(image_file_path))
		image_loader.set_image_from_local(image_file_path, false)
		set_link_tools_visible(false)
	else:
		if only_image:
			return
		var clip_text = Selection.clipboard.get_text()
		if clip_text:
			if clip_text.find("http") != -1:
				text_edit.text = clip_text
				text_edit.readonly = true
				image_loader.get_image(clip_text)
			else:
				# paste text if node is empty, or ask insert at cursor
				pass
#				Selection.current_selected.set_text_from_clipboard(clip_text)
#				Selection.current_selected.set_link_tools_visible(false)


func _on_BodyText_text_changed():
	update_rich_label_from_textbox()
