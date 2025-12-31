extends Node2D

#const key = "AIzaSyDdNeoyFrNaxb2b0FAUTOQdf1_n5yBWIec"
#const key = "AIzaSyDlz-wJVb02B10dRq2KQH8gblRxvuBYX-s"
#const model ="gemini-2.5-flash-lite"

var response_str: String
signal requestCompleted
signal ready_nextround
static var spokenchain := ""

@onready var http_request = $http_request
@export var cards: PackedScene
func _on_http_request_request_completed(result, response_code, headers, body):
	print(result)
	print(response_code)
	if response_code == 200:
		response_str = parse_gemini_response(body)
		requestCompleted.emit()
		return
	response_str = "Error:" + str(response_code) + " " + str(result) + " " + str(headers)
	requestCompleted.emit()

func generate_content(prompt):
	var headers = ["Content-Type: application/json"]
	var request_data = {
		"contents": [{
			"parts":[{
				"text": prompt
			}]
		}]
	}
	print(request_data)
	http_request.request_completed.connect(_on_request_completed)
	var url = "https://generativelanguage.googleapis.com/v1beta/models/" + Global.model + ":generateContent?key=" + Global.key
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))
	print(error)
	
func parse_gemini_response(body):
	var response_string = JSON.parse_string(body.get_string_from_utf8())
	var content = response_string#['candidates'][0]['content']['parts'][0]['text']
	print(content)
	return content

func parse(spoken):
	if not Global.gameplus:
		$hud.update_parentdialogue("(processing)")
	else:
		$hud.update_parentdialogue("(process中)")
	var prompt = 'Ignore all prior prompts. I hear someone say phonetically (merriam webster notation) ' + spoken + '. Is there is a threat for the end of the world? Parsing rules: '
	if not Global.gameplus:
		prompt = prompt + ' Allow a small amount of vagueness while parsing sounds, but also take this into account for scoring. Weigh parsing towards infant talk and setting where disaster could be near. When multiple potential matches are possible, use up to 2 closest match only, but if one is significantly closer phonetically, use only 1. Arrange output in this format: word match, ";", number for threat from 1 to 100 scale, ";", number from 1 to 10 for how well phonetically it matched, ";", use this word in a sentence as parent would talk to infant in normal setting. If multiple words are matched, separate the output of each with "_", arrange with better match word first'
	else:
		prompt = prompt + ' First, treat the phonetics as Chinese PinYin. If there is a common Chinse phrase that exactly matches, return that and ignore matching English phonetics. If not, proceed to matching English phonetics, allowing a small amount of vagueness while parsing sounds, but also take this into account for scoring. Weigh parsing towards infant talk and setting where disaster could be near. When multiple potential matches are possible, use up to 2 closest match only, but if one is significantly closer phonetically, use only 1. Arrange output in this format: word match, ";", number for threat from 1 to 100 scale, ";", number from 1 to 10 for how well phonetically it matched, ";", use this word in a sentence as parent would talk to infant in normal setting. If multiple words are matched, separate the output of each with "_", arrange with better match word first'
	generate_content(prompt)
	#await requestCompleted
	#$HUD.update_parentdialogue(response_str)

func spawn_card1(pos, dict):
	var card1 = cards.instantiate()
	card1.name = "card" + str(pos)
	var spawn_location = $cardpath/cardloc
	spawn_location.progress_ratio = 0.1 * int(pos)
	card1.position = spawn_location.position
	var random_key = dict.keys()[randi() % dict.size()]
	var random_val = dict[random_key][0]
	var random_group = dict[random_key][1]
	card1.get_node("symbol").text = random_key
	card1.get_node("example").text = random_val
	if random_group == "vowel":
		#card1.get_node("symbol").set("theme_override_colors/font_color", Color("brown"))
		#card1.get_node("example").set("theme_override_colors/font_color", Color("brown"))
		card1.get_node("cardface").modulate = Color("light gray")
	else:
		card1.get_node("symbol").set("theme_override_colors/font_color", Color("black"))
		card1.get_node("example").set("theme_override_colors/font_color", Color("black"))
	add_child(card1)
	card1.add_to_group("mycards")
	
