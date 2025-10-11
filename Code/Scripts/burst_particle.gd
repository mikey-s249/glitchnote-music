extends Node2D


func start():
	$Particle1.restart()
	$Particle2.restart()

func rotate_particles(degrees):
	rotation_degrees = degrees
	$Particle1.angle_min = degrees
	$Particle1.angle_max = degrees
	$Particle2.angle_min = degrees
	$Particle2.angle_max = degrees
	
func _on_cpu_particles_2d_finished() -> void:
	queue_free()
