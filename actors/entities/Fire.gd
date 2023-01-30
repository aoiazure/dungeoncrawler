class_name EntityFire
extends Entity

func _ready():
	super()
	randomize()
	set_max_hp(randi_range(1, 5))
	set_cur_hp(get_max_hp())


func get_action() -> Action:
	var action: Action
	
	action = ActionFireSpread.new(gameboard)
	
	return action

func play_attack_quote(_subj: String, _obj: String) -> void:
	## do nothing on attack
	pass

func play_death_quote() -> void:
#	Events.add_event("%s burned out." % get_subject_name())
	pass


