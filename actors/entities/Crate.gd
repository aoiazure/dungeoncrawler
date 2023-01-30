class_name EntityCrate
extends Entity


func play_death_quote() -> void:
	Events.add_event("%s shattered into many pieces." % get_subject_name())
