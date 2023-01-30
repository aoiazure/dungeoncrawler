# Stuff that doesn't act, but can be interacted with

class_name Entity
extends Actor

@export var is_obstacle: bool = true

@export_group("Stats")
@export var weight: float = 2.0


# die when dead
func die() -> void:
	play_death_quote()
	var cell: Cell = gameboard.get_cell(self.cell)
	cell.erase(self)
	gameboard.actors.erase(self)
	self.queue_free()
