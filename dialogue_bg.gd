extends Node

func _ready():
	child_speak = "dada"
	parent_speak = parse_child(child_speak)
