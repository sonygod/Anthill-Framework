/**

 * Обычная текстовая метка используется для отображения текстовой информации.

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  23.08.2012

 */
package ru.antkarlov.anthill;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
using Lambda;

class AntLabel extends AntEntity {
	@:isVar public var bold(get, set) : Bool;
	@:isVar public var text(get, set) : String;
	@:isVar public var autoSize(get, set) : Bool;
	@:isVar public var wordWrap(get, set) : Bool;
	@:isVar public var align(get, set) : String;
	@:isVar public var alpha(get, set) : Float;
	@:isVar public var color(get, set) : UInt;
	@:isVar public var numChars(get, never) : Int;
	@:isVar public var numLines(get, never) : Int;

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	static public var LEFT : String = "left";
	static public var RIGHT : String = "right";
	static public var CENTER : String = "center";
	static public var JUSTIFY : String = "justify";
	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**

	 * Режим смешивания цветов.

	 * @default	null

	 */
	public var blend : String;
	/**

	 * Сглаживание.

	 * @default	true

	 */
	public var smoothing : Bool;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * Стандартное текстовое поле которое используется для растеризации текста.

	 */
	var _textField : TextField;
	/**

	 * Стандартное текстовое форматирование которое используется для применения

	 * к тексту какого-либо оформления.

	 */
	var _textFormat : TextFormat;
	/**

	 * Текущее выравнивание текста.

	 * @default	ALIGN_LEFT

	 */
	var _align : String;
	/**

	 * Определяет авто обновление размера текстовой метки в зависимости от объема текста.

	 * @default	true

	 */
	var _autoSize : Bool;
	/**

	 * Внутренний буфер в который производится растеризация текста.

	 */
	var _buffer : BitmapData;
	/**

	 * Цветовая трансформация. Инициализируется автоматически если задан цвет отличный от 0x00FFFFFF.

	 * @default	null

	 */
	var _colorTransform : ColorTransform;
	/**

	 * Текущий цвет.

	 * @default	0x00FFFFFF

	 */
	var _color : UInt;
	/**

	 * Текущая прозрачность.

	 * @default	1

	 */
	var _alpha : Float;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _flashPoint : Point;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _flashPointZero : Point;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _flashRect : Rectangle;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _matrix : Matrix;
	/**

	 * Флаг определяющий возможно ли пересчитать растровый кадр при изменений данных.

	 */
	var _canRedraw : Bool;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new(aFontName : String, aFontSize : Int = 8, aColor : UInt = 0xFFFFFF, aEmbedFont : Bool = true) {
		super();
		blend = null;
		smoothing = true;
		_textFormat = new TextFormat(aFontName, aFontSize, aColor);
		_textField = new TextField();
		_textField.multiline = false;
		_textField.wordWrap = false;
		_textField.embedFonts = aEmbedFont;
		_textField.antiAliasType = AntiAliasType.NORMAL;
		_textField.gridFitType = GridFitType.PIXEL;
		_textField.defaultTextFormat = _textFormat;
		_textField.autoSize = TextFieldAutoSize.LEFT;
		_autoSize = true;
		width = _textField.width = 100;
		height = _textField.height = 100;
		_flashRect = new Rectangle();
		_flashPoint = new Point();
		_flashPointZero = new Point();
		_matrix = new Matrix();
		_canRedraw = true;
		_align = LEFT;
		_color = 0xFFFFFF;
		_alpha = 1;
	}

