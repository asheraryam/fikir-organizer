extends GraphNode

onready var http_request := $HTTPRequest

onready var text_edit = $HBoxContainer/TextEdit
var texture_rect : TextureButton

func _ready():
	texture_rect = get_node("ImageContainer/TextureRect")
	if not texture_rect:
		texture_rect = load("res://ImageTextureRect.tscn").instance()
		
	http_request.connect("request_completed", self, "_http_request_completed")
	
	texture_rect.connect("pressed", self, "_on_TextureRect_pressed" )

	
func get_image(url):
	var http_stat = http_request.get_http_client_status()
	if http_stat != HTTPClient.STATUS_CONNECTING and http_stat != HTTPClient.STATUS_RESOLVING:
		var error = http_request.request(url)
		if error != OK:
		#	push_error("An error occurred in the HTTP request.")
			return false
		return true
	
	return false


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
		set_node_empty()
		return
	
	print("Fetched image")
	var texture : ImageTexture = ImageTexture.new()
	
	texture.create_from_image(image)
	
	# Display the image in a TextureRect node.
#	var texture_rect = TextureRect.new()
#	add_child(texture_rect)
	texture_rect.texture_normal = texture
	$HBoxContainer/LockButton.visible = true
	$HBoxContainer/LockButton.pressed = true
	text_edit.readonly = true
			
	if not texture:
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
	self.raise()


func _on_TextEdit_gui_input(event: InputEvent):
	pass
#	if event.is_action_released("ui_accept"):
#		var url = text_edit.text.trim_suffix("\n")
#		get_image(url)
#		print("URL" + url)

func check_for_image():
	var url = text_edit.text.trim_suffix("\n")
	if url:
		var success = get_image(url)
		if success:
			var base_name = url.trim_prefix("http://").trim_prefix("https://")
			base_name = base_name.split("/")[0]
#			title = str(base_name)
			title = "Image"
			$HBoxContainer/URL_Label.visible = false
	#		$ImageContainer.add_child(texture_rect)
			$ImageContainer.visible = true
			print("URL" + url)
			texture_rect.rect_min_size = Vector2(160,160)

			if texture_rect.expand:
				rect_size = rect_min_size
		else:
			set_node_empty()
	else:
		set_node_empty()

func _on_TextEdit_text_changed():
	call_deferred("check_for_image")

func set_node_empty():
	title = "Image"
	$ImageContainer/TextureRect.texture_normal = null
#	$ImageContainer.remove_child(texture_rect)
	$ImageContainer.hide()
	$HBoxContainer/LockButton.visible = false
	$HBoxContainer/URL_Label.visible = true
	texture_rect.rect_min_size = Vector2(0,0)

	rect_size = rect_min_size
	
		


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
