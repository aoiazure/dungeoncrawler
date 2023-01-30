class_name ShadowLine
extends Node

var _shadows: Array[Shadow] = []

func is_in_shadow(projection: Shadow) -> bool:
	for shadow in _shadows:
		if shadow.contains(projection):
			return true
	return false


# Add [shadow] to the list of non-overlapping shadows. May merge one or more shadows.
func add(shadow: Shadow) -> void:
	# See where to insert it into the list
	var index: int = 0
	
	for i in range(_shadows.size()):
		index = i
		# Stop when we found insert spot
		if _shadows[i].start >= shadow.start:
			break
	
	# New shadow is going here, check if overlaps prev
	var overlapping_prev: Shadow
	if (index > 0) and (_shadows[index - 1].end > shadow.start):
		overlapping_prev = _shadows[index - 1]
	
	var overlapping_next: Shadow
	if (index < _shadows.size()) and (_shadows[index].start < shadow.end):
		overlapping_next = _shadows[index]
	
	# Insert and unify overlapping shadows
	if overlapping_next != null:
		# overlaps both, so unify one, delete other
		if overlapping_prev != null:
			overlapping_prev.end = overlapping_next.end
			overlapping_prev.end_pos = overlapping_next.end_pos
			_shadows.remove_at(index)
		else:
			# Only overlaps next, so unify it with that
			overlapping_next.start = shadow.start
			overlapping_next.start_pos = shadow.start_pos
	else:
		if overlapping_prev != null:
			# Only overlaps prev, so unify it with that
			overlapping_prev.end = shadow.end
			overlapping_prev.end_pos = shadow.end_pos
		else:
			# No overlaps, so insert
			_shadows.insert(index, shadow)



func is_full_shadow() -> bool:
	return _shadows.size() == 1 and _shadows[0].start == 0 and _shadows[0].end == 1







