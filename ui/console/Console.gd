class_name Console
extends ScrollContainer

@export var max_size: int = 20
@onready var container: VBoxContainer = $Container

var event_label := preload("res://ui/console/EventLabel.tscn")

func _ready():
	# Connect to Event
	Events.connect("event", add_event)


## Console
func add_event(event: String) -> void:
	var children = container.get_children()
	if children.size() >= max_size:
		container.get_children()[-1].queue_free()
	
	var label: Label = event_label.instantiate()
	container.add_child(label)
	container.move_child(label, 0)
	
	label.text = " " + event
	var label_settings: LabelSettings = LabelSettings.new()
	label.label_settings = label_settings
	label_settings.line_spacing = 3
	label_settings.font_size = 24
	
	scroll_vertical = 0
	children = container.get_children()
	for l in children:
		var idx: int = children.find(l)
		var num: float = (1.0 - (float(idx)/children.size()))
		var c: Color = Color(1.0, 1.0, 1.0, num)
		(l as Label).label_settings.font_color = c
