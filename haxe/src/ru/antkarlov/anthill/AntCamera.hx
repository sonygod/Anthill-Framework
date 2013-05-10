/**

 * Реализует рендеринг всех визуальных сущностей.

 * 

 * <p>Чтобы реализовать перемещение камеры (скролл уровней), используйте атрибут <code>scroll</code>

 * для перемещения камеры в игровом мире.</p>

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Anton Karlov

 * @since  29.08.2012

 */
package ru.antkarlov.anthill;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
import ru.antkarlov.anthill.AntCamera;
import ru.antkarlov.anthill.AntCamera;
using Reflect;

class AntCamera extends AntBasic {

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	/**

	 * Стиль слежения камеры: свободный стиль, по X и Y.

	 */
	static public var STYLE_FREELY : UInt = 0;
	/**

	 * Стиль слежения камеры: горизонтальный, только по X.

	 */
	static public var STYLE_HORIZONTAL : UInt = 1;
	/**

	 * Стиль слежения камеры: вертикальный, только по Y.

	 */
	static public var STYLE_VERTICAL : UInt = 2;
	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**

	 * Положение камеры на экране Flash окна по X.

	 */
	public var x : Float;
	/**

	 * Положение камеры на экране Flash окна по Y.

	 */
	public var y : Float;
	/**

	 * Размер окна камеры по ширине.

	 */
	public var width : Int;
	/**

	 * Размер окна камеры по высоте.

	 */
	public var height : Int;
	/**

	 * Флаг определяющий следует ли выполнять заливку цветом в буфер камеры перед рендером объектов.

	 * @default	false

	 */
	public var fillBackground : Bool;
	/**

	 * Цвет заливки.

	 * @default	0xFF000000

	 */
	public var backgroundColor : UInt;
	/**

	 * Содержит смещение камеры относительно игрового мира.

	 * Чтобы прокручивать игровые миры, достаточно менять значения <code>scroll.x</code> и <code>scroll.y</code>.

	 * @default	(0,0)

	 */
	public var scroll : AntPoint;
	/**

	 * Основной буфер камеры куда производится отрисовка всех визуальных объектов.

	 */
	public var buffer : BitmapData;
	/**

	 * Фактор увеличения изображения.

	 * @default	1

	 */
	public var zoom : Int;
	/**

	 * Прямоугольник задающий границы для перемещения камеры.

	 * @default	null

	 */
	public var bounds : AntRect;
	/**

	 * Цель которую приследует камера.

	 * @default	null

	 */
	public var target : AntEntity;
	/**

	 * Стиль слежения за объектом.

	 * @default	STYLE_FREELY

	 */
	public var followStyle : UInt;
	/**

	 * Фактор опережения камеры при движении за целью.

	 * @default	8

	 */
	public var leadingFactor : Float;
	/**

	 * Фактор отставания камеры при движении за целью.

	 * @default	0.25

	 */
	public var smoothFactor : Float;
	/**

	 * Свойство цели для преследования которое используется для определения его позиции по X.

	 * @default	"globalX"

	 */
	public var positionPropertyX : String;
	/**

	 * Свойство цели для преследования которое используется для определения его позиции по X.

	 * @default	"globalY"

	 */
	public var positionPropertyY : String;
	/**

	 * Определяет следует ли при преследовании цели округлять координаты камеры.

	 * @default	false

	 */
	public var roundToIntPosition : Bool;
	/**

	 * Центр экрана.

	 */
	public var screenCenter : AntPoint;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * Помшник для заливки буфера камеры цветом.

