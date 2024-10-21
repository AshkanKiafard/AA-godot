extends Node

@onready var announcer_voice: AudioStreamPlayer = $AnnouncerVoice
@onready var label: Label = $"../UI/CenterContainer/Label"

var text
var praise_sounds = ["excellent", "god like", "great", "my god", "perfect", "wow"]

func choose(l: Array):
	return l[randi()%len(l)]
	
func play_praise_voice(enemy_health):
	if enemy_health > 0:
		text = choose(praise_sounds)
	else:
		text = "ko"
	announcer_voice.stream = load("res://assets/audio/announcer/"+text+".wav")
	label.text = text + "!"
	label.visible = true
	announcer_voice.play()
	await announcer_voice.finished
	label.visible = false
