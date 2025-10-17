extends Area2D

@export var block_id : int = 0;

signal block_selected(block_id : int);



func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		block_selected.emit(block_id);
