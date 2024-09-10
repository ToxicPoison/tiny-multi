extends HBoxContainer

var audio_icon := preload("res://menus/audio.png")
var muted_icon := preload("res://menus/audio_muted.png")

func _on_button_toggled(toggled_on):
	if toggled_on:
		$Button.icon = audio_icon
	else:
		$Button.icon = muted_icon
	AudioServer.set_bus_mute(0, !toggled_on)
	

func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)
