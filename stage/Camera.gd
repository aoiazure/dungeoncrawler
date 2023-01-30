extends Camera2D

const MOVE_DISTANCE: float = 16
const ZOOM_DISTANCE: float = 0.2

var target: Node2D

func _process(_delta):
	if target != null:
		self.global_position = lerp(global_position, target.global_position, 0.1)



func _unhandled_input(event):
	if event.is_action_pressed("move_left"):
		global_position.x -= MOVE_DISTANCE
	if event.is_action_pressed("move_right"):
		global_position.x += MOVE_DISTANCE
	if event.is_action_pressed("move_up"):
		global_position.y -= MOVE_DISTANCE
	if event.is_action_pressed("move_down"):
		global_position.y += MOVE_DISTANCE
	if event.is_action_pressed("move_up_left"):
		global_position += Vector2(-MOVE_DISTANCE, -MOVE_DISTANCE)
	if event.is_action_pressed("move_up_right"):
		global_position += Vector2(MOVE_DISTANCE, -MOVE_DISTANCE)
	if event.is_action_pressed("move_down_left"):
		global_position += Vector2(-MOVE_DISTANCE, MOVE_DISTANCE)
	if event.is_action_pressed("move_down_right"):
		global_position += Vector2(MOVE_DISTANCE, MOVE_DISTANCE)
	
	if event.is_action_pressed("camera_zoom_in"):
		self.zoom += Vector2(ZOOM_DISTANCE, ZOOM_DISTANCE)
	if event.is_action_pressed("camera_zoom_out"):
		self.zoom -= Vector2(ZOOM_DISTANCE, ZOOM_DISTANCE)
	
	self.zoom.x = clamp(self.zoom.x, 0.2, 2.2)
	self.zoom.y = clamp(self.zoom.y, 0.2, 2.2)

