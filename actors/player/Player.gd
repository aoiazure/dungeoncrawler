class_name Player
extends Actor

func get_action() -> Action:
	var action: Action = null
	if Input.is_action_just_pressed("move_left"):
		action = ActionMove.new(gameboard, Vector2.LEFT)
	if Input.is_action_just_pressed("move_up"):
		action = ActionMove.new(gameboard, Vector2.UP)
	if Input.is_action_just_pressed("move_right"):
		action = ActionMove.new(gameboard, Vector2.RIGHT)
	if Input.is_action_just_pressed("move_down"):
		action = ActionMove.new(gameboard, Vector2.DOWN)
	if Input.is_action_just_pressed("move_up_left"):
		action = ActionMove.new(gameboard, Vector2(-1, -1))
	if Input.is_action_just_pressed("move_up_right"):
		action = ActionMove.new(gameboard, Vector2(1, -1))
	if Input.is_action_just_pressed("move_down_left"):
		action = ActionMove.new(gameboard, Vector2(-1, 1))
	if Input.is_action_just_pressed("move_down_right"):
		action = ActionMove.new(gameboard, Vector2(1, 1))
	
	if Input.is_action_just_pressed("wait"):
		action = ActionWait.new()
	
	if Input.is_action_just_pressed("interact_with"):
		action = DirectionActionInteract.new(gameboard)
	if Input.is_action_just_pressed("shoot_arrow"):
		action = DirectionActionFireProjectile.new(gameboard, ActorPaths.ARROW)
	if Input.is_action_just_pressed("firebolt"):
		action = DirectionActionFireProjectile.new(gameboard, ActorPaths.FIREBOLT)
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		action = null
		if is_direction_input:
			is_direction_input = null
			Events.add_event("> Input cancelled.")
	
	return action
