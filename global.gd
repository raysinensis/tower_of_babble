extends Node
# settings
var key1 = "enter gemini api key"
var key2 = "enter alternative gemini api key"
var key = key1
var model1 ="gemini-2.5-flash-lite"
var model2 ="gemini-2.5-flash"
var model3 ="gemini-3-flash-preview"
var model = model1
var targetscore = 10
var waittime = 5
# various
var fullspoken=""
var roundn=1
var energymax=9
var energynow=energymax
var energyrecov=3
var alertscore=0
var readyround = true
var gameplus = false
var rounddict={}
var alldict={}
var dict={}

signal ready_to_send
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func checkenergy(x, maxx):
	if x< 0:
		print("oh no")
	if x>maxx:
		Global.energynow = Global.energymax
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
