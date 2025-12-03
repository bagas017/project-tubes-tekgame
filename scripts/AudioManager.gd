extends Node

var master_enabled: bool = true

func set_master_audio(enabled: bool):
	master_enabled = enabled
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not enabled)
