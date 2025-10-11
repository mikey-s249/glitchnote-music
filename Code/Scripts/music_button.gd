extends Node2D



@export var sound: AudioStream
@export var volume: float

var playing = false

func _ready() -> void:
	
	$Sound.volume_db = volume
	$Label.text = sound.resource_path.get_file().get_basename()
	$Sound.stream = sound
	


# May need to make functionality to have music aligned to beat
func _on_check_button_toggled(toggled_on: bool) -> void:
	if $CheckButton.button_pressed:
		playing = true
	else:
		playing = false

func timer_timeout():
	if playing:
		if ! $Sound.playing:
			$Sound.play()
	else:
		$Sound.stop()
