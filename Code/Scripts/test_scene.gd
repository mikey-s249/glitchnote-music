extends Node2D





func _on_timer_timeout() -> void:
	for child in $Buttons.get_children():
		child.timer_timeout()
