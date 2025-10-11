extends Node2D


#var F1B1 = AudioStreamPlayer.new()
#var F1B2 = AudioStreamPlayer.new()
#var F1B3 = AudioStreamPlayer.new()
#var F1B4 = AudioStreamPlayer.new()
#var F1C1 = AudioStreamPlayer.new()
#var F1C2 = AudioStreamPlayer.new()
#var F1C3 = AudioStreamPlayer.new()
#var F1C4 = AudioStreamPlayer.new()
#var F1HH1 = AudioStreamPlayer.new()
#var F1HH2 = AudioStreamPlayer.new()
#var F1HH3 = AudioStreamPlayer.new()
#var F1HH4 = AudioStreamPlayer.new()
#var F1KS1 = AudioStreamPlayer.new()
#var F1KS2 = AudioStreamPlayer.new()
#var F1KS3 = AudioStreamPlayer.new()
#var F1KS4 = AudioStreamPlayer.new()
#var F1M1 = AudioStreamPlayer.new()
#var F1M2 = AudioStreamPlayer.new()
#var F1M3 = AudioStreamPlayer.new()
#var F1M4 = AudioStreamPlayer.new()
#var F1M5 = AudioStreamPlayer.new()

func _ready() -> void:
	var F1B1 = load("res://Music/Funk1Tracks/F1B1.wav")
	var F1B2 = load("res://Music/Funk1Tracks/F1B2.wav")
	var F1B3 = load("res://Music/Funk1Tracks/F1B3.wav")
	var F1B4 = load("res://Music/Funk1Tracks/F1B4.wav")
	var F1C1 = load("res://Music/Funk1Tracks/F1C1.wav")
	var F1C2 = load("res://Music/Funk1Tracks/F1C2.wav")
	var F1C3 = load("res://Music/Funk1Tracks/F1C3.wav")
	var F1C4 = load("res://Music/Funk1Tracks/F1C4.wav")
	var F1HH1 = load("res://Music/Funk1Tracks/F1HH1.wav")
	var F1HH2 = load("res://Music/Funk1Tracks/F1HH2.wav")
	var F1HH3 = load("res://Music/Funk1Tracks/F1HH3.wav")
	var F1HH4 = load("res://Music/Funk1Tracks/F1HH4.wav")
	var F1KS1 = load("res://Music/Funk1Tracks/F1KS1.wav")
	var F1KS2 = load("res://Music/Funk1Tracks/F1KS2.wav")
	var F1KS3 = load("res://Music/Funk1Tracks/F1KS3.wav")
	var F1KS4 = load("res://Music/Funk1Tracks/F1KS4.wav")
	var F1M1 = load("res://Music/Funk1Tracks/F1M1.wav")
	var F1M2 = load("res://Music/Funk1Tracks/F1M2.wav")
	var F1M3 = load("res://Music/Funk1Tracks/F1M3.wav")
	var F1M4 = load("res://Music/Funk1Tracks/F1M4.wav")
	var F1M5 = load("res://Music/Funk1Tracks/F1M5.wav")
	var bass = [F1B1, F1B2, F1B3, F1B4]
	var chords = [F1C1, F1C2, F1C3, F1C4]
	var high_hats = [F1HH1, F1HH2, F1HH3, F1HH4]
	var drums = [F1KS1, F1KS2, F1KS3, F1KS4]
	var melody = [F1M1, F1M2, F1M3, F1M4, F1M5]
	
	var song = [bass.pick_random(), chords.pick_random(), high_hats.pick_random(), drums.pick_random(), melody.pick_random()]
	
	for sound in song:
		add_child(sound)
		sound.play()
	
	
