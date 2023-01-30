class_name EntityDoor
extends Entity

func toggle_door() -> bool:
	var result: bool = false
	# door closed
	if self.visible:
		result = open_door()
	else:
		result = close_door()
	return result

func open_door() -> bool:
	var success: bool = true
	self.visible = false
	is_obstacle = false
	
	return success


func close_door() -> bool:
	var success: bool = true
	self.visible = true
	is_obstacle = true
	
	return success

func play_death_quote() -> void:
	Events.add_event("%s shattered into many pieces." % get_subject_name())
