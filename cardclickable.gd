extends Area2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if not Global.readyround:
			Global.readyround = true
			return 
		var userandom = false
		print(get_name())
		print(get_node("symbol").text)
		Globalaudio.pickeffect1.play()
		$cardface.modulate.a = 0.1
		self.position[1] = self.position[1]+20
		input_pickable = false
		if get_node("symbol").text == "Stare":
			Global.ready_to_send.emit()
			print("let's go")
			Global.readyround = false
			return
		elif get_node("symbol").text == "vowel" or get_node("symbol").text == "cons":
			var random_key=""
			var random_val=""
			var random_group=""
			var stop=false
			while not stop:
				random_key = Global.dict.keys()[randi() % Global.dict.size()]
				random_val = Global.dict[random_key][0]
				random_group = Global.dict[random_key][1]
				if random_group.substr(0,4) == get_node("symbol").text.substr(0,4):
					stop=true
			get_node("symbol").text = random_key
			get_node("example").text = random_val
			userandom = true
		Global.energynow = Global.energynow - 1
		get_tree().get_root().get_node("main").get_node("hud").get_node("energybar").value = Global.energynow + 1
		get_tree().get_root().get_node("main").get_node("hud").update_energy(Global.energynow, Global.energymax)
		Global.fullspoken = Global.fullspoken + get_node("symbol").text
		if Global.energynow == 0:
			get_tree().get_root().get_node("main").get_node("hud").thinking("sleep")
			Global.ready_to_send.emit()
			print("let's go, you're tired")
			Global.readyround = false
		else:
			print(userandom)
			if userandom:
				get_tree().get_root().get_node("main").get_node("hud").thinking("random")
			else:
				get_tree().get_root().get_node("main").get_node("hud").thinking("")
		print(Global.fullspoken)
# Called when the node enters the scene tree for the first time.
func _ready():
	input_pickable = true
	input_event.connect(_on_input_event)
	pass
	#i
	#self.connect("input_event", "_on_Area2D_input_event")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
