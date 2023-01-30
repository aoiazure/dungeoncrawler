class_name Cell
extends Node

var game: Game
var cell: Vector2i = Vector2i(-1, -1)
var tile: Architect.Tiles = Architect.Tiles.EMPTY

var is_visible: bool = false

var occupants: Array

# Set up the occupants
func _init(_game: Game, _cell: Vector2i, _atlas_coords: Vector2i, _occupants: Array = []):
	game = _game
	cell = _cell
	occupants = _occupants
	## Tile Atlas Coords
	tile = Architect.convert_atlas_to_tile_enum(_atlas_coords)


# Add a reference to an object to the cell
func add(object: Object) -> void:
	occupants.append(object)

# Remove an object reference from being in this cell
func erase(object: Object) -> void:
	occupants.erase(object)

# Check if a specific object exists in the cell
func has(object: Object) -> bool:
	return occupants.has(object)

# Return index of object in cell, -1 if not found.
func find(object: Object) -> int:
	return occupants.find(object)

# Return if there is an Actor in the cell
func has_actor() -> bool:
	var _has_actor: bool = false
	for o in occupants:
		if o == null:
			continue
		if o is Actor:
			_has_actor = true
	return _has_actor

# Return if there is an Entity in the cell
func has_entity() -> bool:
	var _has_entity: bool = false
	for o in occupants:
		if o == null:
			continue
		if o is Entity:
			_has_entity = true
	return _has_entity

func get_actor() -> Actor:
	var actor: Actor
	var all: Array = get_all_actors()
	if all.size() > 0:
		actor = all.pop_front()
	return actor

# Return array of all actors in Cell
func get_all_actors() -> Array:
	var actors: Array = []
	for o in occupants:
		if o == null:
			continue
		if o is Actor:
			actors.append(o)
	return actors

# Return array of all entities in Cell
func get_all_entities() -> Array:
	var entities: Array = []
	for o in occupants:
		if o == null:
			continue
		if o is Entity:
			entities.append(o)
	return entities

# Return array of all actors and all entities, with actor priority
func get_all_actors_and_entities() -> Array:
	var all: Array = []
	all.append_array(get_all_actors())
	all.append_array(get_all_entities())
	return all


# Set the tile.
func set_tile(_tile: Architect.Tiles) -> void:
	tile = _tile

# Return array of all neighboring cells
func get_adjacent_cells() -> Array:
	var cells:= []
	for dir in Architect.DIRECTIONS:
		var new_coord: Vector2i = self.cell + dir
		var _cell: Cell = game.get_cell(new_coord)
		if _cell != null:
			cells.append(_cell)
	
	return cells



# Returns if Cell is visible
func get_is_visible() -> bool:
	return is_visible
# Set cell visibility
func set_is_visible(vis: bool) -> void:
	is_visible = vis



# Return true if the cell is unwalkable or if there is an Actor or Entity that obstructs movement
func is_occupied() -> bool:
	return is_occupied_movement() or is_occupied_pathfinding()

# Returns true if an actor or entity that obstructs movement is in this tile
func is_occupied_movement() -> bool:
	if occupants.size() == 0:
		return false
	var occupied: bool = false
	for o in occupants:
		if o == null:
			continue
		if o is Entity:
			if (o as Entity).is_obstacle:
				occupied = true
				break
		elif o is Actor:
			occupied = true
			break
	
	return occupied

# Returns true if the tile is never walkable
func is_occupied_pathfinding() -> bool:
	var occupied: bool = false
	match tile:
		Architect.Tiles.EMPTY, Architect.Tiles.WALL:
			occupied = true
	
	return occupied
