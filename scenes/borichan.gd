extends KinematicBody2D

var SPEED = 100
var CROUCH_SPEED = 50
var ACCELERATION = 500
var GRAVITY = 400

var health = 100 setget set_health
var max_health = 100

var velocity = Vector2()

onready var anim_tree = $AnimationTree
onready var playback = anim_tree.get("parameters/playback")
onready var pivot = $Pivot
onready var feet = $Feetlo
onready var melee_area = $Pivot/MeleeArea
onready var camera = $Camera2D
onready var health_bar = $CanvasLayer/HealthBar
onready var collision_shape = $CollisionShape2D
onready var crouch_ray_casts = $RayCasts

var Block = preload("res://scenes/Block.tscn")
var Dust = preload("res://scenes/Dust.tscn")

export var attacking = false

var crouched = false


func _ready():
	anim_tree.active = true
	attacking = false
	# camera.set_as_toplevel(true)
	melee_area.connect("body_entered", self, "_on_melee_area_entered")
	
	Manager.meh = 3
	Manager.player = self
	
	health_bar.value = health

func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var move_input = Input.get_axis("move_left", "move_right")
	
	if attacking:
		move_input = 0
	
	var move_speed = CROUCH_SPEED if crouched else SPEED
	
	velocity.x = move_toward(velocity.x, move_input * move_speed, ACCELERATION)

	velocity.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("crouch"):
		crouched = true
		# var capsule: CapsuleShape2D = collision_shape.shape
		# (collision_shape.shape as CapsuleShape2D).radius
		# collision_shape.shape.radius = algo
		for ray_cast in crouch_ray_casts.get_children():
			ray_cast.enabled = true
	
	if not Input.is_action_pressed("crouch"):
		
		var not_ray_cast_colliding = true
		for ray_cast in crouch_ray_casts.get_children():
			if ray_cast.is_colliding():
				not_ray_cast_colliding = false
				break
		if not_ray_cast_colliding:
			crouched = false
			for ray_cast in crouch_ray_casts.get_children():
				ray_cast.enabled = false
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -2 * SPEED
	
	var melee = false
	if not crouched and Input.is_action_just_pressed("attack"):
		playback.travel("melee")
		melee = true
	
	
	if Input.is_action_just_pressed("place"):
		_place()
	
	# Animation
	
	if not melee:
		if is_on_floor():
			if crouched:
				if abs(velocity.x) > 10:
					playback.travel("crouch_walk")
				else:
					playback.travel("crouch")
			else:
				if abs(velocity.x) > 10:
					playback.travel("run")
				else:
					playback.travel("idle")
		else:
			if velocity.y > 0:
				playback.travel("fall")
			else:
				playback.travel("jump")
	
	# Animation
	if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		pivot.scale.x = 1
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		pivot.scale.x = -1
	
	
	# manual camera smoothing
	# camera.global_position = lerp(camera.global_position, global_position, 0.1)


func land():
	pass
	# var dust = Dust.instance()
	# get_parent().add_child(dust)
	#dust.global_position = feet.global_position

func _on_melee_area_entered(body: Node):
	if body.has_method("take_damage"):
		body.take_damage(self)


func _place():
	var block = Block.instance()
	get_parent().add_child(block)
	block.global_position = get_global_mouse_position()


func take_damage(instigator: Node2D):
	self.health -= 10


func set_health(value):
	health = value
	health_bar.value = health
