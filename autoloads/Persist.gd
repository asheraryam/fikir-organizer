extends Node

var EXTENSION = ".think"
var DEFAULT_PROJECT_NAME = "main_project"

var FOLDER_PROJECTS = "projects"
var DIR_PROJECTS = "user://"+ FOLDER_PROJECTS + "/"
var PROJECTS_LIST = "user://project_list" + EXTENSION

var current_project_name = "main_project"

func _ready():
	setup_directories(DEFAULT_PROJECT_NAME)
	load_game()

func init_project(project_name):
	current_project_name = project_name
	
	setup_directories(project_name)

func setup_directories(project_name):
	var directory :Directory= Directory.new()
	directory.open("user://")
	if not directory.dir_exists("images"):
		directory.make_dir("images")
	
	directory.open("user://images")
	if not directory.dir_exists(project_name):
		directory.make_dir(project_name)

func _input(event):
	if event.is_action_pressed("quit"):
		save_game()
		get_tree().quit()

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables
func save_game():
	if not current_project_name or current_project_name.length()==0:
		 current_project_name = DEFAULT_PROJECT_NAME
		
	var project_path = DIR_PROJECTS + current_project_name + EXTENSION
	
	var directory :Directory= Directory.new()
	directory.open("user://")
	if not directory.dir_exists(FOLDER_PROJECTS):
		print("Create new dir %s" % FOLDER_PROJECTS)
		directory.make_dir(FOLDER_PROJECTS)
		
	var save_game = File.new()
	var err = save_game.open(project_path, File.WRITE)
	if err != OK:
		print("Error opening with WRITE %s" % project_path)
		return ERR_FILE_CANT_WRITE
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load
#		if node.filename.empty():
#			print("Note: persistent node '%s' is not an instanced scene" % node.name)
#			continue

		# Check the node has a save function
		if not node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function
		var node_data = node.call("save")

		# Store the save dictionary as a new line in the save file
		save_game.store_line(to_json(node_data))
	save_game.close()

	print("PROJECT SAVED - %s" % current_project_name)
	
	return OK


func load_game(project_name = "main_project"):
	current_project_name = project_name
	
	if not current_project_name or current_project_name.length()==0:
		 current_project_name = DEFAULT_PROJECT_NAME
		
	var project_path = DIR_PROJECTS + current_project_name + EXTENSION
		
	var save_game = File.new()
	if not save_game.file_exists(project_path):
		print("Project not found at %s "% project_path)
		return ERR_FILE_NOT_FOUND # Error! We don't have a save to load.
		

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
#	var save_nodes = get_tree().get_nodes_in_group("Persist")
#	for i in save_nodes:
#		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open(project_path, File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		
		var new_object
		# Firstly, we need to create the object and add it to the tree and set its position.
		if "filename" in node_data and "parent" in node_data:
			new_object = load(node_data["filename"]).instance()
			get_node(node_data["parent"]).add_child(new_object)
		elif "path" in node_data:
			new_object = get_node(node_data["path"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "data":
				continue
			new_object.set(i, node_data[i])
		if new_object.has_method("load_more") and node_data["data"]:
			new_object.call_deferred("load_more",node_data["data"] )
	save_game.close()
	
	print("PROJECT LOADED - %s" % current_project_name)
	
	return OK
	
