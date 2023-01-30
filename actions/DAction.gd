class_name DirectionAction
extends Action

var game: Game
var target_pos: Vector2i
var offset: Vector2i

func _init(_game: Game, target: Vector2i = Vector2i(-1, -1)):
	game = _game
	target_pos = target

## Should be overridden
func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	# Haven't chosen direction yet, so go do that
	if target_pos == Vector2i(-1, -1):
		result.success = true
		# Queue up dir choice
		result.alternative = DirectionActionInput.new(self)
	# Otherwise, you have a position, so do the action needed
	else:
		print("override DAction")
		result.success = true
	
	return result

