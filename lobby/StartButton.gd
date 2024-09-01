extends Button

@onready var lobby = get_tree().get_current_scene()

func _ready():
	lobby.connect("ready_status_updated", _on_status_updated)
	if not ServerSingleton.is_multiplayer_authority():
		queue_free()

func _on_status_updated() -> void:
	for p in lobby.ready_status:
		if not lobby.ready_status[p]:
			set_disabled(true)
			return
	set_disabled(false)
