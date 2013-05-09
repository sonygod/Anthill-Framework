//AS3///////////////////////////////////////////////////////////////////////////
//
// Copyright 2012
//
////////////////////////////////////////////////////////////////////////////////
/**
 * Application entry point for AnthillExamples.
 * 
 * @langversion ActionScript 3.0
 * @playerversion Flash 9.0
 * 
 * @author Антон Карлов
 * @since 27.08.2012
 */
package ;
import flash.display.MovieClip;
import flash.events.Event;
import flash.display.Sprite;
import flash.Lib;
import ru.antkarlov.anthill.*;
import testdrive.*;


class AnthillExamples extends MovieClip {

	var _examples : Array<Dynamic>;
	var _curTest : Int;
	/**
	 * @constructor
	 */
	public function new() {
		super();
		trace("fuck!");
		((stage == null)) ? addEventListener(Event.ADDED_TO_STAGE, initialize) : initialize(null);
	}

	/**
	 * Initialize stub.
	 */
	function initialize(event : Event) : Void {
		if(event != null)  {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		startNow();
	}

	public function startNow() : Void {
		trace("AnthillExamples::initialize()");
		_examples = [    TestTween, TestAntActor, TestTaskManager, TestUI,TestTileMap];
		_curTest = 0;
		var engine : Anthill = new Anthill(_examples[_curTest], 60);
		addChild(engine);
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}

	/**
	 * @private
	 */
	function enterFrameHandler(event : Event) : Void {
		if(AntG.keys.isPressed("LEFT"))  {
			_curTest--;
			if(_curTest < 0)  {
				_curTest = _examples.length - 1;
			}
			trace( Std.is(_examples[_curTest], AntState));
			AntG.switchState(Type.createInstance(_examples[_curTest],[]));
		}

		else if (AntG.keys.isPressed("RIGHT"))  {
			
			_curTest++;
			if(_curTest >= _examples.length)  {
				_curTest = 0;
			}
			
			AntG.switchState(Type.createInstance(_examples[_curTest],[]));
		}
	}

}

