@tool
extends Tree

var items = []
var checked_state ={}

@onready var root: = create_item()



func check_only(index:int):
#	get_root().propagate_check(0)
	for item in items:
		item = item as TreeItem
		item.set_checked(0, false)
	items[index].set_checked(0, true)


func _ready():
	await get_tree().process_frame
	items = get_item_children(root)
	
		
	set_column_expand(0, 0)
	set_column_expand(2, 0)


	update_checked()



	position.y = get_parent().size.y
	global_position.x = get_parent().global_position.x




func update_checked():
	checked_state.clear()
	for i in items.size():
		var item:TreeItem = items[i]
		checked_state[i] = item.is_checked(0)
			




func add_item(text:String, is_checked = true):
	var item:TreeItem = create_item(root)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_checked(0,is_checked)
	item.set_expand_right(0, false)

	item.set_text(1,text)
	item.set_expand_right(1, true)
	
	item.set_text(2,str(10))
	item.set_expand_right(2, false)
	item.set_text_alignment(2, HORIZONTAL_ALIGNMENT_RIGHT)


func _input(event):
	event = event as InputEventMouseButton
	if not event: return
	if not event.pressed: return
	if get_global_rect().has_point(get_global_mouse_position()): return
	hide()


func _on_item_selected():
	return


func _on_item_mouse_selected(position, mouse_button_index):
	var item:TreeItem = get_selected()
	var checked = item.is_checked(0)

	var idx = items.find(item)

	if mouse_button_index == 1:
		item.set_checked(0,!checked)
		checked_state[idx] = !checked
	elif mouse_button_index == 2:
		check_only(idx)
		for key in checked_state:
			checked_state[key] = false
		checked_state[idx] = true

	get_parent().emit_signal("item_toggle_checked")




func _on_item_activated():
	var item:TreeItem = get_selected()
#	item.set_checked(0,!item.is_checked(0))
	var checked = item.is_checked(0)
	item.set_checked(0,!checked)
	var idx = items.find(item)
	checked_state[idx] = !checked
	get_parent().emit_signal("item_toggle_checked")


static func get_item_children(item:TreeItem)->Array:
	item = item.get_first_child()
	var children = []
	while item:
		children.append(item)
		item = item.get_next()
	return children


