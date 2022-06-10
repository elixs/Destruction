extends Node2D

var hp = 100
var strenght = 5
var defense = 2
var display_name = "xD"

onready var label = $Label

export(Script) var Stats

func _ready():
	_update_text()


func _input(event):
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		Persistent.text = "owo"
		_update_text()
	if event.is_action_pressed("ui_right") and not event.is_echo():
		get_tree().change_scene("res://persistent/sceneB.tscn")
	if event.is_action_pressed("save") and not event.is_echo():
#		save_game_json()
#		save_game_persistent()
#		save_game_persistent2()
#		save_game_resource()
		save_game_config()

	if event.is_action_pressed("load") and not event.is_echo():
#		load_game_json()
#		load_game_persistent()
#		load_game_persistent2()
#		load_game_resource()
		load_game_config()


func _update_text():
	label.text = Persistent.text


func save_game_json():
	var data = {
		"hp": hp,
		"strenght": strenght,
		"defense": defense,
		"display_name": display_name,
		"text": label.text
	}
	var data_str = JSON.print(data)
	var file = File.new()
	file.open("user://game.json", File.WRITE)
	file.store_string(data_str)
	file.close()


func load_game_json():
	var file = File.new()
	if !file.file_exists("user://game.json"):
		return
	file.open("user://game.json", File.READ)
	var data_str = file.get_as_text()
	file.close()
	var data = JSON.parse(data_str).result
	print(data.hp)
	print(data.strenght)
	print(data.defense)
	print(data.display_name)
	label.text = data.text


func save_game_persistent():
	var file = File.new()
#	file.open("user://game.save", File.WRITE)
	file.open_encrypted_with_pass("user://game.save", File.WRITE, "1234")
	for node in get_tree().get_nodes_in_group("Persistent"):
		if node.has_method("save"):
			var node_data = node.save()
			file.store_line(to_json(node_data))
	file.close()



func load_game_persistent():
	for node in get_tree().get_nodes_in_group("Persistent"):
		node.queue_free()
	var file = File.new()
	if !file.file_exists("user://game.save"):
		return
	file.open_encrypted_with_pass("user://game.save", File.READ, "1234")
	while file.get_position() < file.get_len():
		var data = parse_json(file.get_line())
		var node: Node = load(data.filename).instance()
		node.add_to_group("Persistent")
		get_tree().get_root().get_node(data.parent).add_child(node)
		node.position = str2var(data.position)
		node.modulate = str2var(data.modulate)
		for key in data.keys():
			if key in ["filename", "parent", "position", "modulate"]:
				continue
			node.set(key, data[key])
	file.close()


func save_game_persistent2():
	var file = File.new()
	file.open("user://game2.save", File.WRITE)
	file.store_float(12.3)
	file.store_32(42)
	file.close()


func load_game_persistent2():
	var file = File.new()
	if !file.file_exists("user://game2.save"):
		return
	file.open("user://game2.save", File.READ)
	
	print(file.get_float())
	print(file.get_32())
	file.close()
	

func save_game_resource():
	var stats = Stats.new()
	stats.hp = 200
	stats.luck = 42.8
	stats.name = "asildhf"
	
	ResourceSaver.save("user://game.tres", stats)
	
#	var file = File.new()
#	file.open("user://game2.tres", File.WRITE)
#	file.store_var(inst2dict(stats))
#	file.close()

func load_game_resource():
	var stats = load("user://game.tres")
	print(stats.name)
	print(stats.hp)
	print(stats.luck)
#	var file = File.new()
#	file.open("user://game2.tres", File.READ)
#	var stats = dict2inst(file.get_var())
#	file.close()
	 
	
func save_game_config():
	var config = ConfigFile.new()
	config.set_value("style", "font", 42)
	config.set_value("style", "color", var2str(Color.rebeccapurple))
	config.set_value("data", "name", "adsfadf")
	config.set_value("data", "age", 54)
	config.save("user://game.cfg")

func load_game_config():
	var config = ConfigFile.new()
	config.load("user://game.cfg")
	for section in config.get_sections():
		for key in config.get_section_keys(section):
			prints(section, key, config.get_value(section, key))
