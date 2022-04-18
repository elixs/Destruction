extends RigidBody2D

var health = 3

func take_damage(instigator: Node2D):
	health -= 1
	if health <= 0:
		queue_free()
	else:
		apply_central_impulse((global_position - instigator.global_position).normalized() * 200)
