class_name Game
extends Node

## Grid
@export var grid: Grid = preload("res://grid/Grid.tres")

## TileMap
@onready var camera: Camera2D = $Camera

@onready var tilemap: TileMap = $TileMap
@onready var hidemap: TileMap = $HideMap

@onready var architect: Architect = $Architect

@onready var actor_holder: Node2D = $Actors
@onready var entity_holder: Node2D = $Entities



var player: Player

var still_playing: bool = true

var actors: Array = []
var _current_actor: int = 0

var _cells: Dictionary = {}

var _mrpas: MRPAS


## Set up necessities
func _ready():
	create_gamespace(3, 15)
	pass



func create_gamespace(rooms_min: int = 3, rooms_max: int = 5) -> void:
	# Wipe all Cells
	_cells.clear()
	camera.target = null
	clear_actors()
	_current_actor = 0
	
	camera.limit_right = grid.size.x * grid.cell_size.x
	camera.limit_bottom = grid.size.y * grid.cell_size.y
	# Generate world
	(architect as Architect).generate_dungeon(rooms_min, rooms_max)
#	(architect as Architect).generate_world(false)
	create_cells()
	
	create_objects()
	
	create_actor(ActorPaths.PLAYER, find_empty_tile())
	create_actor(ActorPaths.MONSTER, find_empty_tile())
	
	player = get_node("Actors/Player")
	camera.target = player
	# Create and reiterate on fov
	_populate_mrpas()
	_compute_field_of_view()


func clear_actors() -> void:
	actors.clear()
	camera.target = null
	for a in actor_holder.get_children():
		a.queue_free()

func _populate_mrpas() -> void:
	_mrpas = MRPAS.new()
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			var coord:= Vector2i(x, y)
			var cell: Cell = get_cell(coord)
			if coord == player.cell:
				_mrpas.set_transparent(coord, true)
				continue
			_mrpas.set_transparent(coord, not cell.is_occupied())

func _compute_field_of_view() -> void:
	# wipe, restart
	_mrpas.clear_field_of_view()
	
	_mrpas.compute_field_of_view(player.cell, max(grid.size.x, grid.size.y) as int)
	
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			var coord:= Vector2(x, y)
			# Set visibility of tile
			remove_hide(coord) if _mrpas.is_in_view(coord) else place_hide(coord)



## Gameloop
func _process(_delta):
	set_process(false)
	_current_actor = (_current_actor) % actors.size()
	# Get current actor
	var actor: Actor = actors[_current_actor]
	# Implementation of Speed from Bob Nystrom's turn-based gameloop
	# Check if enough energy to act, if not, just skip to next character
	if actor.energy_level < actor.energy_threshold:
		if actor.get_speed() > 0:
			actor.energy_level += actor.get_speed()
	# Otherwise they have enough energy, so continue
	else:
		# Get action of the current actor
		var action: Action = actor.get_action()
		# If no action received, return and continue to await it
		if not action:
			set_process(true)
			return
		
		# Try to do an action that was received until it works
		while (true):
			# The result of the action
			@warning_ignore("redundant_await")
			var result: ResultAction = await action.execute(actor)
			# If it doesn't succeed, return and await a valid action
			if not result.success:
				set_process(true)
				return
			
			# If moved, update Cells
			if result.old_cell != result.new_cell:
				var old_cell: Cell = get_cell(result.old_cell)
				var new_cell: Cell = get_cell(result.new_cell)
				old_cell.erase(actor)
				new_cell.add(actor)
			
			# Then if there is an alternative, cascade into it more
			if result.alternative != null:
				action = result.alternative
				continue
			
			break
	
	# Actor done, loop to the next actor cyclically
	_current_actor = (_current_actor + 1) % actors.size()
	# update vis
	_populate_mrpas()
	_compute_field_of_view()
	set_process(true)



## Create actor
func create_actor(actor: String, grid_pos: Vector2i) -> ResultCreate:
#	if is_occupied(grid_pos):
#		print("failed to make actor: area already has actor")
#		return ResultCreate.new(false, null)
	# Make exist
	var a: Actor = load(actor).instantiate()
	actor_holder.add_child(a)
	a.set_cell(grid_pos)
	a.gameboard = self
	a.tilemap = tilemap
	
	# Keep record if it has turns
	if a.get_speed() > 0:
		actors.append(a)
	
	# Add to its Cell
	var cell: Cell = get_cell(grid_pos)
	cell.add(a)
	# also set up astar
	if a is Monster:
		(a as Monster).init_astar(self, tilemap)
	
	if a is Entity:
		pass
	# succeeded
	return ResultCreate.new(true, a)







# Initialize the entire grid with Cell structures
func create_cells() -> void:
	# For each y in the grid size and for each x:
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			# Get the coordinates
			var coords: Vector2i = Vector2i(x, y)
			var t: Vector2i = tilemap.get_cell_atlas_coords(0, coords)
			# Initalize Cell structure. This holds everything that is in it.
			var cell: Cell = Cell.new(self, coords, t)
			_cells[coords] = cell


# Get the `Cell` structure at the specific coordinate
func get_cell(coords: Vector2i) -> Cell:
	var cell: Cell = null
	if _cells.has(coords):
		cell = _cells[coords]
	return cell







## Check if spot is occupied
func is_occupied(cell: Vector2i) -> bool:
	var occupied: bool
	var _cell: Cell = get_cell(cell)
	if _cell:
		occupied = _cell.is_occupied()
	return occupied




## Find random empty tile in world
func find_empty_tile() -> Vector2i:
	var point: Vector2i
	while true:
		randomize()
		@warning_ignore("narrowing_conversion")
		point = Vector2i(randi_range(0, grid.size.x), randi_range(0, grid.size.y))
		if not is_occupied(point) and grid.is_within_bounds(point):
			break
	return point


# Spawn doors
func create_objects() -> void:
	for y in range(grid.size.y):
		for x in range(grid.size.x):
			var coords: Vector2i = Vector2i(x, y)
			# Objects
			var atlas_coords: Vector2i = tilemap.get_cell_atlas_coords(0, coords)
			match atlas_coords:
				Architect.TILE_DOOR:
					create_actor(ActorPaths.DOOR, coords)
				Architect.TILE_TREE:
					architect.place_grass(coords)
					get_cell(coords).tile = Architect.Tiles.GRASS
					create_actor(ActorPaths.TREE, coords)



func place_hide(coords: Vector2i) -> void:
	hidemap.set_cell(0, coords, 0, Vector2i(3, 0))

func remove_hide(coords: Vector2i) -> void:
	hidemap.erase_cell(0, coords)

