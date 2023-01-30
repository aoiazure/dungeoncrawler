class_name Fov
extends Node2D

@onready var grid: Grid = preload("res://grid/Grid.tres")
@onready var game: Game = get_parent()

func refresh(pos: Vector2i) -> void:
	for octant in range(8):
		print("\n===== %s =====\n" % octant) 
		var shadows: Array[Shadow] = refresh_octant(pos, octant)
		
		for s in shadows:
			print("%s->%s" %[s.start, s.end])
	
	# starting pos always visible
	game.remove_hide(pos)
	print(pos)





func refresh_octant(start: Vector2, octant: int, max_rows: int = 100) -> Array:
	var line = ShadowLine.new()
	var full_shadow: bool = false
	
	# Move through rows
	for row in range(max_rows):
		## Stop if we're out of range
		if not grid.is_within_bounds(start + transform_octant(row, 0, octant)): 
			break
		
		for col in range(1+row):
			var pos: Vector2 = start + transform_octant(row, col, octant)
			
			# If we're out of bounds now, stop this loop
			if not grid.is_within_bounds(pos):
				break
			
			# If we already know the entire row is in shadow, hide it 
			if full_shadow:
				game.place_hide(pos)
			else:
				var projection: Shadow = project_tile(row, col)
				var vis: bool = not line.is_in_shadow(projection)
				print("%s is %s" % [pos, vis])
				# Set visibility of tile
				game.remove_hide(pos) if vis else game.place_hide(pos)
				
				# Add opaque tiles to shadow map
				if (vis and game.get_cell(pos).is_occupied_pathfinding()):
					line.add(projection)
					full_shadow = line.is_full_shadow()
			
	
	return line._shadows


func transform_octant(row: int, col: int, octant: int) -> Vector2:
	var vec: Vector2
	match (octant):
		0: return Vector2( col, -row)
		1: return Vector2( row, -col)
		2: return Vector2( row,  col)
		3: return Vector2( col,  row)
		4: return Vector2(-col,  row)
		5: return Vector2(-row,  col)
		6: return Vector2(-row, -col)
		7: return Vector2(-col, -row)
	return vec


#	Creates a [Shadow] that corresponds to the projected silhouette of the
#	given tile. This is used both to determine visibility (if any of the
#	projection is visible, the tile is) and to add the tile to the shadow map.
#	
#	The maximal projection of a square is always from the two opposing
#	corners. From the perspective of octant zero, we know the square is
#	above and to the right of the viewpoint, so it will be the top left and
#	bottom right corners.
func project_tile(row: int, col: int) -> Shadow:
	var top_left = col / (row + 2);
	var bottom_right = (col + 1) / (row + 1)
	return Shadow.new(top_left, bottom_right, Vector2(col, row+2), Vector2(col+1, row+1))


