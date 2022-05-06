extends Node2D

onready var slot = $ViewportContainer/Viewport/SlotMachine
var rolled = false

func _ready():
  slot.connect("stopped", self, "_on_slot_machine_stopped")

func _on_Roll2_button_down():
	if rolled == false:
		slot.start()
		rolled = true
	else:
		slot.stop()

func _on_slot_machine_stopped():
  rolled = false
