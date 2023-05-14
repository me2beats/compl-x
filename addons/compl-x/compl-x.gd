@tool
extends EditorPlugin

var code_completion_control:Control

var script_editor:ScriptEditor

var editor_settings:EditorSettings = get_editor_interface().get_editor_settings()

const code_complete_delay_path = "text_editor/completion/code_complete_delay"
var code_complete_delay = editor_settings.get_setting(code_complete_delay_path) # defined_by_user

var code_complete_timer:=Timer.new()

const some_long_time = 60


func sec(seconds):
	return get_tree().create_timer(seconds).timeout

func _enter_tree():
	code_completion_control = preload("res://addons/compl-x/control.tscn").instantiate()
	code_completion_control.visible = false
	
	code_completion_control.plugin = self
	
	get_editor_interface().get_base_control().add_child(code_completion_control)
	
	
	add_child(code_complete_timer)
	
	editor_settings.set_setting(code_complete_delay_path, some_long_time)

	script_editor = get_editor_interface().get_script_editor()
	var code_edit:CodeEdit = script_editor.get_current_editor().get_base_editor()
	
	if not code_edit: return
	script_editor.connect("editor_script_changed", on_code_edit_change)
	on_code_edit_change()
	
func _exit_tree():
	code_completion_control.queue_free()
	editor_settings.set_setting(code_complete_delay_path, code_complete_delay)
	code_complete_timer.stop()



func _input(event):
	event = event as InputEventKey
	if not event: return
	if event.keycode == KEY_SPACE and event.pressed and event.is_command_or_control_pressed():
		var script_editor: = get_editor_interface().get_script_editor()
		var code_edit = script_editor.get_current_editor().get_base_editor()

		code_edit = code_edit as CodeEdit
		if not code_edit: return

		if !code_edit.has_focus(): return
		get_viewport().set_input_as_handled()

		code_completion_control.request_completion(false)
		
 

	if Input.is_action_just_pressed("ui_cancel"):
		code_completion_control.hide()

func on_code_edit_change(script = null):
	var code_edit = script_editor.get_current_editor().get_base_editor()
	if not code_edit: return
	code_completion_control.code_edit = code_edit
	if !code_edit.is_connected("text_changed", on_text):
		code_edit.connect("text_changed",on_text)
	if !code_edit.is_connected("caret_changed", on_caret):
		code_edit.connect("caret_changed", on_caret)

func on_text():
	code_completion_control.request_completion()
	
	
func on_caret():
	if ! code_completion_control.visible: return
	code_completion_control.request_completion()
	
