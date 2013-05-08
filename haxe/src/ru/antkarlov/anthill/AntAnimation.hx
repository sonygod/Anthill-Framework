/**
 * Данный класс используется для растеризации векторных клипов и для последующего их хранения в памяти.
 * 
 * <p>Воспроизведением и отрисовкой анимаций занимается класс <code>AntActor</code>. Так же в данном классе
 * реализован кэш анимаций который позволяет хранить уникальные экземпляры анимаций для многократного одновременного
 * использования.</p>
 * 
 * <p>Класс реализован на основе класса от Scmorr (http://flashgameblogs.ru/blog/actionscript/667.html).</p>
 * 
 * @see	AntActor Класс для воспроизведения и рендера анимаций.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  20.08.2012
 */
package ru.antkarlov.anthill;

import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class AntAnimation {

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	static var INDENT_FOR_FILTER : Int = 64;
	static var INDENT_FOR_FILTER_DOUBLED : Int = INDENT_FOR_FILTER * 2;
	static var DEST_POINT : Point = new Point();
	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**
	 * Глобальное имя анимации.
	 */
	public var name : String;
	/**
	 * Массив кадров.
	 */
	public var frames : Vector<BitmapData>;
	/**
	 * Массив смещений по X для каждого из кадров анимации.
	 */
	public var offsetX : Vector<Float>;
	/**
	 * Массив смещений по Y для каждого из кадров анимации.
	 */
	public var offsetY : Vector<Float>;
	/**
	 * Общее количество кадров анимации.
	 */
	public var totalFrames : Int;
	/**
	 * Максимальная ширина кадров анимации.
	 */
	public var width : Int;
	/**
	 * Максимальная высота кадров анимации.
	 */
	public var height : Int;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new(aName : String = "noname") {
		//super()
		name = aName;
		frames = new Vector<BitmapData>();
		offsetX = new Vector<Float>();
		offsetY = new Vector<Float>();
		totalFrames = 0;
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**
	 * Уничтожает анимацию.
	 */
	public function destroy() : Void {
		var bmpd : BitmapData;
		var i : Int = 0;
		var n : Int = frames.length;
		while(i < n) {
			bmpd = try cast(frames[i], BitmapData) catch(e:Dynamic) null;
			if(bmpd != null)  {
				bmpd.dispose();
			}
			frames[i] = null;
			i++;
		}

		frames.length = 0;
		offsetY.length = 0;
		offsetY.length = 0;
	}

	/**
	 * Создает растровую однокадровую анимацию из указанного спрайта.
	 * 
	 * @param	aSprite	 Спрайт из которого необходимо создать растровую анимацию.
	 */
	public function makeFromSprite(aSprite : Sprite) : Void {
		totalFrames = 1;
		var rect : Rectangle;
		var flooredX : Int;
		var flooredY : Int;
		var mtx : Matrix = new Matrix();
		var scratchBitmapData : BitmapData = null;
		rect = aSprite.getBounds(aSprite);
		rect.width = Math.ceil(rect.width) + INDENT_FOR_FILTER_DOUBLED;
		rect.height = Math.ceil(rect.height) + INDENT_FOR_FILTER_DOUBLED;
		flooredX = Math.floor(rect.x) - INDENT_FOR_FILTER;
		flooredY = Math.floor(rect.y) - INDENT_FOR_FILTER;
		mtx.tx = -flooredX;
		mtx.ty = -flooredY;
		scratchBitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0);
		scratchBitmapData.draw(aSprite, mtx);
		var trimBounds : Rectangle = scratchBitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
		trimBounds.x -= 1;
		trimBounds.y -= 1;
		trimBounds.width += 2;
		trimBounds.height += 2;
		var bmpData : BitmapData = new BitmapData(Std.int(trimBounds.width), Std.int(trimBounds.height), true, 0);
		bmpData.copyPixels(scratchBitmapData, trimBounds, DEST_POINT);
		flooredX += Std.int(trimBounds.x);
		flooredY += Std.int(trimBounds.y);
		frames.push(bmpData);
		offsetX.push(flooredX);
		offsetY.push(flooredY);
		width = ((width < Std.int(trimBounds.width))) ? Std.int(trimBounds.width) : width;
		height = ((height < Std.int(trimBounds.height))) ? Std.int(trimBounds.height) : height;
		scratchBitmapData.dispose();
	}

	/**
	 * Создает растровую анимацию из указанного клипа.
	 * 
	 * @param	aClip	 Клип из которого необходимо создать растровую анимацию.
	 */
	public function makeFromMovieClip(aClip : MovieClip) : Void {
		totalFrames = aClip.totalFrames;
		var rect : Rectangle;
		var flooredX : Int;
		var flooredY : Int;
		var mtx : Matrix = new Matrix();
		var scratchBitmapData : BitmapData = null;
		var i : Int = 1;
		while(i <= totalFrames) {
			rect = aClip.getBounds(aClip);
			rect.width = Math.ceil(rect.width) + INDENT_FOR_FILTER_DOUBLED;
			rect.height = Math.ceil(rect.height) + INDENT_FOR_FILTER_DOUBLED;
			flooredX = Math.floor(rect.x) - INDENT_FOR_FILTER;
			flooredY = Math.floor(rect.y) - INDENT_FOR_FILTER;
			mtx.tx = -flooredX;
			mtx.ty = -flooredY;
			scratchBitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0);
			scratchBitmapData.draw(aClip, mtx);
			var trimBounds : Rectangle = scratchBitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			trimBounds.x -= 1;
			trimBounds.y -= 1;
			trimBounds.width += 2;
			trimBounds.height += 2;
			var bmpData : BitmapData = new BitmapData(Std.int(trimBounds.width), Std.int(trimBounds.height), true, 0);
			bmpData.copyPixels(scratchBitmapData, trimBounds, DEST_POINT);
			flooredX += Std.int(trimBounds.x);
			flooredY += Std.int(trimBounds.y);
			frames.push(bmpData);
			offsetX.push(flooredX);
			offsetY.push(flooredY);
			width = ((width < Std.int(trimBounds.width))) ? Std.int(trimBounds.width) : width;
			height = ((height < Std.int(trimBounds.height))) ? Std.int(trimBounds.height) : height;
			scratchBitmapData.dispose();
			aClip.gotoAndStop(++i);
			childNextFrame(aClip);
		}

	}

	/**
	 * Создает анимацию из изображения.
	 * 
	 * @param	aGraphic	 Класс растрового изображения.
	 * @param	aFrameWidth	 Размер кадра по ширине.
	 * @param	aFrameHeight	 Размер кадра по высоте.
	 * @param	aOriginX	 Смещение кадров относительно центра координат по X.
	 * @param	aOriginY	 Смещение кадров относительно центра координат по Y.
	 * @param	aFlip	 Определяет необходимость зеркального отражения кадров по горизонтали.
	 */
	public function makeFromGraphic(aGraphic : Class<Dynamic>, aFrameWidth : Int = 0, aFrameHeight : Int = 0, aOriginX : Int = 0, aOriginY : Int = 0, aFlip : Bool = false) : Void {
		var pixels : BitmapData = Type.createInstance(aGraphic, []).bitmapData;
		if(aFlip)  {
			var newPixels : BitmapData = new BitmapData(pixels.width, pixels.height, true, 0x00000000);
			var mtx : Matrix = new Matrix();
			mtx.scale(-1, 1);
			mtx.translate(newPixels.width, 0);
			newPixels.draw(pixels, mtx);
			pixels = newPixels;
		}
		if(aFrameWidth > 0 || aFrameHeight > 0)  {
			aFrameWidth = ((aFrameWidth <= 0)) ? pixels.width : aFrameWidth;
			aFrameHeight = ((aFrameHeight <= 0)) ? pixels.height : aFrameHeight;
			var numFramesX : Int = Math.floor(pixels.width / aFrameWidth);
			var numFramesY : Int = Math.floor(pixels.height / aFrameHeight);
			var rect : Rectangle = new Rectangle();
			rect.x = rect.y = 0;
			rect.width = aFrameWidth;
			rect.height = aFrameHeight;
			var n : Int = numFramesX * numFramesY;
			var i : Int = 0;
			while(i < n) {
				rect.y = Math.floor(i / numFramesX);
				rect.x = i - rect.y * numFramesX;
				rect.x *= aFrameWidth;
				rect.y *= aFrameHeight;
				var bmpData : BitmapData = new BitmapData(aFrameWidth, aFrameHeight, true, 0x00000000);
				bmpData.copyPixels(pixels, rect, DEST_POINT);
				//(aFlip) ? frames[n-i-1] = bmpData : frames[i] = bmpData;
				frames.push(bmpData);
				offsetX.push(aOriginX);
				offsetY.push(aOriginY);
				i++;
			}

			width = aFrameWidth;
			height = aFrameHeight;
		}

		else  {
			frames.push(pixels);
			offsetX.push(aOriginX);
			offsetY.push(aOriginY);
			width = pixels.width;
			height = pixels.height;
		}

		totalFrames = frames.length;
	}

	/**
	 * Создает дубликат текущей анимации только с указанными кадрами.
	 * 
	 * @param	aFrames	 Номера кадров которые необходимо включить в новую анимацию.
	 * @param	aName	 Имя новой анимации, если не указано, то будет использовано имя оригинальной анимации.
	 * @param	aCopy	 Если true то будут созданы новые экземпляры кадров, иначе будут использоваться указатели на кадры из оригинальной анимации.
	 * @return		Возвращает новый экземпляр текущей анимации (дубликат).
	 */
	public function dublicateWithFrames(aFrames : Array<Dynamic>, aName : String = null, aCopy : Bool = false) : AntAnimation {
		var newAnim : AntAnimation = new AntAnimation(((aName == null)) ? name : aName);
		newAnim.width = width;
		newAnim.height = height;
		newAnim.totalFrames = aFrames.length;
		var rect : Rectangle = new Rectangle();
		var origBmp : BitmapData;
		var newBmp : BitmapData;
		var i : Int = 0;
		var n : Int = aFrames.length;
		while(i < n) {
			if(aCopy)  {
				origBmp = try cast(frames[i], BitmapData) catch(e:Dynamic) null;
				rect.x = rect.y = 0;
				rect.width = origBmp.width;
				rect.height = origBmp.height;
				newBmp = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0);
				newBmp.copyPixels(origBmp, rect, DEST_POINT);
				newAnim.frames.push(newBmp);
			}

			else  {
				newAnim.frames.push(frames[i]);
			}

			newAnim.offsetX.push(offsetX[i]);
			newAnim.offsetY.push(offsetY[i]);
			i++;
		}

		return newAnim;
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**
	 * Переводит на один кадр вперед указанный клип.
	 * 
	 * @param	aClip	 Для которого необходимо переключить текущий кадр.
	 */
	function childNextFrame(aClip : MovieClip) : Void {
		var childClip : MovieClip;
		var i : Int = 0;
		var n : Int = aClip.numChildren;
		while(i < n) {
			childClip = try cast(aClip.getChildAt(i), MovieClip) catch(e:Dynamic) null;
			if(childClip != null)  {
				childNextFrame(childClip);
				childClip.nextFrame();
			}
			i++;
		}

	}

	//---------------------------------------
	// ANIMATION CACHE
	//---------------------------------------
	/**
	 * Кэш анимаций.
	 */
	static var _animationCache : AntStorage = new AntStorage();
	/**
	 * Помещает анимацию в кэш.
	 * 
	 * @param	aAnim	 Анимация которую необходимо поместить в кэш.
	 * @param	aKey	 Имя под которой анимация будет доступна в кэше. Если имя не указана, то будет использовано имя из анимации.
	 */
	static public function toCache(aAnim : AntAnimation, aKey : String = null) : AntAnimation {
		_animationCache.set(((aKey == null)) ? aAnim.name : aKey, aAnim);
		return aAnim;
	}

	/**
	 * Извлекает анимацию из кэша.
	 * 
	 * @param	aKey	 Имя анимации которую необходимо извлечь из кэша.
	 */
	static public function fromCache(aKey : String) : AntAnimation {
		if(!_animationCache.containsKey(aKey))  {
			throw new flash.errors.Error("AntAnimation: Missing animation '" + aKey + "'.");
		}
		return try cast(_animationCache.get(aKey), AntAnimation) catch(e:Dynamic) null;
	}

	/**
	 * Удаляет анимацию из кэша анимаций.
	 * 
	 * @param	aKey	 Имя анимации которую необходимо удалить.
	 */
	static public function removeFromCache(aKey : String) : Void {
		if(_animationCache.containsKey(aKey))  {
			(try cast(_animationCache.get(aKey), AntAnimation) catch(e:Dynamic) null).destroy();
			_animationCache.remove(aKey);
		}
	}

	/**
	 * Удаляет все анимации из кэша анимаций.
	 */
	public function clearCache() : Void {
		var anim : AntAnimation;
		for(value in  Reflect.fields(_animationCache)) {
			if(Reflect.field(_animationCache, value) != null)  {
				anim = try cast(_animationCache.remove(value), AntAnimation) catch(e:Dynamic) null;
				if(anim != null)  {
					anim.destroy();
				}
			}
		}

	}

}

