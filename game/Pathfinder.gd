## Thanks to GDQuest for most of this!

class_name Pathfinder
extends Node

# We will use this constant in "for" loops later. It defines the directions in which we allow a unit
# to move in the game: up, left, right, down.
const DIRECTIONS = [
	Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
	Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1), 
]

# Check stuff
var gameboard: Game
var tilemap: TileMap

var _grid: Grid
# This variable holds an AStar2D instance that will do the actual pathfinding. Our script is mostly
# here to initialize that object.
var _astar := AStar2D.new()


# Initializes the Astar2D object upon creation.
func _init(game: Game, grid: Grid, _tilemap: TileMap, own_cell: Vector2i) -> void:
	gameboard = game
	tilemap = _tilemap
	
	# Because we will instantiate the `PathFinder` from our UnitPath's script, we pass it the data it
	# needs to initialize itself via its constructor function, _init().
	_grid = grid
	# To create our AStar graph, we will need the index value corresponding to each grid cell. Here,
	# we cache a mapping between cell coordinates and their unique index. Doing so here slightly
	# simplifies the code and improves performance a bit.
	var cell_mappings: Dictionary = {}
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			var coords: Vector2i = Vector2i(x, y)
			
			# if it's not occupied and is usable
			if is_valid_tile_for_pathfind(game, coords):
				# For each cell, we define a key-value pair of cell coordinates: index.
				cell_mappings[coords] = _grid.as_index(coords)
	## Always add own coord
	cell_mappings[own_cell] = _grid.as_index(own_cell)
	# We then add all the cells to our AStar2D instance and connect them to create our pathfinding graph.
	_add_and_connect_points(cell_mappings)


# Returns the path found between `start` and `end` as an array of Vector2 coordinates.
func calculate_point_path(start: Vector2i, end: Vector2i) -> PackedVector2Array:
	# With the AStar algorithm, we have to use the points' indices to get a path. This is why we
	# need a reliable way to calculate an index given some input coordinates.
	# Our Grid.as_index() method does just that.
	var start_index: int = _grid.as_index(start)
	var end_index: int = _grid.as_index(end)
	# We just ensure that the AStar graph has both points defined. If not, we return an empty
	# PoolVector2Array() to avoid errors.
	if _astar.has_point(start_index) and _astar.has_point(end_index):
		# The AStar2D object then finds the best path between the two indices.
		return _astar.get_point_path(start_index, end_index)
	else:
		return PackedVector2Array()


# Adds and connects the walkable cells to the Astar2D object.
func _add_and_connect_points(cell_mappings: Dictionary) -> void:
	# This function works with two loops. First, we register all our points in the AStar graph.
	# We pass each cell's unique index and the corresponding Vector2 coordinates to the
	# AStar2D.add_point() function.
	for point in cell_mappings:
		var weight_scale: float = _calculate_weight_of_coords(point)
		_astar.add_point(cell_mappings[point], point, weight_scale)
	
	# Then, we loop over the points again, and we connect them with all their neighbors. We use
	# another function to find the neighbors given a cell's coordinates.
	for point in cell_mappings:
		for neighbor_index in _find_neighbor_indices(point, cell_mappings):
			# The AStar2D.connect_points() function connects two points on the graph by index, *not*
			# by coordinates.
			_astar.connect_points(cell_mappings[point], neighbor_index)


# Returns an array of the `cell`'s connectable neighbors.
func _find_neighbor_indices(cell: Vector2i, cell_mappings: Dictionary) -> Array:
	var out := []
	# To find the neighbors, we try to move one cell in every possible direction and is ensure that
	# this cell is walkable and not already connected.
	for direction in DIRECTIONS:
		var neighbor: Vector2i = cell + direction
		# This line ensures that the neighboring cell is part of our walkable cells.
		if not cell_mappings.has(neighbor):
			continue
		# Because we call the function for every cell, we will get neighbors that are already
		# connected. If you don't don't check for existing connections, you'll get many errors.
		if not _astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbor]):
			out.push_back(cell_mappings[neighbor])
	return out


#
func is_valid_tile_for_pathfind(game: Game, coords: Vector2) -> bool:
	return not game.get_cell(coords).is_occupied_pathfinding()

# 
func _calculate_weight_of_coords(coords: Vector2) -> float:
	var weight: float = 1.0
	# if in occupied, its either an actor or an entity
	if gameboard.is_occupied(coords):
		var cell: Cell = gameboard.get_cell(coords)
		var obj = cell.get_all_entities()
		if obj is Entity:
			weight = max(weight, obj.weight)
	
	return weight








