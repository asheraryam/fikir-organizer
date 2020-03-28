extends GraphNode

var API_KEY_THUMBNAILSWS = "ab97c2113e52c3aeca17d5d2b218aa2a4ac169d95308"
var SNAPSHOT_WIDTH = 1080 #720
onready var http_request := $HTTPRequest

onready var text_edit = $HBoxContainer/ImageSettings/TextEdit
onready var lock_btn = $HBoxContainer/ImageSettings/LockButton
onready var url_label = $HBoxContainer/ImageSettings/URL_Label
var texture_rect : TextureButton

func _ready():
	texture_rect = get_node("ImageContainer/TextureRect")
	if not texture_rect:
		texture_rect = load("res://ImageTextureRect.tscn").instance()
		
	http_request.connect("request_completed", self, "_http_request_completed")
	
	texture_rect.connect("pressed", self, "_on_TextureRect_pressed" )


func get_snapshot(url:String):
	var thing = "https://api.thumbnail.ws/api/" + API_KEY_THUMBNAILSWS + "/thumbnail/get?url=" +url.percent_encode()+"&width="+ str(SNAPSHOT_WIDTH).percent_encode()
	print(thing)
	var error = http_request.request(thing)
	if error != OK:
	#	push_error("An error occurred in the HTTP request.")
		set_node_empty()
		return false
	
	text_edit.text = url
	set_node_has_image()
	return true

func get_image(url : String):
	if url.find("gyazo.com") != -1 and url.find("i.gyazo.com") == -1:
		print("Fixing gyazo link")
		url.replace("gyazo.com", "i.gyazo.com")
		url += ".png"
	elif url.find("imgur.com") != -1 and url.find("i.imgur.com") == -1:
		print("Fixing imgur link")
		url.replace("imgur.com", "i.imgur.com")
		url += ".png"
	

		
	var http_stat = http_request.get_http_client_status()
	if http_stat != HTTPClient.STATUS_CONNECTING and http_stat != HTTPClient.STATUS_RESOLVING:
		var error = http_request.request(url)
		if error != OK:
		#	push_error("An error occurred in the HTTP request.")
			set_node_empty()
			return false
		
		text_edit.text = url
		set_node_has_image()
		return true
	
	set_node_empty()
	return false


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	
	print("Fetched image")
	var texture : ImageTexture = ImageTexture.new()

	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load png image, trying as jpg.")
		var image_error = image.load_jpg_from_buffer(body)
		if image_error != OK:
			push_error("Couldn't load jpg image.")
			set_node_empty()
			return
	
	texture.create_from_image(image)
	
	# Display the image in a TextureRect node.
#	var texture_rect = TextureRect.new()
#	add_child(texture_rect)
	texture_rect.texture_normal = texture
	lock_btn.visible = true
	lock_btn.pressed = true
	text_edit.readonly = true
			
	if texture:
		set_node_has_image()
	else:
		set_node_empty()
		
#	$TextureRect.rect_size = texture.get_size()

func _on_Node_close_request():
	queue_free()
	print('removing node')

func _on_Node_resize_request(new_minsize):
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
	raise()
	$BodyText.grab_focus()

func _on_TextEdit_gui_input(event: InputEvent):
	if event.is_action_released("ui_accept"):
		call_deferred("check_for_image")


func check_for_image(p_url: String = ""):
	var url 
	if p_url and p_url.length() >0:
		url = p_url
	else:
		url = text_edit.text.trim_suffix("\n")
	if url:
		var success = get_image(url)
		if success:
			if p_url:
				text_edit.text = p_url
			var base_name = url.trim_prefix("http://").trim_prefix("https://")
			base_name = base_name.split("/")[0]
#			title = str(base_name)
			title = "Image"
			set_node_has_image()
		else:
			set_node_empty()
	else:
		set_node_empty()

func _on_TextEdit_text_changed():
	pass
#	call_deferred("check_for_image")

func set_node_empty():
	$HBoxContainer/ImageSettings.visible = false
	
	title = "Image"
	$ImageContainer/TextureRect.texture_normal = null
#	$ImageContainer.remove_child(texture_rect)
	$ImageContainer.hide()
	lock_btn.visible = false
	url_label.visible = true
	texture_rect.rect_min_size = Vector2(0,0)

	rect_size = rect_min_size

func set_node_has_image():
	$HBoxContainer/ImageSettings.visible = true
	url_label.visible = false
#		$ImageContainer.add_child(texture_rect)
	$ImageContainer.visible = true
	texture_rect.rect_min_size = Vector2(160,160)

	if texture_rect.expand:
		rect_size = rect_min_size
	
func force_selected():
	selected= true
	$BodyText.grab_focus()


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

func save_node():
	return {
		"image_url": text_edit.text.trim_suffix("\n"),
		"text_body": $BodyText.text
	}


func _on_LockButton_toggled(button_pressed):
	text_edit.readonly = button_pressed


