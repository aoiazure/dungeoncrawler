class_name DirectionActionInteract
extends DirectionAction


func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	# Haven't chosen direction yet, so go do that
	if target_pos == Vector2i(-1, -1):
		result.success = true
		# Queue up dir choice
		result.alternative = DirectionActionInput.new(self)
		Events.add_event("> Input a direction to interact with. Press ESC to cancel.")
	# Otherwise, you have a position, so do the action needed
	else:
		var cell: Cell = game.get_cell(target_pos)
		if cell:
			if cell.has_entity():
				var others: Array = cell.get_all_entities()
				for other in others:
					if other is EntityDoor:
						if other.visible:
							result.alternative = ActionDoorOpen.new(game, target_pos)
						else:
							result.alternative = ActionDoorClose.new(game, target_pos)
						result.success = true
						actor.is_direction_input = null
						return result
	
	return result


