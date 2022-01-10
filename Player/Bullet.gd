extends Node2D

var speed = 1
var current_mouse_pos 
var direction : Vector2

onready var timeout : Node = get_node("Timer")

func _process(delta):
	
	current_mouse_pos = get_global_mouse_position()
	direction = current_mouse_pos - global_position
	self.global_translate(direction.normalized()*speed)
	
	look_at(current_mouse_pos)

func _on_Timer_timeout():
	self.queue_free()
