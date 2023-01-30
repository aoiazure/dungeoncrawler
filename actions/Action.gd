class_name Action
extends Node

signal action_finished

var ENERGY_COST: int

func execute(_actor: Actor) -> ResultAction:
	var result := ResultAction.new(false, null)
	print("override this")
	
	finished()
	return result


func finished() -> void:
	emit_signal("action_finished")
