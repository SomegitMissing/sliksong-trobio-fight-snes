class_name StateMachine
extends LimboHSM


@export var first_state: LimboState;


var state_dict: Dictionary[StringName, LimboState] = {};
var current_state: LimboState = first_state;


func _ready() -> void:
	initial_state = first_state;
	current_state = first_state;

	var children: Array[Node] = get_children();
	if children.size() > 0 and initial_state == null:
		initial_state = children[0];

	for child in children:
		if not child is LimboState:
			continue;

		state_dict[child.name] = child;

	var parent := get_parent();

	await parent.ready;

	initialize(parent);
	set_active(true);


func set_state(state_name: StringName) -> void:
	assert(state_dict.has(state_name));

	var state := state_dict[state_name];
	if state == current_state:
		return;

	current_state = state_dict[state_name];
	change_active_state(current_state);


func current_state_name() -> String:
	return current_state.name;


func get_state_node(state_name: StringName) -> LimboState:
	assert(state_dict.has(state_name));
	return state_dict[state_name];
