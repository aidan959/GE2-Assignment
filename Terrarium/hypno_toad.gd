extends Area3D

@onready var timer : Timer = $Timer
var trip : MeshInstance3D 

func _on_body_entered(body):
	if body is Player:
		trip = body.get_node("Camera").get_node("TripBALLS")
		timer.start(15)
		trip.visible = true

func _on_timer_timeout():
	trip.visible = false
