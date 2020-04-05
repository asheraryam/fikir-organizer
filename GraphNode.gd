extends GraphNode

var API_KEY_THUMBNAILSWS = "ab97c2113e52c3aeca17d5d2b218aa2a4ac169d95308"
export (int) var WEB_SNAPSHOT_WIDTH = 1080  #720

export (Vector2) var MIN_TEX_SIZE := Vector2(160, 160)

onready var http_request := $HTTPRequest
onready var text_edit = $HBoxContainer/ImageSettings/TextEdit
onready var lock_btn = $HBoxContainer/ImageSettings/LockButton
onready var url_label = $HBoxContainer/ImageSettings/URL_Label
onready var body_textedit = $CaptionContainer/BodyContainer/BodyText
onready var rich_text = $CaptionContainer/RichTextContainer/RichText

	
onready var texture_rect: TextureButton = get_node("ImageContainer/TextureRect")

var is_image_local := false
var image_path := ""
var local_img_cache := ""

var _last_requested_link := ""


func _ready():
	if not texture_rect:
		texture_rect = load("res://ImageTextureRect.tscn").instance()

	http_request.connect("request_completed", self, "_http_request_completed")

	texture_rect.connect("pressed", self, "_on_TextureRect_pressed")


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
		raise()
		set_rich_text_visible(false)
	else:
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
	rich_text.rect_min_size = body_textedit.rect_size


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


func check_for_image(p_url: String = ""):
	var url
	if p_url and p_url.length() > 0:
		url = p_url
	else:
		url = text_edit.text.trim_suffix("\n")
	if url:
		var is_local = set_image_from_local(url)
		if not is_local:
			print("Local path not found, attempt to fetch URL.")
			var success = get_image(url)
			if success:
				var base_name = url.trim_prefix("http://").trim_prefix("https://")
				base_name = base_name.split("/")[0]
				#			title = str(base_name)
				title = "Image"


#				set_node_has_image()
#			else:
#				set_node_empty()
#	else:
#		set_node_empty()


func _on_TextEdit_text_changed():
	pass


#	call_deferred("check_for_image")


func set_node_empty():
	title = "Image"
	$ImageContainer/TextureRect.texture_normal = null
	#	$ImageContainer.remove_child(texture_rect)
	$ImageContainer.hide()

	texture_rect.rect_min_size = Vector2(0, 0)
	rect_size = rect_min_size


func set_link_tools_visible(is_visible):
	if is_visible:
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
		if texture_rect.texture_normal:
			texture_rect.expand = false
	else:
		texture_rect.expand = true
		rect_size = rect_min_size


func _on_LockButton_toggled(button_pressed):
	text_edit.readonly = button_pressed

func get_snapshot(url: String):
	var thing = (
		"https://api.thumbnail.ws/api/"
		+ API_KEY_THUMBNAILSWS
		+ "/thumbnail/get?url="
		+ url.percent_encode()
		+ "&width="
		+ str(WEB_SNAPSHOT_WIDTH).percent_encode()
	)
	_last_requested_link = thing
	is_image_local = false

	print(thing)

	var error = http_request.request(thing)
	if error != OK:
		#	push_error("An error occurred in the HTTP request.")
		set_node_empty()
		return false

	text_edit.text = url
	set_node_has_image()
	return true


func set_text_from_clipboard(clip_text: String):
	print("Set text edit from clipboard" + clip_text)
	body_textedit.text = clip_text
	body_textedit._on_ExpandingText_text_changed()


func set_image_from_local(path):
	var texture: ImageTexture = ImageTexture.new()
	var err = texture.load(path)
	if err != OK:
		return false

	var new_path: String = "user://" + Selection.ClipBoardUtils.get_formatted_date() + ".png"
	print("Saved local image to " + new_path)
	local_img_cache = new_path
	texture.get_data().save_png(new_path)
	
	is_image_local = true
	image_show_success(texture, path)
	return true

func fetch_cached_image(path):
	var texture: ImageTexture = ImageTexture.new()
	var err = texture.load(path)
	if err != OK:
		return false
	
	image_show_success(texture, image_path)
	
	print("Load image from cache: %s"% path)
	return true


func image_show_success(texture, path):
	image_path = path

	text_edit.text = path
	texture_rect.texture_normal = texture
	set_link_tools_visible(true)
	lock_btn.pressed = true
	text_edit.readonly = true

	if texture:
		set_node_has_image()
	else:
		set_node_empty()


func get_image(url: String):
	if url.find("gyazo.com") != -1 and url.find("i.gyazo.com") == -1:
		print("Fixing gyazo link")
		url.replace("gyazo.com", "i.gyazo.com")
		url += ".png"
	elif url.find("imgur.com") != -1 and url.find("i.imgur.com") == -1:
		print("Fixing imgur link")
		url.replace("imgur.com", "i.imgur.com")
		url += ".png"

	_last_requested_link = url
	is_image_local = false

	var http_stat = http_request.get_http_client_status()
	if http_stat != HTTPClient.STATUS_CONNECTING and http_stat != HTTPClient.STATUS_RESOLVING:
		var error = http_request.request(url)
		if error != OK:
			#	push_error("An error occurred in the HTTP request.")
			#			set_node_empty()
			return false

		text_edit.text = url
		text_edit.readonly = true
		#		set_node_has_image()
		return true

	#	set_node_empty()
	return false


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var image := Image.new()

	print("Fetched image")
	var texture: ImageTexture = ImageTexture.new()

	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load png image, trying as jpg.")
		var image_error = image.load_jpg_from_buffer(body)
		if image_error != OK:
			push_error("Couldn't load jpg image.")
			set_node_empty()
			return

	var new_path: String = "user://" + Selection.ClipBoardUtils.get_formatted_date() + ".png"
	print("Saved web image to " + new_path)
	local_img_cache = new_path
	image.save_png(new_path)
	texture.create_from_image(image)

	image_show_success(texture, _last_requested_link)


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
		"image_path": image_path,
		"is_image_local": is_image_local,
		"local_img_cache": local_img_cache,
		"rect_size": rect_size,
		"rect_min_size": rect_min_size,
		"rect_position": rect_position,
		"data": {"text_body": body_textedit.text,
		"offset_x" :offset.x, 
		"offset_y" :offset.y, }
	}


func load_more(data):
	init_state()
	
	set_link_tools_visible(false)
	
	if "offset_x" in data:
		offset.x = data["offset_x"]
	if "offset_x" in data:
		offset.y = data["offset_y"]
	body_textedit.text = data["text_body"]
	body_textedit._on_ExpandingText_text_changed()
	
	var fetched_image_cache = false
	if local_img_cache:
		fetched_image_cache = fetch_cached_image(local_img_cache)
	
	if not fetched_image_cache:
		if image_path:
			if is_image_local:
				set_image_from_local(image_path)
			else:
				get_image(image_path)
	


func _on_RichText_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			print("Pressed on RTL")
			set_selected(true)
			_on_Node_raise_request()
			body_textedit.grab_focus()


func _on_CaptionContainer_mouse_entered():
	return


#	set_rich_text_visible(false)


func _on_CaptionContainer_mouse_exited():
	return


#	set_rich_text_visible(true)


func _on_BodyText_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			print("Pressed on Body text")
			set_selected(true)
			_on_Node_raise_request()
			body_textedit.grab_focus()


func _on_GraphNode_gui_input(event):
	pass  # Replace with function body.
