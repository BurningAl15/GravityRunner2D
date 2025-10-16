extends Node2D

@export var countdown_time := 4.0

@onready var countdown_label: Label = $CountdownPanel/CountdownLabel

func _ready() -> void:
	$CountdownTimer.wait_time = countdown_time
	$CountdownTimer.start()
	countdown_label.text = str(countdown_time - 1)

func _process(delta):
	if ($CountdownTimer.time_left > 2):
		countdown_label.text = str(int(ceil($CountdownTimer.time_left - 0.5)) - 1)
	elif ($CountdownTimer.time_left <= 2 and $CountdownTimer.time_left > 0):
		countdown_label.text = "Go!"

func _on_countdown_timer_timeout() -> void:
	$CountdownTimer.stop()
	$CountdownPanel.hide()


func _on_obstacle_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
