class_name FreeEntity extends ClassicEntity


func onDeath() -> void:
	print("Free entity died !!!")
	queue_free()
