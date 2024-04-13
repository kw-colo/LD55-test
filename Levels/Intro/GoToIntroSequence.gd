extends Control

@export var next_scene: PackedScene

var settings_applied = false
@onready var config = ConfigFile.new()

func _ready():
	var loadStatus = config.load("user://config.ini")
	if loadStatus == OK: #0 = loaded, so this means data found
		load_config()
	else:
		$VideoStreamPlayer.play()
		push_warning("Not able to load config.ini, can't load settings")
		settings_applied = true
	
func load_config():
	var keys = config.get_section_keys("settings")
	for key in keys:
		if key == "Resolution_Options_Button":
			DisplayServer.window_set_size(config.get_value("settings", key))
		elif key == "Fullscreen_Checkbox":
			DisplayServer.window_set_mode(config.get_value("settings", key))
		elif key == "Vsync_Checkbox":
			DisplayServer.window_set_vsync_mode(config.get_value("settings", key))
		elif key == "MSAA_Checkbox":
			var new_msaa 
			match config.get_value("settings", key):
				0: new_msaa = get_tree().get_root().MSAA_DISABLED
				1: new_msaa = get_tree().get_root().MSAA_2X
				2: new_msaa = get_tree().get_root().MSAA_4X
				3: new_msaa = get_tree().get_root().MSAA_8x
				4: new_msaa = get_tree().get_root().MSAA_MAX
			get_tree().get_root().msaa_3d = new_msaa
	$VideoStreamPlayer.play()
	settings_applied = true

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file(next_scene.resource_path)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") || Input.is_action_just_pressed("ui_accept"): 
		if settings_applied: get_tree().change_scene_to_file(next_scene.resource_path)
