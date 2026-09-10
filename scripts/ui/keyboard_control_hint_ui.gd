extends Control

var key_hint_scene = preload("res://scenes/ui/key_hint.tscn")

var current_state: Enum.State = Enum.State.DEFAULT
var current_tool: Enum.Tool = Enum.Tool.AXE

const DISPLAY_KEYS = [
	Enum.KEYBOARD.CHANGE_TOOL,
	Enum.KEYBOARD.CHANGE_MACHINE,
	Enum.KEYBOARD.ACTION,
	Enum.KEYBOARD.INTERACT,
	Enum.KEYBOARD.CHANGE_MODE,
	Enum.KEYBOARD.CHANGE_SEED,
]


func _ready() -> void:
	var keys = (
		Data.KEYBOARD_KEYS
		if Input.get_connected_joypads().size() == 0
		else Data.KEYBOARD_CONTROLLER
	)

	for key in DISPLAY_KEYS:
		var key_hint = key_hint_scene.instantiate()
		var initial_item = _get_initial_item(key)
		var icon = Data.KEYBOARD_TO_ICONS[key][initial_item]

		key_hint.setup(
			keys[key],
			icon,
			key
		)

		$VBoxContainer.add_child(key_hint)

	_apply_visibility()


func _get_initial_item(key):
	match key:
		Enum.KEYBOARD.CHANGE_TOOL:
			return current_tool

		Enum.KEYBOARD.CHANGE_MACHINE:
			return Enum.Machine.DELETE

		Enum.KEYBOARD.CHANGE_MODE:
			return Enum.State.BUILDING

		Enum.KEYBOARD.CHANGE_SEED:
			return Enum.Seed.TOMATO

		_:
			return 0


func _find_key_hint(key_enum):
	for key_hint in $VBoxContainer.get_children():
		if key_hint.keyboard_key == key_enum:
			return key_hint

	return null


func _set_hint_visible(key_enum, should_show: bool) -> void:
	var key_hint = _find_key_hint(key_enum)

	if key_hint:
		key_hint.visible = should_show


func _apply_visibility() -> void:
	for key_hint in $VBoxContainer.get_children():
		key_hint.hide()

	match current_state:
		Enum.State.DEFAULT:
			_set_hint_visible(Enum.KEYBOARD.CHANGE_TOOL, true)
			_set_hint_visible(Enum.KEYBOARD.ACTION, true)
			_set_hint_visible(Enum.KEYBOARD.INTERACT, true)
			_set_hint_visible(Enum.KEYBOARD.CHANGE_MODE, true)

			if current_tool == Enum.Tool.SEED:
				_set_hint_visible(Enum.KEYBOARD.CHANGE_SEED, true)

		Enum.State.BUILDING:
			_set_hint_visible(Enum.KEYBOARD.CHANGE_MACHINE, true)
			_set_hint_visible(Enum.KEYBOARD.ACTION, true)
			_set_hint_visible(Enum.KEYBOARD.CHANGE_MODE, true)

		Enum.State.HOUSE:
			_set_hint_visible(Enum.KEYBOARD.INTERACT, true)

		Enum.State.FISHING:
			_set_hint_visible(Enum.KEYBOARD.ACTION, true)

		Enum.State.SHOP:
			pass


func _on_player_update_control_ui(
	key_enum,
	current_item,
	state
) -> void:
	current_state = state

	if key_enum == Enum.KEYBOARD.CHANGE_TOOL:
		current_tool = current_item as Enum.Tool

	var key_hint = _find_key_hint(key_enum)

	if key_hint:
		if key_enum == Enum.KEYBOARD.CHANGE_MODE:
			key_hint.update(Enum.State.BUILDING)
		else:
			key_hint.update(current_item)

	_apply_visibility()


func _on_level_update_hint_ui_keys() -> void:
	var keys = (
		Data.KEYBOARD_KEYS
		if Input.get_connected_joypads().size() == 0
		else Data.KEYBOARD_CONTROLLER
	)

	for key_hint in $VBoxContainer.get_children():
		if keys.has(key_hint.keyboard_key):
			key_hint.update_key_texture(
				keys[key_hint.keyboard_key]
			)
