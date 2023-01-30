extends Node

signal event(event_text)

## Add an event to the console
func add_event(event_text: String) -> void:
	if len(event_text) == 0:
		return
	emit_signal("event", event_text)




