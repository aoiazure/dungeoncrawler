class_name Shadow
extends Node

var start: float
var end: float
var start_pos: Vector2
var end_pos: Vector2

func _init(_start: float, _end: float, _start_pos: Vector2, _end_pos: Vector2):
	start = _start
	end = _end
	start_pos = _start_pos
	end_pos = _end_pos

# Returns `true` if [other] is completely covered by this shadow.
func contains(other: Shadow) -> bool:
	return self.start <= other.start and self.end >= other.end

