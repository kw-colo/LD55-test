extends ColorRect

@onready var Player: CharacterBody3D = get_tree().current_scene.find_child("Player")

# Program Wide
@onready var config = ConfigFile.new()
@onready var audioServer = AudioServer

# Option Menu Controls
@onready var optionsBackButton: Button = find_child("OptionsBackButton")
@onready var audioMasterSlider: Slider = find_child("AudioMasterSlider")
@onready var audioMusicSlider: Slider = find_child("AudioMusicSlider")
@onready var audioSFXSlider: Slider = find_child("AudioSFXSlider")
@onready var audioVoiceSlider: Slider = find_child("AudioVoiceSlider")
@onready var mouseSensitivitySlider: Slider = find_child("MouseSensitivitySlider")
@onready var fovSlider: Slider = find_child("FOVSlider")
@onready var vsyncCheckbox : CheckBox = find_child("Vsync_Checkbox")
@onready var fullscreenCheckbox : CheckBox = find_child("Fullscreen_Checkbox")
@onready var msaaOptions : OptionButton = find_child("MSAA_Checkbox")

signal options_closed()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_sliders_to_labels()
	print("Hi")
	#visible = false
	var loadStatus = config.load("user://config.ini")
	if loadStatus == OK: #0 = loaded, so this means data found
		loadConfig()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func connect_sliders_to_labels():
	audioMasterSlider.value_changed.connect(audioMasterSlider_changed)
	audioMusicSlider.value_changed.connect(audioMusicSlider_changed)
	audioSFXSlider.value_changed.connect(audioSFXSlider_changed)
	audioVoiceSlider.value_changed.connect(audioVoiceSlider_changed)
	mouseSensitivitySlider.value_changed.connect(mouseSensitivitySlider_changed)
	fovSlider.value_changed.connect(fovSlider_changed)
	optionsBackButton.pressed.connect(close_options)
	
func close_options():
	visible = false
	emit_signal("options_closed")

func audioMasterSlider_changed(value):
	find_child("AudioMasterLabel").text = str(value).pad_decimals(2)
	storeConfig("AudioMasterSlider", value)
	setBusDB("Master", value)
	
func audioMusicSlider_changed(value):
	find_child("AudioMusicLabel").text = str(value).pad_decimals(2)
	storeConfig("AudioMusicSlider", value)
	setBusDB("Music", value)

func audioSFXSlider_changed(value):
	find_child("AudioSFXLabel").text = str(value).pad_decimals(2)
	storeConfig("AudioSFXSlider", value)
	setBusDB("SFX", value)

func audioVoiceSlider_changed(value):
	find_child("AudioVoiceLabel").text = str(value).pad_decimals(2)
	storeConfig("AudioVoiceSlider", value)
	setBusDB("Dialogue", value) #maybe other buses
	
func mouseSensitivitySlider_changed(value):
	find_child("MouseSensitivityLabel").text = str(value).pad_decimals(2)
	storeConfig("MouseSensitivitySlider", value)
	if Player:
		Player.MOUSE_SENS = value

func fovSlider_changed(value):
	find_child("FOVLabel").text = str(value)
	if Player:
		Player.find_child("Camera3D").fov = value
	storeConfig("FOVSlider",value)
	
#Config Save/Load
func saveConfig():
	var saveStatus = config.save("user://config.ini")
	if saveStatus:
		print("config save failed")

func loadConfig():
	var settingKeys = config.get_section_keys("settings")
	for key in settingKeys:
		if key != "leaderboard_name" and key != "fullscreen" and key != "Resolution_Options_Button" and key != "Resolution_Options_Current_Index":
			if key == "Fullscreen_Checkbox":
				var current_value = config.get_value("settings", key)
				if current_value == 4:
					find_child(key).button_pressed = true
				else:
					find_child(key).button_pressed = false
			elif key == "Vsync_Checkbox":
				var current_value = config.get_value("settings", key)
				if current_value == 4:
					find_child(key).button_pressed = true
				else:
					find_child(key).button_pressed = false
			elif key == "MSAA_Checkbox":
				find_child(key).selected = config.get_value("settings", key)
			else:
				if !find_child(key) == null:
					find_child(key).value = config.get_value("settings", key)

func setBusDB(busName, linear):
	audioServer.set_bus_volume_db(audioServer.get_bus_index(busName), linear_to_db(linear))

func storeConfig(component,value):
	config.set_value("settings",component,value)
	saveConfig()

func _on_vsync_checkbox_toggled(button_pressed):
	var vsync
	if button_pressed: vsync = 1
	else: vsync = 0
	storeConfig("Vsync_Checkbox", vsync)
	DisplayServer.window_set_vsync_mode(vsync)

func _on_fullscreen_checkbox_toggled(button_pressed):
	var fullscreen
	if button_pressed: 
		fullscreen = 4
	else:
		fullscreen = 0
	storeConfig("Fullscreen_Checkbox", fullscreen)
	DisplayServer.window_set_mode(fullscreen)

func _on_resolution_changed(index):
	pass
	var new_resolution : Vector2
	match index:
		0: new_resolution = Vector2(640, 360)
		1: new_resolution = Vector2(1280, 720)
		2: new_resolution = Vector2(1280, 800)
		3: new_resolution = Vector2(1920, 1080)
		4: new_resolution = Vector2(2550, 1440)
		5: new_resolution = Vector2(3840, 2160)
	DisplayServer.window_set_size(new_resolution)
	storeConfig("Resolution_Options_Button", new_resolution)
	storeConfig("Resolution_Options_Current_Index", index)


func _on_msaa_options_item_selected(index):
	var new_msaa 
	match index:
		0: new_msaa = get_tree().get_root().MSAA_DISABLED
		1: new_msaa = get_tree().get_root().MSAA_2X
		2: new_msaa = get_tree().get_root().MSAA_4X
		3: new_msaa = get_tree().get_root().MSAA_8x
		4: new_msaa = get_tree().get_root().MSAA_MAX
	storeConfig("MSAA_Checkbox", new_msaa)
	get_tree().get_root().msaa_3d = new_msaa
