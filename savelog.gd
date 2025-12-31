extends Node2D
const SAVE_FILE_PATH = "user://my_data.json"
	
#/Users/rfu/Library/Application Support/Godot/app_userdata/TowerOfBabble/my_data.json
func save_data(data_to_save: Dictionary):
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
		file.close()
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		file.store_string("\n")
		var json_string = JSON.stringify(data_to_save, "\t")
		file.store_string(json_string)
		file.close()
		print("Data saved to: ", SAVE_FILE_PATH)
	else:
		print("Failed to open file for writing. Error code: ", FileAccess.get_open_error())

func load_data() -> Dictionary:
	var n=0
	var allcontent = {}
	var parsed_content
	var json = JSON.new()
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var contents = content.split("}\n{")
			print(len(contents))
			file.close()
			for content1 in contents:
				if content1[0] != "{" and content1[1] != "{":
					content1 = "{" + content1
				if content1[-1] != "}":
					if content1[-3] != "\n":
						content1 = content1 + "}"
				json = JSON.new()
				parsed_content = json.parse_string(content1)
				if typeof(parsed_content) == TYPE_DICTIONARY:
					n+=1
					print(str(n) + " set of data loaded from: ", SAVE_FILE_PATH)
					print(parsed_content.keys()[0])
					allcontent[parsed_content.keys()[0]]=parsed_content[parsed_content.keys()[0]]
				else:
					print("Failed to parse JSON data.")
			return(allcontent)
		else:
			print("Failed to open file for reading. Error code: ", FileAccess.get_open_error())
	else:
		print("Save file does not exist, loading defaults.")
	return {} # Return empty dictionary or default values

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
