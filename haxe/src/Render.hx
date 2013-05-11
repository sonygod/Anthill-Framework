package ;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.ColorTransform;
import flash.display.IBitmapDrawable;
import flash.geom.Rectangle;
import flash.display.BlendMode;
import flash.geom.Matrix;

/**
 * ...
 * @author sonygod
 */
class Render
{

	
	/**
	 * ready for rewrite use stage3d 
	 * @param	baseBitmapdata
	 * @param	sourceBitmapData
	 * @param	sourceRect
	 * @param	destPoint
	 * @param	alphaBitmapData
	 * @param	alphaPoint
	 * @param	mergeAlpha
	 */
 	inline static public function copyPixels2(baseBitmapdata:BitmapData,sourceBitmapData:BitmapData, sourceRect:flash.geom.Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Bool = false):Void {
		
		 baseBitmapdata.copyPixels(sourceBitmapData, sourceRect, destPoint, alphaBitmapData, alphaPoint, mergeAlpha);
	}
	
	/**ready for rewrite use stage3d 
	 * 
	 * @param	baseBitmapdata
	 * @param	source
	 * @param	matrix
	 * @param	colorTransform
	 * @param	blendMode
	 * @param	clipRect
	 * @param	smoothing
	 */
	inline  static public function draw2(baseBitmapdata:BitmapData, source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null, clipRect:Rectangle = null, smoothing:Bool = false):Void {
		
		 baseBitmapdata.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
	}
	
}