	/**

	 * @inheritDoc

	 */
	override public function destroy() : Void {
		_textField = null;
		_textFormat = null;
		_colorTransform = null;
		if(_buffer != null)  {
			_buffer.dispose();
			_buffer = null;
		}
		super.destroy();
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Задает цвет текста для всего текстового поля или для указанного диапазона символов.

	 * <p>Примичание: Цвет указанный через <code>setColor()</code> применяется непосредственно к стандартному

	 * текстовому полю и не имеет отношения к значению <color>color</color>. То есть если вы укажете цвет

	 * через <code>setColor()</code>, а потом зададите другой цвет через <code>color</code> - то цвета будут смешаны.</p>

	 * 

	 * @param	aColor	 Цвет в который необходимо перекрасить текст.

	 * @param	aStartIndex	 Начальный индекс символа скоторого начинать красить.

	 * @param	aEndIndex	 Конечный индекс символа до которого красить.

	 */
	public function setColor(aColor : UInt, aStartIndex : Int = -1, aEndIndex : Int = -1) : Void {
		_textFormat.color = aColor;
		_textField.setTextFormat(_textFormat, aStartIndex, aEndIndex);
		calcFrame();
	}

	/**

	 * Подсвечивает указанный текст указанным цветом.

	 * 

	 * @param	aText	 Текст который необходимо подсветить.

	 * @param	aColor	 Цвет которым необходимо подсветить.

	 */
	public function highlightText(aText : String, aColor : UInt) : Void {
		var str : String = _textField.text;
		var startIndex : Int = str.indexOf(aText);
		var endIndex : Int = 0;
		var offset : Int = 0;
		while(startIndex >= 0) {
			offset += endIndex;
			endIndex = startIndex + aText.length;
			setColor(aColor, startIndex + offset, endIndex + offset);
			str = str.substring(endIndex, str.length);
			startIndex = str.indexOf(aText);
		}

	}

	/**

	 * Устанавливает размер текстового поля в ручную.

	 * Если autoSize = true то размеры будут автоматически изменены при обновлении текста.

	 * 

	 * @param	aWidth	 Размер текстового поля по ширине.

	 * @param	aHeight	 Размер текстового поля по высоте.

	 */
	public function setSize(aWidth : Int, aHeight : Int) : Void {
		width = _textField.width = aWidth;
		height = _textField.height = aHeight;
		resetHelpers();
	}

	/**

	 * Применяет массив указанных фильтров к текстовому полю и перерасчитывает растр.

	 * 

	 * @param	aFilteresArray	 Массив фильтров которые необходимо применить к тексту.

	 */
	public function applyFilters(aFiltersArray : Array<BitmapFilter>) : Void {
		_textField.filters = aFiltersArray;
		calcFrame();
	}

	/**

	 * Устанавливает однопиксельную обводку для текстового поля.

	 * 

	 * @param	aColor	 Цвет обводки.

	 */
	public function setStroke(aColor : UInt = 0xFF000000) : Void {
		applyFilters([new GlowFilter(aColor, 1, 2, 2, 5)]);
	}

	/**

	 * Запрещает обновление текста до тех пор пока не будет вызван <code>endChange()</code>.

	 * Следует вызывать перед тем как необходимо применить сразу много сложных операций к тексту.

	 * <p>Пример использования:</p>

	 * 

	 * <code>

	 * label.beginChange();

	 * label.setSize(200, 50);

	 * label.text = "some big text here";

	 * label.setColor(0x00FF00, 0, 4);

	 * label.endChange();

	 * </code>

	 */
	public function beginChange() : Void {
		_canRedraw = false;
	}

	/**

	 * Разрешает обновление текста. Обязательно вызывать после того как был вызван метод <code>beginChange()</code>.

	 */
	public function endChange() : Void {
		_canRedraw = true;
		resetHelpers();
	}

	/**

	 * @inheritDoc

	 */
	override public function draw(aCamera : AntCamera) : Void {
		updateBounds();
		/*if (cameras == null)

		{

		cameras = AntG.cameras;

		}

		

		var cam:AntCamera;

		var i:int = 0;

		var n:int = cameras.length;

		while (i < n)

		{

		cam = cameras[i] as AntCamera;

		if (cam != null)

		{

		drawText(cam);

		}

		i++;

		}*/
		drawText(aCamera);
		super.draw(aCamera);
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * @private

	 */
	override function calcBounds() : Void {
		vertices[0].set(globalX - origin.x * scaleX, globalY - origin.y * scaleY);
		// top left
		vertices[1].set(globalX + width * scaleX - origin.x * scaleX, globalY - origin.y * scaleY);
		// top right
		vertices[2].set(globalX + width * scaleX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY);
		// bottom right
		vertices[3].set(globalX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY);
		// bottom left
		var tl : AntPoint = vertices[0];
		var br : AntPoint = vertices[2];
		bounds.set(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
		saveOldPosition();
	}

	/**

	 * @inheritDoc

	 */
	override function rotateBounds() : Void {
		vertices[0].set(globalX - origin.x * scaleX, globalY - origin.y * scaleY);
		// top left
		vertices[1].set(globalX + width * scaleX - origin.x * scaleX, globalY - origin.y * scaleY);
		// top right
		vertices[2].set(globalX + width * scaleX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY);
		// bottom right
		vertices[3].set(globalX - origin.x * scaleX, globalY + height * scaleY - origin.y * scaleY);
		// bottom left
		var dx : Float;
		var dy : Float;
		var p : AntPoint = vertices[0];
		var maxX : Float = p.x;
		var maxY : Float = p.y;
		p = vertices[2];
		var minX : Float = p.x;
		var minY : Float = p.y;
		var rad : Float = -globalAngle * Math.PI / 180;
		// Radians
		var i : Int = 0;
		while(i < 4) {
			p = vertices[i];
			dx = globalX + (p.x - globalX) * Math.cos(rad) + (p.y - globalY) * Math.sin(rad);
			dy = globalY - (p.x - globalX) * Math.sin(rad) + (p.y - globalY) * Math.cos(rad);
			maxX = ((dx > maxX)) ? dx : maxX;
			maxY = ((dy > maxY)) ? dy : maxY;
			minX = ((dx < minX)) ? dx : minX;
			minY = ((dy < minY)) ? dy : minY;
			p.x = dx;
			p.y = dy;
			i++;
		}

		bounds.set(minX, minY, maxX - minX, maxY - minY);
		saveOldPosition();
	}

	/**

	 * Отрисовка текста в буффер указанной камеры.

	 * 

	 * @param	aCamera	 Камера в буффер которой необходимо отрисовать текст.

	 */
	function drawText(aCamera : AntCamera) : Void {
		AntBasic.NUM_OF_VISIBLE++;
		if(_buffer == null || !onScreen(aCamera))  {
			return;
		}
		AntBasic.NUM_ON_SCREEN++;
		var p : AntPoint = getScreenPosition(aCamera);
		if(aCamera._isMasked)  {
			p.x -= aCamera._maskOffset.x;
			p.y -= aCamera._maskOffset.y;
		}
		_flashPoint.x = p.x - origin.x;
		_flashPoint.y = p.y - origin.y;
		// Если не применено никаких трансформаций то выполняем простой рендер через copyPixels().
		if(globalAngle == 0 && scaleX == 1 && scaleY == 1 && blend == null)  {
			aCamera.buffer.copyPixels(_buffer, _flashRect, _flashPoint, null, null, true);
		}

		else // Если объект имеет какие-либо трансформации, используем более сложный рендер через draw().
		 {
			_matrix.identity();
			_matrix.translate(-origin.x, -origin.y);
			_matrix.scale(scaleX, scaleY);
			if(globalAngle != 0)  {
				_matrix.rotate(Math.PI * 2 * (globalAngle / 360));
			}
			_matrix.translate(_flashPoint.x + origin.x, _flashPoint.y + origin.y);
			aCamera.buffer.draw(_buffer, _matrix, null, Type.createEnum(BlendMode,blend), null, smoothing);
		}

	}

	/**

	 * Растеризация векторного TextField в битмап.

	 */
	function calcFrame() : Void {
		if(_buffer == null || !_canRedraw)  {
			return;
		}
		_flashRect.width = _buffer.width;
		_flashRect.height = _buffer.height;
		_buffer.fillRect(_flashRect, 0x00FFFFFF);
		_buffer.draw(_textField);
		if(_colorTransform != null)  {
			_buffer.colorTransform(_flashRect, _colorTransform);
		}
	}

	/**

	 * Сброс помошников и обновление битмапа.

	 */
	function resetHelpers() : Void {
		if(width == 0 || height == 0 || !_canRedraw)  {
			return;
		}
		_flashRect.x = _flashRect.y = 0;
		_flashRect.width = width;
		_flashRect.height = height;
		if(_buffer == null || _buffer.width < width || _buffer.height < height)  {
			if(_buffer != null)  {
				_buffer.dispose();
			}
			_buffer = new BitmapData(Std.int(width), Std.int(height), true, 0x00FFFFFF);
		}
		calcFrame();
		updateBounds();
	}

	//---------------------------------------
	// GETTER / SETTERS
	//---------------------------------------
	/**

	 * Определяет толщину начертания текста.

	 */
	function get_bold() : Bool {
		return _textFormat.bold;
	}

	function set_bold(value : Bool) : Bool {
		if(_textFormat.bold != value)  {
			_textFormat.bold = value;
			_textField.setTextFormat(_textFormat);
			resetHelpers();
		}
		return value;
	}

	/**

	 * Определяет текст для текстовой метки.

	 */
	function get_text() : String {
		return _textField.text;
	}

	function set_text(value : String) : String {
		if(_textField.text != value)  {
			_textField.text = value;
			width = _textField.width;
			height = _textField.height;
			resetHelpers();
		}
		return value;
	}

	/**

	 * Определяет изменяется ли текстовое поле автоматически исходя из количества текста.

	 * Выравнивание текста не работает при авто изменении размера поля.

	 */
	function get_autoSize() : Bool {
		return _autoSize;
	}

	function set_autoSize(value : Bool) : Bool {
		if(_autoSize != value)  {
			_autoSize = value;
			_textField.autoSize = ((_autoSize)) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
			align = _align;
			resetHelpers();
		}
		return value;
	}

	/**

	 * Определяет возможен ли перенос строк.

	 */
	function get_wordWrap() : Bool {
		return _textField.wordWrap;
	}

	function set_wordWrap(value : Bool) : Bool {
		if(_textField.wordWrap != value)  {
			_textField.wordWrap = value;
			_textField.multiline = value;
			resetHelpers();
		}
		return value;
	}

	/**

	 * Определяет выравнивание текста.

	 */
	function get_align() : String {
		return _align;
	}

	function set_align(value : String) : String {
		_align = value;
		switch(_align) {
		case LEFT:
			_textFormat.align = TextFormatAlign.LEFT;
		case RIGHT:
			_textFormat.align = TextFormatAlign.RIGHT;
		case CENTER:
			_textFormat.align = TextFormatAlign.CENTER;
		case JUSTIFY:
			_textFormat.align = TextFormatAlign.JUSTIFY;
		}
		_textField.setTextFormat(_textFormat);
		resetHelpers();
		return value;
	}

	/**

	 * Определяет текущую прозрачность кэшированного битмапа текстовой метки.

	 */
	function get_alpha() : Float {
		return _alpha;
	}

	function set_alpha(value : Float) : Float {
		value = ((value > 1)) ? 1 : ((value < 0)) ? 0 : value;
		if(_alpha != value)  {
			_alpha = value;
			if(_alpha != 1 || _color != 0x00FFFFFF)  {
				_colorTransform = new ColorTransform((_color >> 16) * 0.00392, (_color >> 8 & 0xFF) * 0.00392, (_color & 0xFF) * 0.00392, _alpha);
			}

			else  {
				_colorTransform = null;
			}

			calcFrame();
		}
		return value;
	}

	/**

	 * Определяет текущий цвет кэшированного битмапа текстовой метки.

	 */
	function get_color() : UInt {
		return _color;
	}

	function set_color(value : UInt) : UInt {
		value &= 0x00FFFFFF;
		if(_color != value)  {
			_color = value;
			if(_alpha != 1 || _color != 0x00FFFFFF)  {
				_colorTransform = new ColorTransform((_color >> 16) * 0.00392, (_color >> 8 & 0xFF) * 0.00392, (_color & 0xFF) * 0.00392, _alpha);
			}

			else  {
				_colorTransform = null;
			}

			calcFrame();
		}
		return value;
	}

	/**

	 * Возвращает количество символов в тексте.

	 */
	function get_numChars() : Int {
		return _textField.length;
	}

	/**

	 * Возвращает количество строк в тексте.

	 */
	function get_numLines() : Int {
		return _textField.numLines;
	}

}

