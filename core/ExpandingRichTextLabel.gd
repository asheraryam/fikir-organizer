tool
extends RichTextLabel
class_name ExpandingRichTextLabel

var _previous_size : int = 0 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_size : int = get_v_scroll().max_value
	
	if not _previous_size == new_size:
		rect_size.y = new_size
		rect_min_size.y = new_size
		_previous_size = new_size
