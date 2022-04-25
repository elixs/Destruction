extends Node2D

onready var area = $Area2D
onready var respawn_point = $RespawnPoint


func _ready():
	area.connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node):
	Manager.checkpoint_position = respawn_point.global_position
