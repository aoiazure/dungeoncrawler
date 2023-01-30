class_name ActionMove
extends Action

var game: Game
var offset: Vector2i

# set mandatory refs
func _init(_game: Game, _offset: Vector2i):
	game = _game
	offset = _offset
	ENERGY_COST = 5

# execute
func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	var new_cell: Vector2i = actor.cell + offset
	
	# For dir input
	if actor.is_direction_input != null:
		var da: DirectionAction = actor.is_direction_input
		da.target_pos = new_cell
		da.offset = offset
		result.success = true
		result.alternative = da
		return result
	
	# If there's not anything there, then you can move
	if not game.is_occupied(new_cell):
		return await move(actor, new_cell)
	# Otherwise, there is something, so start acting on that
	else:
		var cell: Cell = game.get_cell(new_cell)
		var all: Array = cell.get_all_actors_and_entities()
		
		if all.size() > 0:
			var front = all.pop_front()
			if front is EntityDoor:
				if front.visible:
					result.success = true
					result.alternative = ActionDoorOpen.new(game, new_cell)
					return result
				else:
					return await move(actor, new_cell)
			
			if front is Actor:
				result.success = true
				result.alternative = ActionAttack.new(game, new_cell)
				return result
	
	return result

func move(actor: Actor, new_cell: Vector2i) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	result.set_cells(actor.cell, new_cell)
	result.success = true
	await actor.move_to_cell(new_cell)
	actor.energy_level -= ENERGY_COST
	## Reset energy if action taken
	finished()
	return result
