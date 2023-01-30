class_name Architect
extends Node2D


@export var grid: Grid = preload("res://grid/Grid.tres")

enum { KEEP, REMOVE, REPLACE }
enum Tiles { EMPTY, FLOOR, DIRT, GRASS, TREE, WATER, WALL, DOOR }
enum Structure { ROOM, HALL }

const ORDINALS = [
	Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
]
const DIRECTIONS = [
	Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
	Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1), 
]

## Tile Atlas Coords
const TILE_EMPTY: Vector2i = Vector2i(0, 0)
const TILE_FLOOR: Vector2i = Vector2i(1, 0)
const TILE_WALL : Vector2i = Vector2i(2, 0)
const TILE_DIRT : Vector2i = Vector2i(0, 1)
const TILE_GRASS: Vector2i = Vector2i(0, 2)
const TILE_TREE : Vector2i = Vector2i(1, 3)
const TILE_WATER_LIGHT : Vector2i = Vector2i(2, 1)
const TILE_DOOR : Vector2i = Vector2i(2, 2)

var tilemap: TileMap
var texture: NoiseTexture2D

## Set up
func _ready():
	tilemap = get_parent().find_child("TileMap")


## Shitty, basic hard rng
func generate_simple_world() -> void:
	tilemap.clear()
	# rng
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	await create_basic_noise_map()
	var noise: Noise = texture.noise
	
	var max: float = -INF
	var min: float = INF
	var avg: float = 0.0
	
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			var wx: int = texture.width * (x/grid.size.x)
			var wy: int = texture.width * (y/grid.size.y)
			var value: float = noise.get_noise_2d(wx, wy)
			
			var coords := Vector2i(x, y)
			
			if value > 0.55:
				place_tree(coords)
			elif value > 0.32:
				place_grass(coords)
			elif value > -0.05:
				place_dirt(coords)
			elif value > -0.3:
				place_floor(coords)
			else:
				place_water(coords)
			
			# Stats
			if value > max:
				max = value
			elif value < min:
				min = value
			avg += value
	
	# Stats
	avg = avg/920
	print("Max: %s, Avg: %s, Min: %s" % [max,avg, min])


## Generate world with better smoothing and realism
func generate_world(smooth: bool = false, specific_seed: int = -1) -> void:
	tilemap.clear()
	# rng
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	create_noise_map(512, FastNoiseLite.NoiseType.TYPE_VALUE, 0.02, specific_seed)
	var noise: Noise = texture.noise
	
	
	
	# Initialize tiles
	var tiles: Dictionary = {}
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			# Traverse the noise texture proportionally to the grid
			# so you ALWAYS traverse the entire thing
			var wx: int = texture.width * (x/grid.size.x)
			var wy: int = texture.width * (y/grid.size.y)
			var value: float = noise.get_noise_2d(wx, wy)
			# The current coordinates
			var coords: Vector2i = Vector2i(x, y)
			
			# goes from -0.64 to 0.64 basically, so we set the gradient here
			if value > 0.55:
				tiles[coords] = Tiles.TREE
			elif value > 0.31:
				tiles[coords] = Tiles.GRASS
			elif value > -0.05:
				tiles[coords] = Tiles.DIRT
			elif value > -0.35:
				tiles[coords] = Tiles.FLOOR
			else:
				tiles[coords] = Tiles.WATER
	
	# If you're going to smooth it out
	if smooth:
		smooth_tile_of_type(tiles, Tiles.DIRT, Tiles.FLOOR)
		smooth_tile_of_type(tiles, Tiles.GRASS, Tiles.DIRT)
		# smooth X times
		for i in range(5):
			smooth_tile_of_type(tiles, Tiles.WATER, Tiles.FLOOR)
	
	# Draw the map
	draw_map(tiles)
	# Remove all the little puddles
	clear_small_water()




