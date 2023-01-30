class_name ResultAction
extends Node

## If action was successfully completed
var success: bool
## If there is an alternative action to try
var alternative: Action = null

## If actor moved
var old_cell: Vector2 = Vector2i(-1, -1)
var new_cell: Vector2 = Vector2i(-1, -1)

## Set up basic ResultAction
func _init(_success: bool, _alternative: Action):
	success = _success
	alternative = _alternative

## If the actor moved
func has_moved() -> bool:
	return old_cell != new_cell

func set_cells(_old: Vector2i, _new: Vector2i) -> void:
	old_cell = _old
	new_cell = _new
