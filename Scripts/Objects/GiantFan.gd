class_name GiantFan extends Node2D

static var _retract_offsets_cache: Dictionary = {}

var _retract_offset: float = 0.0

var activated: bool = false

func _ready() -> void:
	var frames: SpriteFrames = $Sprite.sprite_frames
	if frames in _retract_offsets_cache:
		_retract_offset = _retract_offsets_cache[frames]
	else:
		for i in frames.get_frame_count("default"):
			_retract_offset = minf(_retract_offset, -frames.get_frame_texture("default", i).get_height())
		_retract_offsets_cache[frames] = _retract_offset
	$Sprite.offset.y = _retract_offset
	$Sprite.stop()

func _physics_process(delta) -> void:
	$Sprite.offset.y = move_toward($Sprite.offset.y, 0.0 if activated else _retract_offset, delta * 60.0 * 8.0)

func activate() -> void:
	if activated:
		return
	
	activated = true
	$Shutter.play()

	var physics_frame: Signal = get_tree().physics_frame
	while $Sprite.offset.y != 0.0:
		await physics_frame

	$BigFan.play()
	$Sprite.play("default")

func deactivate() -> void:
	if not activated:
		return
	
	$Shutter.play()
	$BigFan.stop()
	$Sprite.stop()
	activated = false
