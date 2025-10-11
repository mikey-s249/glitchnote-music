extends Area2D
class_name TileRay

enum Direction{VERTICAL, HORIZONTAL}

var direction: Direction


#func _init(direction_p: Direction):
	#direction = direction_p

func set_direction(direction_p: Direction):
	direction = direction_p

func _ready() -> void:
	var screen_size = get_viewport().content_scale_size
		
		#$Collision.shape.size = Vector2(20, 2000)
	if direction == Direction.HORIZONTAL:
		rotation_degrees = 90
		#$Collision.shape.size = Vector2(2000, 20)


func _on_timer_timeout() -> void:
	queue_free()