## Generate a very okay dungeon
func generate_dungeon(rooms_min: int = 3, rooms_max: int = 5, room_size_min: int = 5, room_size_max: int = 8, 
		specific_seed: int = -1) -> void:
	# prepopulate with all empties
	tilemap.clear()
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			var coords: Vector2i = Vector2i(x, y)
			place_empty(coords)
	
	var data: Dictionary = _generate_data(rooms_min, rooms_max, room_size_min, room_size_max)
	for cell in data.keys():
		place_floor(cell)
		for dir in DIRECTIONS:
			var new_cell: Vector2i = cell + dir
			if not new_cell in data:
				if not grid.is_within_bounds(new_cell):
					new_cell = grid.clamp_pos(new_cell)
				place_wall(new_cell)
	
	generate_doors(data)
	clear_double_doors(data)


func _generate_data(rooms_min: int = 3, rooms_max: int = 5, room_size_min: int = 5, room_size_max: int = 8) -> Dictionary:
	# rng
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	var data: Dictionary = {}
	var rooms := []
	
	var attempts: int = 0
	var placed: int = 0
	while placed < rooms_min or attempts < rooms_max:
		var room := _create_random_room(rng)
		attempts += 1
		# Failed
		if _intersects(rooms, room):
			continue
		placed += 1
		_add_room(data, rooms, room)
		if rooms.size() > 1:
			rng.randomize()
			var room_previous: Rect2 = rooms[rng.randi_range(0, rooms.size() - 2)]
			_add_connection(rng, data, room_previous, room)
	return data

## Create random sized room at a random position in the grid
func _create_random_room(rng: RandomNumberGenerator, room_size_min: int = 5, room_size_max: int = 8) -> Rect2:
	var width: int = rng.randi_range(room_size_min, room_size_max)
	var height: int = rng.randi_range(room_size_min, room_size_max)
	var x: int = rng.randi_range(0, grid.size.x - width - 1)
	var y: int = rng.randi_range(0, grid.size.y - height - 1)
	return Rect2(x, y, width, height)

## Add the room to data
func _add_room(data: Dictionary, rooms: Array, room: Rect2) -> void:
	rooms.push_back(room)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			var point := Vector2i(x, y)
			data[point] = Structure.ROOM

## 
func _add_connection(rng: RandomNumberGenerator, data: Dictionary, room1: Rect2, room2: Rect2) -> void:
	var room_center1 := room1.get_center() + Vector2(rng.randi_range(-2, 2), rng.randi_range(-2, 2))
	var room_center2 := room2.get_center() + Vector2(rng.randi_range(-2, 2), rng.randi_range(-2, 2))
	room_center1.x = clamp(room_center1.x, min(room1.position.x, room1.end.x), max(room1.position.x, room1.end.x))
	room_center1.y = clamp(room_center1.y, min(room1.position.y, room1.end.y), max(room1.position.y, room1.end.y))
	room_center2.x = clamp(room_center2.x, min(room2.position.x, room2.end.x), max(room2.position.x, room2.end.x))
	room_center2.y = clamp(room_center2.y, min(room2.position.y, room2.end.y), max(room2.position.y, room2.end.y))
	
	if rng.randi_range(0, 1) == 0:
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
	else:
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)

## Add corridor
func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
	var begin: int = min(start, end)
	var finish: int = max(start, end) + 1
	
	for t in range(begin, finish):
		var point := Vector2i.ZERO
		match axis:
			Vector2i.AXIS_X: 
				point = Vector2i(t, constant)
			Vector2i.AXIS_Y: 
				point = Vector2i(constant, t)
		if not data.has(point):
			data[point] = Structure.HALL


func generate_doors(data: Dictionary, place_chance: float = 0.4) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	var door_coords: Dictionary = {}
	for cell in data.keys():
#		var room_neighbors: int = 0
		var hall_neighbors: int = 0
		var vert_n: int = 0
		var horiz_n: int = 0
#		for dir in DIRECTIONS:
#			var new_cell: Vector2i = cell + dir
#			if new_cell in data:
#				if data[new_cell] == Structure.ROOM:
#					room_neighbors += 1
		
		for dir in ORDINALS:
			var new_cell: Vector2i = cell + dir
			if new_cell in data:
				if data[new_cell] == Structure.HALL:
					hall_neighbors += 1
			else:
				match dir:
					Vector2i.UP, Vector2i.DOWN: vert_n += 1
					Vector2i.LEFT, Vector2i.RIGHT: horiz_n += 1
		
		if (vert_n == 2 or horiz_n == 2) and hall_neighbors == 1:
			door_coords[cell] = Tiles.DOOR
	
	for coord in door_coords:
		rng.randomize()
		if rng.randf() > place_chance: continue
		for dir in ORDINALS:
			var new_coord: Vector2i = coord + dir
			if new_coord in door_coords:
				continue
		place_door(coord)

