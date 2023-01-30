class_name Projectile
extends Actor

@export var lifetime: int = 5

var direction: Vector2i = Vector2i.UP : set=_set_direction

func _ready():
	energy_level = 5

func init(_speed: int, dir: Vector2i) -> void:
	self.speed = _speed
	_set_direction(dir)

func _set_direction(value: Vector2i) -> void:
	direction = value
	match direction:
		Vector2i.UP: rotation_degrees = 0.0
		Vector2i.RIGHT: rotation_degrees = 90.0
		Vector2i.DOWN: rotation_degrees = 180.0
		Vector2i.LEFT: rotation_degrees = 270.0

## Do hurting
func attack(defender: Actor) -> bool:
	play_attack_quote(get_subject_name(), defender.get_object_name())
	die()
	return defender.take_damage(get_damage())


## Command pattern
func get_action() -> Action:
	var action: Action = null
	
	action = ActionMoveProj.new(gameboard, direction)
	(action as ActionMoveProj).offset = direction
	
	return action

# die when dead
func die() -> void:
	var cell: Cell = gameboard.get_cell(self.cell)
	cell.erase(self)
	gameboard.actors.erase(self)
	self.queue_free()