	 */
	var _flashRect : Rectangle;
	/**

	 * Битмап для вывода буффера камеры на экран стандартными средствами Flash.

	 */
	var _flashBitmap : Bitmap;
	public var _flashSprite : Sprite;
	/**

	 * Помошник для рассчета новой позиции камеры.

	 */
	var _newPos : AntPoint;
	public var _isMasked : Bool;
	public var _maskOffset : AntPoint;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new(aX : Float, aY : Float, aWidth : Int, aHeight : Int, aZoom : Int = 1) {
		super();
		x = aX;
		y = aY;
		width = aWidth;
		height = aHeight;
		fillBackground = false;
		backgroundColor = 0xFF000000;
		scroll = new AntPoint();
		zoom = aZoom;
		bounds = null;
		buffer = new BitmapData(width, height, true, backgroundColor);
		_flashBitmap = new Bitmap(buffer);
		_flashBitmap.scaleX = _flashBitmap.scaleY = zoom;
		_flashBitmap.x = -width * 0.5;
		_flashBitmap.y = -height * 0.5;
		screenCenter = new AntPoint(width * 0.5 * zoom, height * 0.5 * zoom);
		_flashSprite = new Sprite();
		_flashSprite.x = x + screenCenter.x;
		_flashSprite.y = y + screenCenter.y;
		_flashSprite.addChild(_flashBitmap);
		_flashRect = new Rectangle(0, 0, aWidth, aHeight);
		_newPos = new AntPoint();
		target = null;
		followStyle = STYLE_FREELY;
		leadingFactor = 8;
		smoothFactor = 0.25;
		positionPropertyX = "globalX";
		positionPropertyY = "globalY";
		roundToIntPosition = false;
		_isMasked = false;
		_maskOffset = new AntPoint();
	}