func clear_double_doors(data: Dictionary) -> void:
	for cell in data.keys():
		for dir in ORDINALS:
			var new_cell: Vector2i = cell + dir
			if new_cell in data:
				if tilemap.get_cell_atlas_coords(0, new_cell) == TILE_DOOR:
					place_floor(cell)
					break


## Check if the rooms overlap with any other
func _intersects(rooms: Array, room: Rect2) -> bool:
	var out := false
	for room_other in rooms:
		if room.intersects(room_other, true):
			out = true
			break
	return out







## Finally, raw the map of tiles
func draw_map(tiles: Dictionary) -> void:
	for coord in tiles.keys():
		match tiles[coord]:
			Tiles.TREE:
				place_tree(coord)
			Tiles.GRASS:
				place_grass(coord)
			Tiles.DIRT:
				place_dirt(coord)
			Tiles.FLOOR:
				place_floor(coord)
			Tiles.WATER:
				place_water(coord)
			Tiles.WALL:
				place_wall(coord)
			Tiles.DOOR:
				place_door(coord)

## Smooth out areas of a specific type, replacing as needed
func smooth_tile_of_type(tiles: Dictionary, _type: Tiles, replacement: Tiles) -> void:
	# Get the coords of all tiles of the specified type (that have yet to be placed)
	var type_tiles: PackedVector2Array = get_all_tiles_of_type_in_dict(tiles, _type)
	var source_id: int = 1
	
	
	var temp: Dictionary = tiles.duplicate()
	for cell in temp.keys():
		cell = (cell as Vector2)
		var same_type_neighbors: int = 0
		# For all its neighbors
		for dir in DIRECTIONS:
			var adj_coord: Vector2 = cell + dir
			# if its neighbor is the same type
			if type_tiles.has(adj_coord):
				same_type_neighbors += 1
		
		# Enough of type for threshold
		if same_type_neighbors >= 5:
			temp[cell] = REPLACE
		elif same_type_neighbors >= 3:
			temp[cell] = KEEP
		else:
			temp[cell] = REMOVE
	
	for tile in temp.keys():
		if temp[tile] == REPLACE:
			tiles[tile] = _type
		elif temp[tile] == REMOVE:
			if tilemap.get_cell_source_id(0, tile) == source_id:
				tiles[tile] = replacement
	pass


func get_all_tiles_of_type_in_dict(tiles: Dictionary, _type: Tiles) -> PackedVector2Array:
	var array: Array = []
	for cell in tiles.keys():
		if tiles[cell] == _type:
			array.append(cell)
	
	return PackedVector2Array(array)




## Remove all tiny splots of water that aren't helpful
func clear_small_water(threshold: int = 13) -> void:
	for t in tilemap.get_used_cells(0):
		var fill: PackedVector2Array = flood_fill(t, "water")
		if fill.size() != 0 and fill.size() < threshold:
			for c in fill:
				place_floor(c)

# Get all connected tiles at a coordinate of a specific type
func flood_fill(_coord: Vector2, _type: String) -> PackedVector2Array:
	var tile_type: String = get_tile_type_at_coord(_coord)
	if tile_type.to_lower() != _type:
		return PackedVector2Array([])
	
	# To be returned
	var area: PackedVector2Array
	# flood fill
	var flood_queue: Array = [ _coord ]
	var visited: Array = [ _coord ]
	while not flood_queue.is_empty():
		var coord: Vector2 = flood_queue.pop_front()
		for adj_coord in tilemap.get_surrounding_cells(coord):
			# If out of bounds, ignore it
			if not grid.is_within_bounds(adj_coord):
				continue
			# 
			if get_tile_type_at_coord(adj_coord) == tile_type and not visited.has(adj_coord):
				flood_queue.append(adj_coord)
				visited.append(adj_coord)
	area = PackedVector2Array(visited)
	return area


