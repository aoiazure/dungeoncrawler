class_name DirectionActionFireProjectile
extends DirectionAction

const DIRECTIONS = [
	Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
]

var proj: String

func _init(_game: Game, proj_path: String, target: Vector2i = Vector2i(-1, -1)):
	game = _game
	proj = proj_path
	target_pos = target
	ENERGY_COST = 5

## Should be overridden
func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(false, null)
	
	# Haven't chosen direction yet, so go do that
	if target_pos == Vector2i(-1, -1):
		result.success = true
		# Queue up dir choice
		result.alternative = DirectionActionInput.new(self)
		Events.add_event("> Input a direction to fire the projectile. Cardinals only. Press ESC to cancel.")
	# Otherwise, you have a position, so do the action needed
	else:
		if offset in DIRECTIONS:
			var res: ResultCreate = game.create_actor(proj, target_pos)
			result.success = res.success
			if result.success:
				actor.is_direction_input = null
				actor.energy_level -= ENERGY_COST
				(res.obj_created as Projectile)._set_direction(offset)
				Events.add_event("%s fired %s." % [actor.get_subject_name(), res.obj_created.get_object_name()])
				finished()
	
	return result

