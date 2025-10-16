extends Area2D

func _on_power_up_body_entered(body: Node2D) -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()