# Get Tile Type info at a specific coordinate
func get_tile_type_at_coord(coord: Vector2) -> String:
	if tilemap.get_cell_tile_data(0, coord):
		return tilemap.get_cell_tile_data(0, coord).get_custom_data("Tile Type")
	return ""


### Place stuff
func place_empty(coords: Vector2) -> void:
	tilemap.set_cell(0, coords, 0, TILE_EMPTY)

func place_floor(coords: Vector2) -> void:
	tilemap.set_cell(0, coords, 0, TILE_FLOOR)

func place_dirt(coords: Vector2) -> void:
	tilemap.set_cell(0, coords, 0, TILE_DIRT)

func place_grass(coords: Vector2) -> void:
	tilemap.set_cell(0, coords, 0, TILE_GRASS)

func place_tree(coords: Vector2) -> void:
	tilemap.set_cell(0, coords, 0, TILE_TREE)

func place_water(coords: Vector2) -> void:
	tilemap.set_cell(0, coords, 0, TILE_WATER_LIGHT)

func place_wall(coords: Vector2) -> void: 
	tilemap.set_cell(0, coords, 0, TILE_WALL)

func place_door(coords: Vector2) -> void:
	tilemap.set_cell(0, coords, 0, TILE_DOOR)



## Create a noise map on the fly
func create_noise_map(width: int = 512, 
		noise_type: FastNoiseLite.NoiseType = FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH, 
		frequency: float = 0.01,
		specific_seed: int = -1) -> void:
	
	texture = NoiseTexture2D.new()
	texture.noise = FastNoiseLite.new()
	texture.width = width
	# Set specific seed
	if specific_seed != -1:
		texture.noise.seed = specific_seed
	else:
		texture.noise.seed = randi()
	print(texture.noise.seed)
	
	var noise: Noise = texture.noise
	noise.noise_type = noise_type
	noise.frequency = frequency
	await texture.changed

## Very basic noise map, no customizing
func create_basic_noise_map() -> void:
	create_noise_map(512, FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH, 0.01)

static func convert_atlas_to_tile_enum(_atlas_coords: Vector2i) -> Tiles:
	var tile: Tiles = Tiles.EMPTY
	match _atlas_coords:
		TILE_FLOOR:
			tile = Tiles.FLOOR
		TILE_WALL :
			tile = Tiles.WALL
		TILE_DIRT :
			tile = Tiles.DIRT
		TILE_GRASS:
			tile = Tiles.GRASS
		TILE_TREE :
			tile = Tiles.TREE
		TILE_WATER_LIGHT:
			tile = Tiles.WATER
		TILE_DOOR :
			tile = Tiles.DOOR
	
	return tile







## Basically just for testing purposes
func smooth_tile_at_point(cell: Vector2, 
		_type: Tiles = Tiles.WATER, _replacement: Tiles = Tiles.FLOOR) -> void:
	
	var type_tiles: PackedVector2Array 
	match _type:
		Tiles.FLOOR:
			type_tiles = PackedVector2Array(tilemap.get_used_cells_by_id(0, 0, TILE_FLOOR))
		Tiles.DIRT:
			type_tiles = PackedVector2Array(tilemap.get_used_cells_by_id(0, 0, TILE_DIRT))
		Tiles.GRASS:
			type_tiles = PackedVector2Array(tilemap.get_used_cells_by_id(0, 0, TILE_GRASS))
		Tiles.TREE:
			type_tiles = PackedVector2Array(tilemap.get_used_cells_by_id(0, 0, TILE_TREE))
		Tiles.WATER:
			type_tiles = PackedVector2Array(tilemap.get_used_cells_by_id(0, 0, TILE_WATER_LIGHT))
		Tiles.WALL:
			type_tiles = PackedVector2Array(tilemap.get_used_cells_by_id(0, 0, TILE_WALL))
	
	var same_type_neighbors: int = 0
	# For all its neighbors
	for dir in DIRECTIONS:
		var adj_coord: Vector2 = cell + dir
		# if its neighbor is the same type
		if type_tiles.has(adj_coord):
			same_type_neighbors += 1
	
	# Enough water for threshold
	if same_type_neighbors >= 4:
		place_water(cell)
	elif same_type_neighbors < 3:
		place_floor(cell)

