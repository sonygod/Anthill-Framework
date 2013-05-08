/**
 * Помошник для работы с прямоугольниками.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Anton Karlov
 * @since  30.08.2012
 */
package ru.antkarlov.anthill;

class AntRect {
	@:isVar public var top(get, never) : Float;
	@:isVar public var bottom(get, never) : Float;
	@:isVar public var left(get, never) : Float;
	@:isVar public var right(get, never) : Float;

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**
	 * Позиция прямоугольника по X.
	 * @default	0
	 */
	public var x : Float;
	/**
	 * Позиция прямоугольника по Y.
	 * @default	0
	 */
	public var y : Float;
	/**
	 * Ширина прямоугольника.
	 * @default	0
	 */
	public var width : Float;
	/**
	 * Высота прямоугольника.
	 * @default	0
	 */
	public var height : Float;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new(aX : Float = 0, aY : Float = 0, aWidth : Float = 0, aHeight : Float = 0) {
		//super()
		x = aX;
		y = aY;
		width = aWidth;
		height = aHeight;
	}

	/**
	 * Устанавливает новые значения прямоугольника.
	 * 
	 * @param	aX	 Позиция прямгоугольника по X.
	 * @param	aY	 Позиция прямгоугольника по Y.
	 * @param	aWidth	 Ширина прямоугольника.
	 * @param	aHeight	 Высота прямоугольника.
	 */
	public function set(aX : Float = 0, aY : Float = 0, aWidth : Float = 0, aHeight : Float = 0) : Void {
		x = aX;
		y = aY;
		width = aWidth;
		height = aHeight;
	}

	/**
	 * Копирует значения в указанный прямоугольник или создает новый с идентичными значениями.
	 * 
	 * @param	aRect	 Указатель на другой прямоугольник куда произвести клонирование.
	 * @return		Возвращает указатель на новый экземпляр класса прямоугольника с идентичными значениями.
	 */
	public function copy(aRect : AntRect = null) : AntRect {
		if(aRect == null)  {
			aRect = new AntRect();
		}
		aRect.set(x, y, width, height);
		return aRect;
	}

	/**
	 * Копирует значения из указанного прямоугольника.
	 * 
	 * @param	aRect	 Прямоугольник значения которого необходимо скопировать.
	 * @return		Возвращает указатель на себя.
	 */
	public function copyFrom(aRect : AntRect) : AntRect {
		set(aRect.x, aRect.y, aRect.width, aRect.height);
		return this;
	}

	/**
	 * Определяет пересечение текущего прямоугольника с точкой.
	 * 
	 * @param	aPoint	 Точка пересечение с которой необходимо проверить.
	 * @return		Возвращает true если точка внутри прямоугольника.
	 */
	public function intersectsPoint(aPoint : AntPoint) : Bool {
		return ((aPoint.x > left && aPoint.x < right && aPoint.y > top && aPoint.y < bottom)) ? true : false;
	}

	/**
	 * Определеяет пересечение текущего прямоугольника с указанным.
	 * 
	 * @param	aRect	 Другой прямоугольник с которым необходимо проверить пересечение.
	 * @return		Возвращает true если прямоугольники пересекаются.
	 */
	public function intersectsRect(aRect : AntRect) : Bool {
		return (((aRect.right > left && aRect.left < right) && (aRect.bottom > top && aRect.top < bottom))) ? true : false;
	}

	/**
	 * Определеяет пересечение текущего прямоугольника с заданной областью или точкой.
	 * 
	 * @param	aX	 Начало области по x.
	 * @param	aY	 Начало области по y.
	 * @param	aWidth	 Ширина области.
	 * @param	aHeight	 Высота области.
	 * @return		Возвращает true если прямоугольник пересекается с заданной областью.
	 */
	public function intersects(aX : Float, aY : Float, aWidth : Float = 0, aHeight : Float = 0) : Bool {
		// Если высота и ширина не указаны, проверяем пересечение с точкой.
		if(aWidth == 0 && aHeight == 0)  {
			return ((aX > left && aX < right && aY > top && aY < bottom)) ? true : false;
		}
		var t : Float = aY;
		var r : Float = aX + aWidth;
		var b : Float = aY + aHeight;
		var l : Float = aX;
		return (((r > left && l < right) && (b > top && t < bottom))) ? true : false;
	}

	/**
	 * Возвращает позицию верхней грани прямоугольника.
	 */
	function get_top() : Float {
		return y;
	}

	/**
	 * Возвращает позицию нижней грани прямоугольника.
	 */
	function get_bottom() : Float {
		return y + height;
	}

	/**
	 * Возвращает позицию левой грани прямоугольника.
	 */
	function get_left() : Float {
		return x;
	}

	/**
	 * Возвращает позицию правой грани прямоугольника.
	 */
	function get_right() : Float {
		return x + width;
	}

}

