extends Node


const API_KEY_THUMBNAILSWS = "ab97c2113e52c3aeca17d5d2b218aa2a4ac169d95308"
export (int) var WEB_SNAPSHOT_WIDTH = 1080  #720

var http_request = HTTPRequest.new()


var is_image_local := false
var image_path := ""
var local_img_cache := ""

var _last_requested_link := ""

func _ready():
	add_child(http_request)

	http_request.connect("request_completed", self, "_http_request_completed")
	
func pick_image_name():
	return "user://images/"+persist.current_project_name +"/"+ Selection.clipboard.get_formatted_date() + ".png"

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

		get_parent().text_edit.text = url
		get_parent().text_edit.readonly = true
		#		set_node_has_image()
		return true

	#	set_node_empty()
	return false


func image_show_success(texture, path):
	get_parent().call("image_show_success", texture, path)
	
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
			get_parent().call("set_node_empty")
			return

	var new_path: String = pick_image_name()
	print("Saved web image to " + new_path)
	local_img_cache = new_path
	image.save_png(new_path)
	texture.create_from_image(image)
	image_show_success(texture, _last_requested_link)

func set_image_from_local(path, save = true):
	var texture: ImageTexture = ImageTexture.new()
	var err = texture.load(path)
	if err != OK:
		return false

	if save:
		var new_path: String = pick_image_name()
		print("Saved local image to " + new_path)
		local_img_cache = new_path
		texture.get_data().save_png(new_path)
	
	is_image_local = true
	image_show_success(texture, path)
	return true

func check_for_image(p_url: String = ""):
	var url
	if p_url and p_url.length() > 0:
		url = p_url
	else:
		url = get_parent().get_text_in_box().trim_suffix("\n")
	if url:
		var is_local = set_image_from_local(url)
		if not is_local:
			print("Local path not found, attempt to fetch URL.")
			var success = get_image(url)
			if success:
				var base_name = url.trim_prefix("http://").trim_prefix("https://")
				base_name = base_name.split("/")[0]
				#			title = str(base_name)


#				set_node_has_image()
#			else:
#				set_node_empty()
#	else:
#		set_node_empty()

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
		get_parent().set_node_empty()
		return false

	get_parent().text_edit.text = url
	get_parent().set_node_has_image()
	return true



func fetch_cached_image(path):
	var texture: ImageTexture = ImageTexture.new()
	var err = texture.load(path)
	if err != OK:
		return false
	
	image_show_success(texture, image_path)
	
	print("Load image from cache: %s"% path)
	return true

func load_image_from_persistance():
	var fetched_image_cache = false
	if local_img_cache:
		fetched_image_cache = fetch_cached_image(local_img_cache)
		
	if not fetched_image_cache:
		if image_path:
			if is_image_local:
				set_image_from_local(image_path, false)
			else:
				get_image(image_path)

