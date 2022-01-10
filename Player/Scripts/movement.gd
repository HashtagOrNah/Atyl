extends KinematicBody2D

export var SPEED = 100
export var AIR_SPEED = 90
export var MAX_AIR_SPEED = -1000
export var ACCEL = 10
export var AIR_ACCEL = 20
export var GRAV = 10

var jumping = false
var falling = false
var direction = 0
var air_direction = Vector2(0,0)
var velocity = Vector2(0,0)

onready var left_ray : Node = get_node("left")
onready var right_ray : Node = get_node("right")
onready var anim_manager : Node = get_node("AnimatedSprite")

var current_state = "Fall" setget _set_state, _get_state
var previous_state = "Fall"

onready var v_lab : Node = get_node("Control/Label")
onready var coyote_timer : Node = get_node("Coyote")
onready var cooldown : Node = get_node("AttackCooldown")
onready var bullet_spawn : Node = get_node("BulletSpawn")
onready var bullet_container : Node = get_node("BulletContainer")
export var bullet : PackedScene

func _set_state(state):
	coyote_timer.stop()
	print(state)
	if current_state == "Fall":
		falling = false

	if state == "Jump":
		velocity.y = MAX_AIR_SPEED
	
	elif state == "Fall":
		if current_state != "Jump":
			coyote_timer.start()
		velocity.y = -GRAV
	
	previous_state = current_state
	current_state = state
	
	animation_process()

func animation_process():
	
	if previous_state == "Walk" and current_state == "Fall":
		anim_manager.play("Ledge_Fall")
		yield(anim_manager, "animation_finished")
	
	anim_manager.play(current_state)

func _get_state():
	return current_state

func _input(event):
	
	direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	if direction == -1:
		get_node("AnimatedSprite").flip_h = true
	
	elif direction == 1:
		get_node("AnimatedSprite").flip_h = false
		
	if event.is_action_pressed("jump"):
		jumping = true
		
	if event.is_action_pressed("attack"):
		attack()
	
	elif event.is_action_released("jump"):
		jumping = false
		
func _physics_process(delta):
	
	v_lab.text = "X: {x}, Y: {y}".format({"x": stepify(velocity.x, 0.01), "y": stepify(velocity.y, 0.01)})
	
	if !left_ray.is_colliding() and !right_ray.is_colliding():
		falling = true

	call(current_state, delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)

func Idle(delta):

	if jumping:
		self.current_state = "Jump"
		
	elif falling:
		self.current_state = "Fall"
		
	elif direction:
		self.current_state = "Walk"

func Walk(delta):
	
	if jumping:
		self.current_state = "Jump"
	elif not direction:
		velocity.x = 0
		self.current_state = "Idle"
	elif falling:
		self.current_state = "Fall"
		
	velocity.x = min(abs(velocity.x) + ACCEL, SPEED) * direction
	
func Fall(delta):
	
	if is_on_floor():
		if direction:
			self.current_state = "Walk"
		else:
			self.current_state = "Idle"
	
	elif jumping == true and coyote_timer.is_stopped() == false:
		self.current_state = "Jump"

	velocity.y += GRAV
	velocity.x = min(abs(velocity.x) + AIR_ACCEL, AIR_SPEED) * direction

func Jump(delta):
	
	if velocity.y >= 0:
		self.current_state = "Fall"
		
	elif not jumping:
		if is_on_floor():
			if direction:
				self.current_state = "Walk"
			else:
				self.current_state = "Idle"
		else:
			self.current_state = "Fall"
	
	velocity.y += GRAV
	velocity.x = min(abs(velocity.x) + AIR_ACCEL, AIR_SPEED) * direction

func attack():
	
	if cooldown.is_stopped() == false:
		return
	
	var new_bullet = bullet.instance()
	new_bullet.global_position = bullet_spawn.global_position
	bullet_container.add_child(new_bullet)
