class_name ActionMoveProj
extends DirectionAction

func _init(_game: Game, target: Vector2i = Vector2i(-1, -1)):
	game = _game
	target_pos = target
	ENERGY_COST = 5

# execute
func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	var new_cell: Vector2i = actor.cell + offset
	
	# If there's not anything there, then you can move
	if not game.is_occupied(new_cell):
		result.set_cells(actor.cell, new_cell)
		
		result.success = true
		await actor.move_to_cell(new_cell)
		actor.energy_level -= ENERGY_COST
		(actor as Projectile).lifetime -= 1
		if actor.lifetime <= 0:
			Events.add_event("%s fell to the floor, broken and harmless." % actor.get_subject_name())
			actor.die()
		
		## Reset energy if action taken
		finished()
		return result
	
	# Otherwise, there is something, so start acting on that
	else:
		var cell: Cell = game.get_cell(new_cell)
		var all: Array = cell.get_all_actors_and_entities()
		
		if all.size() > 0:
			var front = all.pop_front()
			if front is Actor:
				result.success = true
				result.alternative = ActionAttack.new(game, new_cell)
				return result
		else:
			(actor as Projectile).die()
	
	return result

