import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.extensions.livinglights.AntLight;

class Torch extends AntActor {

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	public var light : AntLight;
	var _fireInterval : Float;
	/**
	 * @constructor
	 */
	public function new() {
		super();
		addAnimationFromCache("Torch_mc");
		_fireInterval = 0.25;
	}

	/**
	 * @private
	 */
	override public function update() : Void {
		_fireInterval -= 2 * AntG.elapsed;
		if(_fireInterval <= 0)  {
			makeParticle();
			_fireInterval = AntMath.randomRangeNumber(0.1, 0.25);
		}
		super.update();
	}

	/**
	 * @private
	 */
	function makeParticle() : Void {
		var p : Particle = try cast(this.recycle(Particle), Particle) catch(e:Dynamic) null;
		p.reset(AntMath.randomRangeInt(-2, 2), AntMath.randomRangeInt(1, 3));
		p.velocity.y = -AntMath.randomRangeNumber(30, 50);
		p.moves = true;
		p.scaleX = ((AntMath.randomRangeInt(0, 1) == 0)) ? -1 : 1;
		p.switchAnimation("TinyFire_mc");
		p.play();
		p.revive();
		if(light != null)  {
			light.reset(x + p.x, y + p.y);
		}
	}

}

