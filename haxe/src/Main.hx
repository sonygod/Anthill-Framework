package ;


import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;


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
	}
	
	
	
}

