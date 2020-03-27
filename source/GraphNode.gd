extends GraphNode

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
	if event.is_action_released("ui_accept"):
		print(var2str(event))
