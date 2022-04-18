extends MarginContainer


onready var resume = $PanelContainer/VBoxContainer/Resume
onready var main_menu = $PanelContainer/VBoxContainer/MainMenu
onready var exit = $PanelContainer/VBoxContainer/Exit


func _ready():
	resume.connect("pressed", self, "_on_resume")
	main_menu.connect("pressed", self, "_on_main_menu")
	exit.connect("pressed", self, "_on_exit")
	visible = false


func _on_resume():
	visible = false
	get_tree().paused = false


func _on_main_menu():
	get_tree().change_scene("res://scenes/main_menu.tscn")
	get_tree().paused = false


func _on_exit():
	get_tree().quit()


func _input(event):
	if event.is_action_pressed("pause") and not event.is_echo():
		get_tree().paused = !visible
		visible = !visible
