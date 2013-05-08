import ru.antkarlov.anthill.AntActor;

class Particle extends AntActor {

	/**
	 * @constructor
	 */
	public function new() {
		super();
		addAnimationFromCache("ParticlePurple_mc");
		addAnimationFromCache("ParticleYellow_mc");
		addAnimationFromCache("TinyFire_mc");
		eventComplete.add(killParticle);
	}

	/**
	 * @private
	 */
	function killParticle(aParticle : AntActor) : Void {
		aParticle.moves = false;
		aParticle.kill();
	}

}

