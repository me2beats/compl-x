@tool
extends Button

@onready var tree: = $Tree

signal item_toggle_checked

func is_checked(idx:int):
	return tree.checked_state[idx]

func _pressed():
	tree.visible = !tree.visible

func fill(items:Array):
	for item in items:
		tree.add_item(item)

	