	/**

	 * Уничтожает экземпляр камеры и осовобождает память.

	 */
	override public function destroy() : Void {
		target = null;
		AntG.removeCamera(this);
		buffer.dispose();
		buffer = null;
		if(_flashSprite.contains(_flashBitmap))  {
			_flashSprite.removeChild(_flashBitmap);
		}
		_flashBitmap = null;
		if(_flashSprite.parent != null)  {
			_flashSprite.parent.removeChild(_flashSprite);
		}
		_flashSprite = null;
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Устанавливает цель за которой будет выполнятся слежение.

	 * 

	 * @param	aTarget	 Цель за которой будет выполнятся слежение.

	 * @param	aStyle	 Стиль слежения.

	 */
	public function follow(aTarget : AntEntity, aStyle : UInt = 0) : Void {
		target = aTarget;
		followStyle = aStyle;
	}

	/**

	 * Моментальное перемещение камеры к указанной позиции.

	 * 

	 * @param	aPoint	 Точка к которой будет перемещена камера.

	 */
	public function focusOn(aPoint : AntPoint) : Void {
		aPoint.x += ((aPoint.x > 0)) ? 0.0000001 : -0.0000001;
		aPoint.y += ((aPoint.y > 0)) ? 0.0000001 : -0.0000001;
		_newPos.set(-(aPoint.x - width) - screenCenter.x, -(aPoint.y - height) - screenCenter.y);
		if(bounds != null)  {
			_newPos.x = limitByX(_newPos.x);
			_newPos.y = limitByY(_newPos.y);
		}
		scroll.x = _newPos.x;
		scroll.y = _newPos.y;
	}

	/**

	 * Устанавливает ограничение для перемещения камеры.

	 * 

	 * @param	aLowerX	 Минимально допустимая позиция камеры по X (обычно это 0).

	 * @param	aLowerY	 Минимально допустимая позиция камеры по Y (обычно это 0).

	 * @param	aUpperX	 Максимально допустимая позиция камеры по X (обычно это ширина уровня).

	 * @param	aUpperY	 Максимально допустимая позиция камеры по Y (обычно это высота уровня).

	 */
	public function setBounds(aLowerX : Int, aLowerY : Int, aUpperX : Int, aUpperY : Int) : Void {
		if(bounds == null)  {
			bounds = new AntRect();
		}
		bounds.set(aLowerX, aLowerY, aUpperX, aUpperY);
		update();
	}

	/**

	 * Обработка действий камеры.

	 */
	override public function update() : Void {
		if(target != null)  {
			switch(followStyle) {
			case AntCamera.STYLE_FREELY:
				_newPos.x = (scroll.x - (-target.field(positionPropertyX) + screenCenter.x - (target.velocity.x * AntG.elapsed) * leadingFactor)) * smoothFactor;
				_newPos.y = (scroll.y - (-target.field(positionPropertyY) + screenCenter.y - (target.velocity.y * AntG.elapsed) * leadingFactor)) * smoothFactor;
			case AntCamera.STYLE_HORIZONTAL:
				_newPos.x = (scroll.x - (-target.field(positionPropertyX) + screenCenter.x - (target.velocity.x * AntG.elapsed) * leadingFactor)) * smoothFactor;
			case AntCamera.STYLE_VERTICAL:
				_newPos.y = (scroll.y - (-target.field(positionPropertyY)+ screenCenter.y - (target.velocity.y * AntG.elapsed) * leadingFactor)) * smoothFactor;
			}
			if(roundToIntPosition)  {
				_newPos.x += ((_newPos.x > 0)) ? 0.0000001 : -0.0000001;
				_newPos.y += ((_newPos.y > 0)) ? 0.0000001 : -0.0000001;
				_newPos.set(scroll.x - AntMath.ceil(_newPos.x), scroll.y - AntMath.ceil(_newPos.y));
			}

			else  {
				_newPos.set(scroll.x - _newPos.x, scroll.y - _newPos.y);
			}

			if(bounds != null)  {
				_newPos.x = limitByX(_newPos.x);
				_newPos.y = limitByY(_newPos.y);
			}
			scroll.x = _newPos.x;
			scroll.y = _newPos.y;
		}

		else if(bounds != null)  {
			scroll.x = limitByX(scroll.x);
			scroll.y = limitByY(scroll.y);
		}
	}

	/**

	 * Отрисовка буфера камеры на экран.

	 */
	/*public function draw():void

	{

	buffer.unlock();

	buffer.lock();

	

	if (fillBackground)

	{

	buffer.fillRect(_flashRect, backgroundColor);

	}

	}*/
	/**

	 * @private

	 */
	public function beginDraw() : Void {
		buffer.lock();
		if(fillBackground)  {
			buffer.fillRect(_flashRect, backgroundColor);
		}
	}

	/**

	 * @private

	 */
	public function endDraw() : Void {
		buffer.unlock();
	}

	/**

	 * Определяет начало отрисовки сущности использующей маску.

	 * 

	 * @param	aMask	 Указатель на маску которая будет временно применена к камере.

	 */
	public function beginDrawMask(aMask : AntMask) : Void {
		if(!_isMasked)  {
			buffer = aMask.buffer;
			_maskOffset.set(aMask.globalX, aMask.globalY);
			_isMasked = true;
		}
	}

	/**

	 * Определяет окончание отрисовки сущности использующей маску.

	 * 

	 * @param	aMask	 Указатель на маску которая ранее была применена к камере.

	 */
	public function endDrawMask(aMask : AntMask) : Void {
		if(_isMasked)  {
			buffer = _flashBitmap.bitmapData;
			aMask.drawTo(buffer);
			_isMasked = false;
		}
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * Ограничивает значение по горизонтали согласно заданным границам.

	 * 

	 * @param	aValue	 Новая позиция по горизонтали.

	 * @return		Если новая позиция вышла за пределы границы, то вернет крайнюю доступную позицию.

	 */
	function limitByX(aValue : Float) : Float {
		if(aValue > bounds.left)  {
			aValue = bounds.left;
		}

		else if(AntMath.abs(aValue) > bounds.right - width)  {
			aValue = -(bounds.right - width);
		}
		return aValue;
	}

	/**

	 * Ограничивает значение по вертикали согласно заданным границам.

	 * 

	 * @param	aValue	 Новая позиция по вертикали.

	 * @return		Если новая позиция вышла за пределы границы, то вернет крайнюю доступную позицию.

	 */
	function limitByY(aValue : Float) : Float {
		if(aValue > bounds.top)  {
			aValue = bounds.top;
		}

		else if(AntMath.abs(aValue) > bounds.bottom - height)  {
			aValue = -(bounds.bottom - height);
		}
		return aValue;
	}

}

