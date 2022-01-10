extends Node2D

signal falling

onready var left_ray = $left
onready var right_ray = $right

func _physics_process(_delta):

	if not left_ray.is_colliding() and not right_ray.is_colliding():
		emit_signal("falling")
		print("wow")
