extends Node

export var spawn_max = 3
export var spawn_rate = 2
export var unit : PackedScene

var child_count = 0

func _ready():
	
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(spawn_rate)
	timer.connect("timeout", self, "spawn_unit")
	timer.start()
	
func spawn_unit():
	
	if child_count == spawn_max:
		return
	
	var new_inst = unit.instance()
	add_child(new_inst)
	child_count += 1
