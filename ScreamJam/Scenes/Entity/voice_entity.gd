extends Node3D


func _ready():
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera.global_position.distance_to(global_position) < 10.0:
		$AudioStreamPlayer3D.bus = "Master"
	
	$AudioStreamPlayer3D.finished.connect(queue_free)
	$AudioStreamPlayer3D.play()
