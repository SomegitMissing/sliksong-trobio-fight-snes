class_name Hornet
extends CharacterBody2D


# State and Animation
const SA_IDLE: StringName = &"Idle";
const SA_WALK: StringName = &"Walk";
const SA_JUMP: StringName = &"Jump";
const SA_GROUD_ATTACK: StringName = &"GroundAttack";
const SA_AIR_ATTACK: StringName = &"AirAttack";

# Animations
const ANIM_FALL: StringName = &"Fall";


@export var max_speed: float;
@export var fall_acceleration: float;
@export var jump_force: float;

@export_group("Nodes")
@export var state_machine: StateMachine;
@export var sprite: AnimatedSprite2D;


func _physics_process(delta: float) -> void:
	velocity.y += fall_acceleration * delta;

	move_and_slide();


func _apply_movement() -> void:
	var movement := Input.get_axis("ui_left", "ui_right");

	if movement != 0:
		sprite.flip_h = movement < 0;

	velocity.x = movement * max_speed;


func _idle_entered() -> void:
	sprite.play(SA_IDLE);


func _idle_updated(_delta: float) -> void:
	_apply_movement();

	if Input.is_action_just_pressed("jump"):
		state_machine.set_state(SA_JUMP);
		return;

	if Input.is_action_just_pressed("attack"):
		state_machine.set_state(SA_GROUD_ATTACK);
		return;

	if velocity.x != 0:
		state_machine.set_state(SA_WALK);


func _walk_entered() -> void:
	sprite.play(SA_WALK);


func _walk_updated(_delta: float) -> void:
	_apply_movement();

	if Input.is_action_just_pressed("jump"):
		state_machine.set_state(SA_JUMP);
		return;

	if Input.is_action_just_pressed("attack"):
		state_machine.set_state(SA_GROUD_ATTACK);
		return;

	if velocity.x == 0:
		state_machine.set_state(SA_IDLE);


func _jump_entered() -> void:
	if sprite.animation != ANIM_FALL:
		sprite.play(SA_JUMP);
		velocity.y = jump_force * -1;


func _jump_updated(_delta: float) -> void:
	_apply_movement();

	if Input.is_action_just_pressed("attack"):
		state_machine.set_state(SA_AIR_ATTACK);
		return;

	if is_on_floor():
		if velocity.x == 0:
			state_machine.set_state(SA_IDLE);
		else:
			state_machine.set_state(SA_WALK);

		return;

	if velocity.y >= 0 and sprite.animation != ANIM_FALL:
		await sprite.animation_looped;
		sprite.play(ANIM_FALL);


func _ground_attack_entered() -> void:
	velocity.x = 0;
	sprite.play(SA_GROUD_ATTACK);

	await sprite.animation_finished;
	state_machine.set_state(SA_IDLE);


func _air_attack_entered() -> void:
	sprite.play(SA_AIR_ATTACK);

	await sprite.animation_finished;

	sprite.play(ANIM_FALL);
	state_machine.set_state(SA_JUMP);
