class_name ActionFireSpread
extends Action

var game: Game


func _init(_game: Game):
	game = _game
	ENERGY_COST = 5


func execute(actor: Actor) -> ResultAction:
	var result := ResultAction.new(false, null)
	
	# Spend energy
	actor.energy_level -= ENERGY_COST
	# Burn all in current cell
	var c: Cell = game.get_cell(actor.cell)
	for a in c.get_all_actors():
		a = (a as Actor)
		if a.get_flammable():
			a.apply_status()
			actor.attack(a)
	
	# Burn surrounding world
	var adj_cells = c.get_adjacent_cells()
	# For every adj cell
	for cell in adj_cells:
		# random spread chance; only 67% chance to spread
		randomize()
		if randi_range(0, 2) == 0:
			continue
		
		cell = (cell as Cell)
		var actors: Array = cell.get_all_actors()
		var flammable: bool = false
		for a in actors:
			a = (a as Actor)
			# Only ever have one fire per cell
			if a is EntityFire:
				flammable = false
				continue
			if a.get_flammable():
				flammable = true
		
		if flammable:
			print("it spread")
			game.create_actor(ActorPaths.FIRE, cell.cell)
	
	# Use up lifetime
	(actor as EntityFire).set_cur_hp(actor.get_cur_hp() - 1)
	if actor.get_cur_hp() <= 0:
		actor.die()
	
	finished()
	return result


