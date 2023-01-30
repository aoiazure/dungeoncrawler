## Action to get a direction for other actions

class_name DirectionActionInput
extends Action

var action: Action

func _init(action_for: Action):
	ENERGY_COST = 0
	action = action_for



func execute(actor: Actor) -> ResultAction:
	var result := ResultAction.new(false, null)
	
	actor.is_direction_input = action
	# false to keep the turn on the current actor!
	result.success = false
	
	return result



