extends CanvasLayer
@export var cell_scene: PackedScene

func update_time(week):
	$time.text = "  Week " + str(week)
func update_alert(score):
	$alert.text = "Alert Level: "+str(score)
func update_energy(currente, maxe):
	$energy.text = "Energy: "+str(currente)+"/"+str(maxe)+"  "
func update_childdialogue(text):
	$childbox.get_node("childdialogue").text = text
func update_parentdialogue(text):
	$parentbox.get_node("parentdialogue").text = text
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_checklog_pressed():
	print(get_tree().get_root().get_node("main").get_node("savelog"))
	Global.alldict = get_tree().get_root().get_node("main").get_node("savelog").load_data() 
	print(Global.alldict)
	var dialog = $popuplog
	dialog.get_node("popupscroll").get_node("popupmargin").get_node("tablegrid").get_node("popuptext").text = str(Global.alldict.keys())
	#dialog.text = "hi"#str(Global.alldict)
	#dialog.connect("modal_closed", Callable(dialog, "queue_free"))
	#get_tree().get_root().get_node("main").add_child(dialog)
	populate_grid(len(Global.alldict.keys()), 3)
	dialog.popup()
	pass # Replace with function body.

func populate_grid(rows: int, columns: int):
	$popuplog/popupscroll/popupmargin/tablegrid.columns = columns 
	get_tree().call_group("mycells", "queue_free")
	for row in range(rows):
		for col in range(columns):
			var cell_instance = cell_scene.instantiate()
			cell_instance.name = "cell"+"_"+ str(row)+"_"+str(col)
			if col == 0:
				cell_instance.get_node("cell_text").text = Global.alldict.keys()[row]
				var new_sb = StyleBoxFlat.new()
				new_sb.bg_color = Color.SKY_BLUE
				cell_instance.add_theme_stylebox_override("panel", new_sb)
			if col == 2:
				cell_instance.get_node("cell_text").text = Global.alldict[Global.alldict.keys()[row]]["parent"]#str(row + col)
			if col == 1:
				cell_instance.get_node("cell_text").text = str(Global.alldict[Global.alldict.keys()[row]]["score"])
				var new_sb = StyleBoxFlat.new()
				new_sb.bg_color = Color.RED
				cell_instance.add_theme_stylebox_override("panel", new_sb)
			$popuplog/popupscroll/popupmargin/tablegrid.add_child(cell_instance)
			cell_instance.add_to_group("mycells")
	$popuplog/popupscroll/popupmargin/tablegrid.queue_sort()



func _on_checkoptions_pressed():
	var dialog2 = $popupmenu
	dialog2.popup()
	pass # Replace with function body.

func _on_accountselect_item_selected(index):
	print($popupmenu/accountselect.get_selected_id())
	if $popupmenu/accountselect.get_selected_id() == 0:
		Global.key = Global.key1
	elif $popupmenu/accountselect.get_selected_id() == 1:
		Global.key = Global.key2
	pass # Replace with function body.


func _on_modelselect_item_selected(index):
	print($popupmenu/modelselect.get_selected_id())
	if $popupmenu/modelselect.get_selected_id() == 0:
		Global.model = Global.model1
	elif $popupmenu/modelselect.get_selected_id() == 1:
		Global.model = Global.model2
	elif $popupmenu/modelselect.get_selected_id() == 2:
		Global.model = Global.model3
	pass # Replace with function body.

func _on_scoreset_value_changed(value):
	Global.targetscore = value
	pass # Replace with function body.

func _on_timeset_value_changed(value):
	Global.waittime = value
	pass # Replace with function body.

func thinking(mood):
	if mood == "random":
		$emote_idea.visible = true
		$emote_sleep.visible = false
		$emote_think1.visible = false
		$emote_think2.visible = false
		$emote_think3.visible = false
	elif mood == "sleep":
		$emote_sleep.visible = true
		$emote_think1.visible = false
		$emote_think2.visible = false
		$emote_think3.visible = false
		$emote_idea.visible = false
	elif $emote_think1.visible:
		$emote_think1.visible = false
		$emote_think2.visible = true
		$emote_sleep.visible = false
		$emote_idea.visible = false
	elif $emote_think2.visible:
		$emote_think2.visible = false
		$emote_think3.visible = true
		$emote_sleep.visible = false
		$emote_idea.visible = false
	elif $emote_think3.visible:
		$emote_think3.visible = false
		$emote_think1.visible = true
		$emote_sleep.visible = false
		$emote_idea.visible = false
	else:
		$emote_think1.visible = true
		$emote_sleep.visible = false
		$emote_idea.visible = false
