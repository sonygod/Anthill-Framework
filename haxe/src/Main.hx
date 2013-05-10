package ;


import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import msignal.Signal;

/**
 * ...
 * @author sonygod
 */

class Main {


	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		
		
		
		
		stage.addChild(new AnthillExamples());
		//stage.addChild(new LivingLights());
		
		signalWithOneArg();
		
	}
	
	static function signalWithOneArg()
	{
		var completed = new Signal1(String);
		completed.add(function (e):Void { trace("okkk"); } );
		completed.dispatch("hello");
	}
	
	
	
}

