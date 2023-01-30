class_name ActionWait
extends Action

func execute(actor: Actor) -> ResultAction:
	var result: ResultAction = ResultAction.new(true, null)
	Events.add_event("%s waited." % actor.get_subject_name())
	return result
