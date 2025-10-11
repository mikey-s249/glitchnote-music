extends Sprite2D
class_name Tiles

var playing = false
var num_timeouts = 0
var can_lose = false

# Keeps track of how many times the global clock has reset so the music all plays in sync
var clock_cycle = 0

@export var tile_color: Color

# Need to completely overhall this script, it is a mess
# The sound doesn't end in sync with the tile changing
# Ready state needs own colour
# Need to work out when song resets
# Right now it resets upon every time a tile is activated
# Maybe have a "next stream" variable



enum TileState{PLAYING, IDLE, LOSING, READY}

var state: TileState = TileState.IDLE



var next_sound: AudioStream

@export var type: Sounds.Type = Sounds.Type.BASS

var idle_colour = Color("FFFFFF")
var playing_colour = Color("ff2996")
var losing_colour = Color("ff0000")
var ready_colour = Color("00ff00")
var new_track_ready = false

var type_name: String

signal lose_game

func _ready() -> void:
	$Sound.stream = get_parent().get_new_melody(type)
	next_sound = get_parent().get_new_melody(type)
	#print($Sound.stream.)
	#$Sound.stream = sound
	var new_gradient_texture: GradientTexture1D = GradientTexture1D.new()
	var new_gradient: Gradient = Gradient.new()
	new_gradient.remove_point(1)
	new_gradient.set_color(0, tile_color)
	new_gradient.set_offset(0, 0.5)
	#new_gradient.add_point(-1.0, inactive_colour)
	new_gradient.add_point(0.5, idle_colour)
	new_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	
	#new_gradient.set_offset(0, -1)
	new_gradient_texture.gradient = new_gradient
	texture = new_gradient_texture
	$Timer.wait_time = clamp(get_length() * 8, 32, 64)
	$NewSongTimer.wait_time = 2 * $Timer.wait_time
	match type:
		Sounds.Type.BASS:
			type_name = "Bass"
		Sounds.Type.CHORDS:
			type_name = "Chords"
		Sounds.Type.HIGH_HATS:
			type_name = "High Hats"
		Sounds.Type.DRUMS:
			type_name = "Kick Snare"
		Sounds.Type.MELODY:
			type_name = "Melody"
		Sounds.Type.COUNTER_MELODY:
			type_name = "Counter Melody"
#func _process(delta: float) -> void:
	#
	#if state == TileState.PLAYING:
		#var frac = ($Timer.wait_time - $Timer.time_left) / $Timer.wait_time
		##var colour = lerp(active_colour, inactive_colour, frac)
		#texture.gradient.set_offset(1, frac+0.001)
	#elif state == TileState.LOSING:
		#var frac = ($LoseTimer.wait_time - $LoseTimer.time_left) / $LoseTimer.wait_time
		#texture.gradient.set_offset(1, 1-frac-0.001)


func resolve_colour():
	if state == TileState.IDLE:
		texture.gradient.set_color(0, tile_color)
		texture.gradient.set_color(1, idle_colour)
		#texture.gradient.set_offset(1, 1.0)
	elif state == TileState.READY:
		texture.gradient.set_color(1, ready_colour)
		#texture.gradient.set_offset(1, 1.0)
	elif state == TileState.PLAYING:
		#texture.gradient.set_color(0, tile_color)
		texture.gradient.set_color(1, playing_colour)
	elif state == TileState.LOSING:
		#texture.gradient.set_color(0, tile_color)
		texture.gradient.set_color(1, losing_colour)
		


# Checks which cycle the clock is on to ensure that everything is synced
func check_cycle(length=get_length()):
	if length == 2.0 || length == 4.0:
		return true
	elif length == 8.0:
		if clock_cycle == 1 || clock_cycle == 3:
			return true
	elif length == 16.0:
		if clock_cycle == 3:
			return true
	return false




func clock_timeout() -> void:
	clock_cycle += 1
	clock_cycle %=4
	if state == TileState.IDLE:
		if can_lose:
			state = TileState.LOSING
			start_lose_timer()
	
	if state == TileState.READY:
		
		if new_track_ready:
			if check_cycle(max(get_length(), next_sound.get_length())):
				new_track_ready = false
				get_new_track()
				$Sound.play()
				$Timer.start()
				$NewSongTimer.start()
				state = TileState.PLAYING
		else:
			if check_cycle():
				if ! $Sound.playing:
					$Sound.play()
				$Timer.start()
				if $NewSongTimer.is_stopped():
					$NewSongTimer.start()
				state = TileState.PLAYING
	resolve_colour()

# Function that returns the decimal showing how far through the timer we are
func get_frac():
	var frac
	if state == TileState.PLAYING:
		frac = ($Timer.wait_time - $Timer.time_left) / $Timer.wait_time
	elif state == TileState.LOSING:
		frac = ($LoseTimer.wait_time - $LoseTimer.time_left) / $LoseTimer.wait_time
	return frac


func start_track():
	if $Timer.is_stopped():
		$Timer.start()
	if ! $Sound.playing:
		$Sound.play()


func get_length():
	return $Sound.stream.get_length()

func _on_area_2d_area_entered(area: Area2D) -> void:
	state = TileState.READY
	resolve_colour()
	#texture.gradient.set_offset(1, 0)
	#texture.gradient.set_color(1, active_colour)
	$LoseTimer.stop()


func start_lose_timer():
	if $LoseTimer.is_stopped() and can_lose:
		$LoseTimer.start()

func _on_timer_timeout() -> void:
	$Sound.stop()
	if can_lose:
		state = TileState.LOSING
		start_lose_timer()
	else:
		state = TileState.IDLE
	resolve_colour()

# May need to duplicate the assignment below so that it isn't referencing it


func get_new_track():
	$Sound.stream = next_sound
	next_sound = get_parent().get_new_melody(type)
	$Timer.wait_time = clamp(get_length() * 8, 32, 64)
	


func _on_lose_timer_timeout() -> void:
	lose_game.emit()


func _on_new_song_timer_timeout() -> void:
	new_track_ready = true
