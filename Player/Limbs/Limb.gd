extends Node2D
class_name Limb

var outlineMaterial = preload("res://Player/Limbs/OutlineMaterial.tres")
export(bool) var addOutline = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _changeSkeleton(_skeleton: Skeleton2D):
	pass

func applySkeleton(_skeleton: Skeleton2D):
	_changeSkeleton(_skeleton)
	
	var toadd = []
	for N in get_children():
		if(N is Polygon2D):
			N.set_skeleton(_skeleton.get_path())
			if(addOutline):
				var outlineN: Node2D = N.duplicate()
				
				outlineN.self_modulate = Color.black
				outlineN.z_index -= 1
				outlineN.material = outlineMaterial
				
				toadd.append(outlineN)
	for outlineN in toadd:
		add_child(outlineN)
