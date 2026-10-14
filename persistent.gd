extends Node

var _curr_level_index := 0
var _levels := ResourceLoader.list_directory("res://level_scenes")

var best_time := -1.0
var first_try_at_level = true # when retry_level is added this can be false, influences the showing of LevelInfo at level start

func on_end_level(time):
	
	if best_time == -1.0 or time < best_time:
		best_time = time

func next_level():
	_curr_level_index += 1
	_curr_level_index = _curr_level_index % _levels.size()
	get_tree().change_scene_to_file("res://level_scenes/" + _levels[_curr_level_index])
