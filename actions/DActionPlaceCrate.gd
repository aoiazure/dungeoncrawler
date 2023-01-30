class_name DirectionActionPlaceCrate
extends DirectionAction




func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	# Haven't chosen direction yet, so go do that
	if target_pos == Vector2i(-1, -1):
		result.success = true
		# Queue up dir choice
		result.alternative = DirectionActionInput.new(self)
		Events.add_event("> Input a direction to place a crate. Press ESC to cancel.")
	# Otherwise, you have a position, so make the box
	else:
		print(target_pos)
		var res: ResultCreate = game.create_entity(ActorPaths.CRATE, target_pos)
		result.success = res.success
		if result.success:
			actor.is_direction_input = null
			Events.add_event("%s placed a crate." % actor.get_character_name())
			finished()
	
	return result

