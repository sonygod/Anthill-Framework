package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import ru.antkarlov.anthill.AntEntity;
import flash.display.MovieClip;
import ru.antkarlov.anthill.AntG;

/**
 * ...
 * @author sonygod
 */

class Main 
{
	var xxx:AntEntity;
	var xx:AntG;

	//@internal var yyy:String;
	// @:internal static var yyy2:String;
	function new () {
		
	}
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		
		
		 new AnthillExamples();
		
		
		
	}
	
	
	
}

