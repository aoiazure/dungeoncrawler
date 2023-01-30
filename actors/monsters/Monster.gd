class_name Monster
extends Actor

var pathfinder: Pathfinder

var target_point: Vector2i = Vector2i(-1, -1)
var path: PackedVector2Array = PackedVector2Array()

## Create and run astar on the gameworld
func init_astar(game: Game, _map: TileMap) -> void:
	# For occupation checking
	gameboard = game
	# get map ref
	tilemap = _map
	# Setup astar
	pathfinder = Pathfinder.new(game, grid, tilemap, self.cell)
	# if you have no target, then just reset the path
	if target_point == Vector2i(-1, -1):
		path = PackedVector2Array()


## Command pattern
func get_action() -> Action:
	init_astar(gameboard, tilemap)
	var action: Action
	
	# If no path to work on, generate a path to work on
	if path.size() == 0:
		while true:
			randomize()
			target_point = Vector2i(randi_range(0, grid.size.x), randi_range(0, grid.size.y))
			if pathfinder._astar.has_point(grid.as_index(target_point)):
				path = pathfinder.calculate_point_path(self.cell, target_point)
#				print("Moving from %s to %s via %s" % [self.cell, target_point, path])
				break
	
	# Otherwise, work on the current path
	else:
		# Remove the first point since thats always the current cell you're in
		path = pathfinder.calculate_point_path(self.cell, target_point).slice(1)
		# if doing so means the path is now empty, then we're at the destination, so restart
		if path.size() == 0:
			print("%s's destination reached" % self.name)
			return action
		
		# Otherwise, get the next point
		var next_point: Vector2i = path[0]
		# Get the relative direction, and return the appropriate action
		var dir: Vector2i = next_point - self.cell
		match dir:
			Vector2i.LEFT:
				action = ActionMove.new(gameboard, Vector2i.LEFT)
			Vector2i.RIGHT:
				action = ActionMove.new(gameboard, Vector2i.RIGHT)
			Vector2i.UP:
				action = ActionMove.new(gameboard, Vector2i.UP)
			Vector2i.DOWN:
				action = ActionMove.new(gameboard, Vector2i.DOWN)
			Vector2i(-1, -1):
				action = ActionMove.new(gameboard, Vector2i(-1, -1))
			Vector2i(-1, 1):
				action = ActionMove.new(gameboard, Vector2i(-1, 1))
			Vector2i(1, -1):
				action = ActionMove.new(gameboard, Vector2i(1, -1))
			Vector2i(1, 1):
				action = ActionMove.new(gameboard, Vector2i(1, 1))
	
	return action