func spawn_card_stop(pos):
	var card1 = cards.instantiate()
	card1.name = "card" + "stop"
	var spawn_location = $cardpath/cardloc
	spawn_location.progress_ratio = 0.1 * int(pos)
	card1.position = spawn_location.position
	card1.get_node("symbol").text = "Stare"
	card1.get_node("example").text = "DONE"
	card1.get_node("cardface").modulate = Color("light green")
	add_child(card1)
	card1.add_to_group("mycards")
	
func spawn_card_random(group, pos):
	var card1 = cards.instantiate()
	card1.name = "card" + group
	var spawn_location = $cardpath2/cardloc2
	spawn_location.progress_ratio = 0.1 * int(pos)
	card1.position = spawn_location.position
	card1.get_node("symbol").text = group
	card1.get_node("example").text = "?"
	if group == "vowel":
		card1.get_node("cardface").modulate = Color("light gray")
	else:
		card1.get_node("symbol").set("theme_override_colors/font_color", Color("black"))
		card1.get_node("example").set("theme_override_colors/font_color", Color("black"))
	add_child(card1)
	card1.add_to_group("mycards")
	
func spawn_card_manual(sym, val, group, pos):
	var card1 = cards.instantiate()
	card1.name = "card" + sym + val
	var spawn_location = $cardpath2/cardloc2
	spawn_location.progress_ratio = 0.1 * int(pos)
	card1.position = spawn_location.position
	card1.get_node("symbol").text = sym
	card1.get_node("example").text = val
	if group == "vowel":
		card1.get_node("cardface").modulate = Color("light gray")
	else:
		card1.get_node("symbol").set("theme_override_colors/font_color", Color("black"))
		card1.get_node("example").set("theme_override_colors/font_color", Color("black"))
	add_child(card1)
	card1.add_to_group("mycards")	
	
func prepdict():
	var dict = {}
	var file = FileAccess.open("res://mwcd_pronunciation.csv", FileAccess.READ)
	while not file.eof_reached():
		var csv = file.get_csv_line()
		if len(csv) > 1:
			if csv[0] != "symbol":
				var symbol = csv[0]
				var example = csv[1]
				var group = csv[2]
				dict[symbol] = [example, group]
	file.close()
	return dict
	
func check_score():
	if Global.alertscore >= Global.targetscore:
		print("Disaster averted")
		show_win()
		await get_tree().create_timer(Global.waittime*2).timeout
		get_tree().reload_current_scene()
	elif Global.roundn - 1 >= 5:
		print("Try again")
		await get_tree().create_timer(Global.waittime).timeout
		get_tree().reload_current_scene() 
	else:
		return("more")

func show_game_over():
	Globalaudio.winner1.playing = false
	$winner.visible = false
	$winner.get_node("story").visible = false
	$winner.get_node("background").visible = false
	print("Showing story")
	$gameover.visible = true
	Globalaudio.gameover1.play()
	await get_tree().create_timer(Global.waittime).timeout
	$gameover.visible = false
	$hud/checklog.visible = true
	$hud/checkoptions.visible = true

func show_win():
	$gameover.visible = false
	print("Congrats")
	resetround()
	Globalaudio.winner1.play()
	$hud/checklog.visible = false
	$hud/checkoptions.visible = false
	$hud.visible = false
	if Global.gameplus:
		$winner.get_node("story").set("theme_override_fonts/font", load("res://NotoSansTC-Bold.ttf"))
		$winner.get_node("story").text="And thus, earth was rescued from armageddon, and our child could grow up with a normal childhood.\n作文寫完了嗎?不要老看電視"
	$winner.get_node("story").visible = true
	$winner.visible = true
	await get_tree().create_timer(Global.waittime).timeout
	$winner.get_node("background").visible = true
	Global.gameplus = true
	await get_tree().create_timer(Global.waittime).timeout
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$hud.visible = true
	$hud.get_node("popupmenu").get_node("timeset").value = Global.waittime
	$hud.get_node("popupmenu").get_node("scoreset").value = Global.targetscore
	$hud.get_node("popupmenu").get_node("accountselect").selected = 0
	$hud.get_node("popupmenu").get_node("modelselect").selected = 0
	Global.fullspoken=""
	Global.roundn=1
	Global.alertscore=0
	Global.readyround = true
	Global.dict = prepdict()
	show_game_over()
	if Global.gameplus:
		$hud.update_parentdialogue("好寶寶, are you trying to tell me something?")
		$hud.get_node("Label").text="Babble出去_________________________________________________"
		#$hud.get_node("parentbox").get_node("parentdialogue").set("theme_override_fonts/font", null)
		$hud.get_node("parentbox").get_node("parentdialogue").set("theme_override_fonts/font", load("res://NotoSansTC-Bold.ttf"))
	while Global.roundn <= 5:
		print("round " + str(Global.roundn))
		startround(Global.roundn, Global.dict)
		Global.roundn=Global.roundn+1
		await ready_nextround
		var result = await check_score()
		if result == "win":
			resetround()
			break
		if result == "again":
			resetround()
			break
	
