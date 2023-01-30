class_name Firebolt
extends Projectile

const fire := "res://actors/entities/Fire.tscn"

## Do hurting
func attack(defender) -> bool:
	var res: bool = false
	if defender is Actor:
		Events.add_event("%s strikes %s." % [self.get_subject_name(), defender.get_object_name()])
		res = defender.take_damage(get_damage())
		if (defender as Actor).get_flammable():
			gameboard.create_actor(fire, defender.cell)
		die()
	return res



func play_death_quote() -> void:
	pass
