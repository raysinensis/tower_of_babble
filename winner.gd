extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.gameplus:
		$story.set("theme_override_fonts/font", load("res://NotoSansTC-Bold.ttf"))
		$story.text="And thus, earth was rescued from armageddon, and our child could grow up with a normal childhood.\n作文寫完了嗎?不要老看電視"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
