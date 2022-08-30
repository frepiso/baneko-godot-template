# ----------------------------------------
# utility.gd
# ----------------------------------------
# Functions for tool use.
extends Node
const MODULE_NAME = "Utility"

@onready var logger = load("res://core/classes/logger.gd").new()
@onready var pckmgr = load("res://core/classes/pckmgr.gd").new()
@onready var loader = load("res://core/classes/loader.gd").new()


# Ready ----------------------------------
func _ready():
	pckmgr.set_logger(logger)
	loader.set_logger(logger)
	pass


# File Operations ------------------------
# Get files in folder and subfolders. Regex Match is supported.
func get_files_recursive(path: String, regex: RegEx = null) -> Array:
	var files = []
	var dir := Directory.new()
	if dir.open(path) != OK:
		logger.error("Could not open directory: %s" % path, MODULE_NAME)
		return []
	if dir.list_dir_begin() != OK:
		logger.error("Could not list contents of: %s" % path, MODULE_NAME)
		return []
	var file := dir.get_next()
	while file != "":
		if dir.current_is_dir():
			files += get_files_recursive(dir.get_current_dir().path_join(file), regex)
		else:
			var file_path = dir.get_current_dir().path_join(file)
			if regex != null:
				if regex.search(file_path):
					files.append(file_path)
			else:
				files.append(file_path)
		file = dir.get_next()
	return files


# PackageManager -------------------------
# Load Packages from given paths (with order)
func load_packages(paths: Array) -> void:

	if OS.has_feature("standalone"):
		# Load if exported.
		pckmgr.set_path(paths)
		pckmgr.load_packages()
	else:
		logger.warning("This project seems runs in editor, Hello developers!", MODULE_NAME)
		logger.warning("Skipping load packages!", MODULE_NAME)
	pass


# Class ----------------------------------
# SceneSignal for manage scene changes.
class SceneSignal:
	signal change_scene_requested(path: String, transition: String, use_sub_threads: bool)
	signal remove_old_scene_requested()
	signal set_new_scene_requested(path: String, resource: Resource)
