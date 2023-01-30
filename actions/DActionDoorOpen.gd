class_name ActionDoorOpen
extends DirectionAction

func _init(_game: Game, target: Vector2i = Vector2i(-1, -1)):
	game = _game
	target_pos = target
	ENERGY_COST = 2


# Execute
func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	var door: EntityDoor
	var others: Array = game.get_cell(target_pos).get_all_entities()
	for other in others:
		if other is EntityDoor:
			door = other
			break
	# If there's no door, return failure
	if not door:
		return result
	# Otherwise, try to open it
	result.success = door.open_door()
	if result.success:
		## Reset energy if action taken
		actor.energy_level -= ENERGY_COST
		Events.add_event("%s opened a door." % actor.get_subject_name())
		finished()
		return result
	return result


