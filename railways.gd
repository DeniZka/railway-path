extends Node

signal railwais_updated()

var rails : Array[Path2D] = []

func parse_railways(railways: Node2D):
	#collect rails paths
	for rail in railways.get_children():
		if rail is Path2D:
			rails.append(rail)
	railwais_updated.emit()

func add_railways(railway: Path2D):
	rails.append(railway)

func remove_railways(railway: Path2D):
	rails.erase(railway)

