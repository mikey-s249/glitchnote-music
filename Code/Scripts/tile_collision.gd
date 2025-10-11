extends Sprite2D


#var colour_change = false

func _ready() -> void:
	#texture.gradient.
	pass

#
#func _process(delta: float) -> void:
	#if colour_change:
		#texture.gradient.set_color(0, lerp(texture.gradient.get_color(0), Color("c801f3"), delta * 0.5))
#

func _on_area_2d_area_entered(area: Area2D) -> void:
	get_parent().playing = true
	var new_gradient_texture: GradientTexture1D = GradientTexture1D.new()
	var new_gradient: Gradient = Gradient.new()
	new_gradient.set_color(0, Color("c801f3"))
	new_gradient.remove_point(1)
	new_gradient_texture.gradient = new_gradient
	#new_gradient.gradient.colors = PackedColorArray([Color("c801f3")])
	#new_gradient.gradient.offsets = [0.0]

	texture = new_gradient_texture
	#colour_change = true
	
