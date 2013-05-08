import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.extensions.livinglights.*;

class MagicFly extends AntActor {
	@:isVar public var variety(never, set) : Int;

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	public var rotateSpeed : Float;
	public var moveSpeed : Float;
	public var targetX : Float;
	public var targetY : Float;
	public var light : AntLight;
	//---------------------------------------
	// PRIVATE VARIABLES
	//---------------------------------------
	var _mainAngle : Float;
	var _offsetAngle : Float;
	var _curAngle : Float;
	var _blink : Bool;
	var _blinkInterval : Float;
	var _particleInterval : Float;
	var _targetInterval : Float;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new() {
		super();
		addAnimationFromCache("MagicFly_mc");
		moveSpeed = AntMath.randomRangeNumber(0.5, 1.5);
		rotateSpeed = AntMath.randomRangeNumber(2, 5);
		targetX = 320;
		targetY = 240;
		_mainAngle = 0;
		_offsetAngle = 0;
		_curAngle = 0;
		_blink = false;
		_blinkInterval = AntMath.randomRangeInt(0.5, 1.5);
		_particleInterval = AntMath.randomRangeNumber(0.1, 0.3);
		_targetInterval = AntMath.randomRangeNumber(1, 2);
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**
	 * @inheritDoc
	 */
	override public function update() : Void {
		updateFly();
		updateBlink();
		updateTail();
		changeTarget();
		// Обработка выхода за пределы экрана.
		if(x < 0) x = 640;
		if(x > 640) x = 0;
		if(y < 0) y = 480;
		if(y > 480) y = 0;
		super.update();
	}

	/**
	 * @private
	 */
	function set_variety(value : Int) : Int {
		gotoAndStop(((value < 0)) ? 1 : ((value > 2)) ? 2 : value);
		return value;
	}

	//---------------------------------------
	// PRIVATE METHODS
	//---------------------------------------
	/**
	 * @private
	 */
	function updateFly() : Void {
		_mainAngle = AntMath.angleDeg(x, y, targetX, targetY);
		_offsetAngle = _curAngle - _mainAngle;
		// Нормализация угла.
		if(_offsetAngle > 180)  {
			_offsetAngle = -360 + _offsetAngle;
		}

		else if(_offsetAngle < -180)  {
			_offsetAngle = 360 + _offsetAngle;
		}
		if(Math.abs(_offsetAngle) < rotateSpeed)  {
			_curAngle -= _offsetAngle;
		}

		else if(_offsetAngle > 0)  {
			_curAngle -= rotateSpeed;
		}

		else  {
			_curAngle += rotateSpeed;
		}

		// Обновление векторной скорости согласно текущему углу.
		var rad : Float = AntMath.toRadians(_curAngle);
		x += moveSpeed * Math.cos(rad);
		y += moveSpeed * Math.sin(rad);
		// Обновление положения источника света вязанного с этим летуном.
		if(light != null)  {
			light.reset(x, y);
		}
	}

	/**
	 * @private
	 */
	function updateBlink() : Void {
		if(_blinkInterval <= 0)  {
			_blink = true;
		}

		else if(!_blink)  {
			_blinkInterval -= 2 * AntG.elapsed;
			if(alpha <= 1)  {
				alpha += 0.05;
			}
		}
		if(_blink)  {
			alpha -= 0.05;
			if(alpha <= 0)  {
				alpha = 0;
				_blink = false;
				_blinkInterval = AntMath.randomRangeInt(0.5, 1.5);
			}
		}
	}

	/**
	 * @private
	 */
	function updateTail() : Void {
		_particleInterval -= 2 * AntG.elapsed;
		if(_particleInterval <= 0)  {
			var p : Particle = try cast(parent.recycle(Particle), Particle) catch(e:Dynamic) null;
			p.switchAnimation(((currentFrame == 1)) ? "ParticlePurple_mc" : "ParticleYellow_mc");
			p.reset(x + AntMath.randomRangeInt(-5, 5), y + AntMath.randomRangeInt(-5, 5));
			p.revive();
			p.play();
			_particleInterval = AntMath.randomRangeNumber(0.1, 0.3);
		}
	}

	/**
	 * @private
	 */
	function changeTarget() : Void {
		_targetInterval -= 2 * AntG.elapsed;
		if(_targetInterval <= 0)  {
			targetX = x + AntMath.randomRangeInt(-10, 10);
			targetY = y + AntMath.randomRangeInt(-10, 10);
			_targetInterval = AntMath.randomRangeNumber(1, 2);
		}
	}

}

