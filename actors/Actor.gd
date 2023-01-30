class_name Actor
extends Node2D

@export var grid: Grid = preload("res://grid/Grid.tres")

@export var actor_data: ActorData = ActorData.new()


var energy_threshold: int = 5
var energy_level: int = 0 : set = set_energy

var gameboard: Game
var tilemap: TileMap = null
## Position

var cell: Vector2i = Vector2i(-1, -1) : set = set_cell
# Actions
var is_direction_input: Action = null





func _ready():
	set_cell(cell)

## Set cell
func set_cell(value: Vector2i) -> void:
	cell = grid.clamp_pos(value)
	global_position = grid.calculate_map_position(cell)

## Move to
func move_to_cell(new_cell: Vector2i) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", grid.calculate_map_position(new_cell), 0.05)
	await tween.finished
	set_cell(new_cell)


## Command pattern
func get_action() -> Action:
	var action: Action = null
	print("override get_action in %s" % self.name)
	
	return action

## Do hurting
func attack(defender: Actor) -> bool:
	play_attack_quote(get_subject_name(), defender.get_object_name())
	return defender.take_damage(get_damage())

## Get hurted
func take_damage(_damage: int) -> bool:
	var damaged: bool = false
	set_cur_hp(get_cur_hp() - _damage)
	damaged = true
	if get_cur_hp() <= 0:
		self.die()
	
	return damaged

## Teleport to random place when dead; placeholder
# replace this later
func die() -> void:
	play_death_quote()
	var cell: Cell = gameboard.get_cell(self.cell)
	cell.erase(self)
	set_cell(gameboard.find_empty_tile())
	cell = gameboard.get_cell(self.cell)
	cell.add(self)
	set_cur_hp(actor_data.max_hp)

# Set energy
func set_energy(value) -> void:
	energy_level = value

# Apply statuses; currently doesn't do anything
func apply_status() -> bool:
	var applied: bool = true
	print("applied status on %s" % get_object_name())
	return applied



func play_attack_quote(subj: String, obj: String) -> void:
	Events.add_event("%s attacked %s." % [subj, obj])

func play_death_quote() -> void:
	Events.add_event("%s died. Override this!" % get_subject_name())




func get_char_name() -> String:
	return actor_data.character_name

func set_max_hp(value: int) -> void:
	actor_data.max_hp = value

func get_max_hp() -> int:
	return actor_data.max_hp

func set_cur_hp(value: int) -> void:
	actor_data.cur_hp = value

func get_cur_hp() -> int:
	return actor_data.cur_hp

func get_damage() -> int:
	return actor_data.damage

func get_speed() -> int:
	return actor_data.speed

func get_flammable() -> bool:
	return actor_data.is_flammable





func get_subject_name() -> String:
	return "The %s" % get_char_name().to_lower()

func get_object_name() -> String:
	return ("the %s" % get_char_name()).to_lower()
