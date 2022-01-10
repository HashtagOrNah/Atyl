extends KinematicBody2D

onready var animation : Node = $AnimatedSprite

var SPEED = 20
var velocity = Vector2()
var direction = 1

var last_state = "Fall"
var current_state = "Fall"

var rng = RandomNumberGenerator.new()
var rand_walk : float = 0.0

func _ready():
	rng.randomize()

func _physics_process(delta):
	
	animation.flip_h = direction-1
	call(current_state, delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)

func change_state(state):
	
	if last_state == "Fall":
		velocity.y = 0
	
	animation.play(state)
	
	last_state = current_state
	current_state = state

func Fall(_delta):
	
	velocity.y += 50
	
	if is_on_floor():
		idle_process()
		change_state("Idle")

func Walk(delta):
	
	rand_walk -= delta
	velocity.x = SPEED * direction
	
	if rand_walk <= 0:
		velocity.x = 0
		idle_process()
		change_state("Idle")

func Idle(_delta):
	pass
	
func idle_process():
	
	yield(animation, "animation_finished")
	animation.play("Walk_Start")
	yield(animation, "animation_finished")
	
	direction = -direction
	rand_walk = rng.randf_range(1,3)
	change_state("Walk")

