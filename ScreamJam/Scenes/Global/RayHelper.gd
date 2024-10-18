extends Node3D

func castScreenMouseRay():
	var mousePosition: Vector2 = get_viewport().get_mouse_position()
	
	var sceneCamera: Camera3D = get_viewport().get_camera_3d()
	var origin = sceneCamera.project_ray_origin(mousePosition)
	var direction =  sceneCamera.project_ray_normal(mousePosition)
	
	var space_state = get_world_3d().direct_space_state
	var query =  PhysicsRayQueryParameters3D.create(origin, origin + direction * 20.0, 0b1000000)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	
	return null

func castRay(origin: Vector3, end: Vector3, mask: int):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, end, mask)
	var result = space_state.intersect_ray(query)
	
	return result
