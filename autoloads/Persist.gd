extends Node

var CURRENT_PROJECT_PATH = ""

var DEFAULT_PROJECT_PATH = "user://main_project.think"

func _ready():
	load_game()

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables
func save_game(project_path = "user://main_project.think"):
	CURRENT_PROJECT_PATH = project_path
	if not CURRENT_PROJECT_PATH or CURRENT_PROJECT_PATH.length()==0:
		CURRENT_PROJECT_PATH = DEFAULT_PROJECT_PATH
		
	var save_game = File.new()
	save_game.open(CURRENT_PROJECT_PATH, File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function
		if ! node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function
		var node_data = node.call("save")

		# Store the save dictionary as a new line in the save file
		save_game.store_line(to_json(node_data))
	save_game.close()

	# Note: This can be called from anywhere inside the tree. This function


# is path independent.
func load_game(project_path = "user://main_project.think"):
	CURRENT_PROJECT_PATH = project_path
	if not CURRENT_PROJECT_PATH or CURRENT_PROJECT_PATH.length()==0:
		CURRENT_PROJECT_PATH = DEFAULT_PROJECT_PATH
		
	var save_game = File.new()
	if not save_game.file_exists(CURRENT_PROJECT_PATH):
		return  # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open(CURRENT_PROJECT_PATH, File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "data":
				continue
			new_object.set(i, node_data[i])
		if new_object.has_method("load_more") and node_data["data"]:
			new_object.call_deferred("load_more",node_data["data"] )
	save_game.close()
