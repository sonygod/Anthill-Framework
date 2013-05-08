import ru.antkarlov.anthill.AntPreloader;

class ExamplePreloader extends AntPreloader {

	public function new() {
		super();
		entryClass = "AnthillExamples";
	}

	/**
	 * @private
	 */
	override public function update(aPercent : Float) : Void {
		super.update(aPercent);
		trace("Loading:", aPercent * 100);
	}

	/**
	 * @private
	 */
	override public function completed() : Void {
		super.completed();
		trace("Loading is completed!");
	}

}

