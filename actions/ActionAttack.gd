class_name ActionAttack
extends Action

var game: Game
var defender_pos: Vector2

func _ready():
	ENERGY_COST = 5

func _init(_game: Game, defender_position: Vector2i):
	game = _game
	defender_pos = defender_position


func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	var cell: Cell = game.get_cell(defender_pos)
	var all: Array = cell.get_all_actors_and_entities()
	var defender
	
	if all.size() > 0:
		defender = all.pop_front()
		if defender.has_method("take_damage"):
			## Reset energy if action taken
			result.success = actor.attack(defender)
			actor.energy_level -= ENERGY_COST
			finished()
		return result
	else:
		result.success = false
	
	return result