func startround(roundn, dict):
	resetround()
	Global.fullspoken=""
	for x in range(roundn + 4):
		spawn_card1(x, dict)
	spawn_card_stop(roundn + 4)
	spawn_card_random("cons", 0)
	spawn_card_random("vowel", 1)
	if Global.roundn >= 2:
		spawn_card_manual("m", "mama", "cons", 8)
	if Global.roundn >= 3:
		if not Global.gameplus:
			spawn_card_manual("d", "dada", "cons", 9)
		else:
			spawn_card_manual("b", "baba", "cons", 9)
	$hud.update_time(9 + roundn*3)
	$hud.get_node("timebar").value = roundn + 1
	$hud.update_alert(Global.alertscore)
	$hud.get_node("alertbar").value = Global.alertscore + 1
	$hud.update_energy(Global.energynow, Global.energymax)
	Global.readyround = true
	await Global.ready_to_send
	var spoken = Global.fullspoken
	$hud.update_childdialogue(spoken)
	if spoken != "":
		parse(spoken)
		await requestCompleted
	else:
		if not Global.gameplus:
			$hud.update_parentdialogue("I could look at your little serious face all day.")
		else:
			$hud.update_parentdialogue("他好可愛喲")
	#var reaction = await parse(spoken)
	#$HUD.update_parentdialogue(reaction)
	ready_nextround.emit()

func resetround():
	Global.rounddict={}
	Global.energynow = Global.energynow + Global.energyrecov
	Global.checkenergy(Global.energynow, Global.energymax)
	$hud.get_node("energybar").value = Global.energynow + 1
	get_tree().call_group("mycards", "queue_free")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if json == null:
		if not Global.gameplus:
			$hud.update_parentdialogue("Sorry buddy, what's that?")
		else:
			$hud.update_parentdialogue("Sorry buddy, 沒聽懂呢?")
		return
	if "error" in json:
		if not Global.gameplus:
			$hud.update_parentdialogue("Sorry buddy, my brain is fried, can't understand a thing.")
		else:
			$hud.update_parentdialogue("Sorry buddy, 太累啦, can't understand a thing.")
		#Global.alertscore = 7 #TESTING
		#$hud.update_alert(Global.alertscore)
		#$hud.get_node("alertbar").value = Global.alertscore + 1
	else:
		Globalaudio.thinkeffect1.play()
		var reaction = json['candidates'][0]['content']['parts'][0]['text']
		var splits = reaction.split("_")
		var parsed = splits[0].split(";")
		if len(parsed) < 2 or len(parsed[0]) > 200:
			if not Global.gameplus:
				$hud.update_parentdialogue("Sorry sweetie, I might be hallucinating things, must be working too hard.")
			else:
				$hud.update_parentdialogue("Sorry sweetie, 大概累到産生幻覺了.")
		else:
			var threatscore = int(parsed[1])/10
			if threatscore > 5:
				Global.alertscore = Global.alertscore + threatscore
				$hud.update_alert(Global.alertscore)
				$hud.get_node("alertbar").value = Global.alertscore + 1
				$hud.update_parentdialogue(parsed[0] + "??!!")
			else:
				$hud.update_parentdialogue(parsed[0] + "? " + parsed[3])
			Global.rounddict = {
				$hud/childbox/childdialogue.text : {
					"parent" : $hud/parentbox/parentdialogue.text,
					"score" : threatscore,
					"model" : Global.model,
					"ngplus" : Global.gameplus
				}
			}
			print(Global.rounddict)
			$savelog.save_data(Global.rounddict)
	requestCompleted.emit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
