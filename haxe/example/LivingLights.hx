//AS3///////////////////////////////////////////////////////////////////////////
//
// Copyright 2013
//
////////////////////////////////////////////////////////////////////////////////
/**
 * Application entry point for LivingLights.
 * 
 * @langversion ActionScript 3.0
 * @playerversion Flash 9.0
 * 
 * @author Антон Карлов
 * @since 26.04.2013
 */
import flash.events.Event;
import flash.display.Sprite;
import flash.display.StageQuality;

import ru.antkarlov.anthill.Anthill;


class LivingLights extends Sprite {

	/**
	 * @constructor
	 */
	public function new() {
		super();
		((stage == null)) ? addEventListener(Event.ADDED_TO_STAGE, initialize) : initialize(null);
	}

	/**
	 * Initialize stub.
	 */
	function initialize(event : Event) : Void {
		if(event != null)  {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		stage.quality = StageQuality.LOW;
		var engine : Anthill = new Anthill(StateLights, 60);
		addChild(engine);
	}

}

