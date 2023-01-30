class_name ResultCreate
extends Node

var obj_created
var success: bool = false

func _init(_success: bool, obj: Node) -> void:
	obj_created = obj
	success = _success
