extends Node

var best_time := -1.0

func on_end_level(time):
	
	if best_time == -1.0 or time < best_time:
		best_time = time
