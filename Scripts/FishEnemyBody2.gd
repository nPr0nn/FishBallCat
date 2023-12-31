extends KinematicBody2D
onready var Game = get_node("/root/Singleton")

var player = null

var velocity = Vector2.ZERO
var maxSpeed = 110
var vacantSpeed = 80
var pushBackSpeed = 150
var hp: int = 100
var followDot = null
onready var health_bar = $Healthbar
var caminho
var armor = 0.5
var minimap_icon = "enemy"
var timeStarted = false
onready var timer = get_node("Timer")

signal removed
		
func _ready():
	caminho = get_parent().get_child(1)
	followDot = caminho.get_child(0).get_child(0)
	pass
	var cena = get_parent().get_parent().get_parent()
	#cena.get_parent().get_parent().get_parent().find_node("MiniMap")._new_marker(get_parent())	

func _physics_process(delta):
	self.look_at(velocity+self.global_position)
	if player != null and !timeStarted:
		velocity = (player.global_position - global_position).normalized() * maxSpeed
		look_at(player.global_position)	
	elif followDot != null and !timeStarted:
		look_at(followDot.global_position)
		velocity = (followDot.global_position - global_position).normalized() * vacantSpeed
	elif !timeStarted:
		velocity = Vector2.ZERO

	velocity = move_and_slide(velocity)
	if timeStarted:
		look_at(-velocity+self.global_position)
	
	#colisions
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "PlayerBody":
			collision.collider.hurt(10)
			collision.collider.pushBack(self.global_position) #new
			self.pushBack(collision.collider.global_position) #new
			
			
func hurt(dano = 1, show = true):
	if typeof(dano) != 2 or dano < 0:
		return "valor de dano invalido"
	hp-=dano*(1-self.armor)
	if show:
		health_bar._on_health_updated(hp,0)
	if hp<=0:
		if !show:
			return "dead"
		dead()
	return hp
	
func pushBack(enemyPosition):#new
	var pushBackDirection = (self.global_position - enemyPosition).normalized()
	velocity = pushBackDirection * pushBackSpeed
	timer.set_wait_time(0.15)
	timer.start()
	timeStarted = true
	
	
func dead():
	Game.bossKill()
	emit_signal("removed", get_parent())
	get_parent().queue_free()

func _on_Area2D_body_entered(body):
	if body.name == "PlayerBody":
		player = body
		pass

func _on_Area2D_body_exited(body):
	if body.name == "PlayerBody":
		player = null

func _on_Timer_timeout():
	timeStarted = false
	timer.stop()
