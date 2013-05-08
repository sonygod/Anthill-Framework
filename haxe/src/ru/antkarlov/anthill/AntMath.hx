/**

 * Утилитный класс с полезными математическими методами.

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  18.05.2011

 */
package ru.antkarlov.anthill;

class AntMath {

	/**

	 * @private

	 */
	static var MAX_RATIO : Float = 1 / untyped __global__["uint"].MAX_VALUE;
	/**

	 * @private

	 */
	static var r : Int = Std.int(Math.random() * untyped __global__["uint"].MAX_VALUE);
	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Округляет указанное значение в меньшую сторону.

	 * 

	 * @param	value	 Значение которое необходимо округлить.

	 * @return		Округленное значение.

	 */
	static public function floor(value : Float) : Float {
		var n : Float = Std.int(value);
		return ((value > 0)) ? (n) : (((n != value)) ? n - 1 : n);
	}

	/**

	 * Округляет указанное значение в большую сторону.

	 * 

	 * @param	value	 Значение которое необходимо округлить.

	 * @return		Округленное значение.

	 */
	static public function ceil(value : Float) : Float {
		var n : Float = Std.int(value);
		return ((value > 0)) ? (((n != value)) ? n + 1 : n) : n;
	}

	/**

	 * Убирает минус у отрицательных значений, позитивные значения остаются без изменений.

	 * 

	 * @param	value	 Значение для которого необходимо убрать минус.

	 * @return		Позитивное значение.

	 */
	static public function abs(value : Float) : Float {
		return ((value < 0)) ? value * -1 : value;
	}

	/**

	 * Проверяет вхождение значение в заданный диапазон.

	 * 

	 * @param	value	 Значение вхождение которого необходимо проверить.

	 * @param	aLower	 Наименьшее значение диапазона.

	 * @param	aUpper	 Наибольшоее значение диапазона.

	 * @return		Возвращает true если указанное значение в заданном диапазоне.

	 */
	static public function range(value : Float, aLower : Float, aUpper : Float) : Bool {
		return ((value > aLower) && (value < aUpper));
	}

	/**

	 * Возрващает ближайшее значение к заданному.

	 * 

	 * @param	value	 Заданное значение.

	 * @param	out1	 Первое возможно ближайшее значение.

	 * @param	out2	 Второе возможно ближайшее значение.

	 * @return		Возвращает ближайшее из out1 и out2 к value.

	 */
	static public function closest(value : Float, out1 : Float, out2 : Float) : Float {
		return ((Math.abs(value - out1) < Math.abs(value - out1))) ? out1 : out2;
	}

	/**

	 * Возвращает случайное целочисленное число из заданного диапазона.

	 * 

	 * @param	aLower	 Меньшее значание в диапазоне.

	 * @param	aUpper	 Большее значание в диапазоне.

	 * @return		Случайное целочисленное число из заданного диапазона.

	 */
	static public function randomRangeInt(aLower : Int, aUpper : Int) : Int {
		return Std.int(random() * (aUpper - aLower + 1)) + aLower;
	}

	/**

	 * Возвращает случайное число из заданного диапазона.

	 * 

	 * @param	aLower	 Меньшее значание в диапазоне.

	 * @param	aUpper	 Большее значание в диапазоне.

	 * @return		Случайное число из заданного диапазона.

	 */
	static public function randomRangeNumber(aLower : Float, aUpper : Float) : Float {
		return random() * (aUpper - aLower) + aLower;
	}

	/**

	 * Возвращает случайное число.

	 * 

	 * @return		Случайное число.

	 */
	static public function random() : Float {
		r ^= (r << 21);
		r ^= (r >>> 35);
		r ^= (r << 4);
		return r * MAX_RATIO;
	}

	/**

	 * Сравнивает указанные значения с возможной погрешностью.

	 * 

	 * @param	aValueA	 Первое значение.

	 * @param	aValueB	 Второе значение.

	 * @param	aDiff	 Допустимая для сравнения погрешность.

	 * @return		Возвращает true если указанные значения равны с допустимой погрешностью.

	 */
	static public function equal(aValueA : Float, aValueB : Float, aDiff : Float = 0.00001) : Bool {
		return (Math.abs(aValueA - aValueB) <= aDiff);
	}

	/**

	 * Переводит указанное значение из одного диапазона в другой.

	 * 

	 * @param	value	 Значение которое необходимо перевести.

	 * @param	aLower	 Наименьшее значение первого диапазона.

	 * @param	aUpper	 Наибольшее значение первого диапазона.

	 * @param	bLower	 Наименьшее значение второго диапазона.

	 * @param	bUpper	 Наибольшее значение второго диапазона.

	 * @return		Новое значение.

	 */
	static public function remap(value : Float, aLower : Float, aUpper : Float, bLower : Float, bUpper : Float) : Float {
		/*

		TODO протестировать

		*/
		return bLower + (bUpper - aLower) * (value - aLower) / (aUpper - aLower);
	}

	/**

	 * Ограничивает указанное значение заданным диапазоном.

	 * 

	 * @param	value	 Значение которое необходимо ограничить.

	 * @param	aLower	 Наименьшее значение диапазона.

	 * @param	aUpper	 Наибольшее значение диапазона.

	 * @return		Если значение меньше или больше заданного диапазона, то будет возвращена граница диапазона.

	 */
	static public function trimToRange(value : Float, aLower : Float, aUpper : Float) : Float {
		return ((value > aUpper)) ? aUpper : ((value < aLower)) ? aLower : value;
	}

	/**

	 * Возрващает значение из заданного диапазона с заданным коэффицентом.

	 * <p>Например: 

	 * <code>if (aCoef == 0.0) return aLower;

	 * if (aCoef == 1.0) return aUpper;</code></p>

	 * 

	 * @param	aLower	 Наименьшее значение диапазона.

	 * @param	aUpper	 Наибольшее значение диапазона.

	 * @param	aCoef	 Коэффицент.

	 * @return		Значение из диапазона согласно коэфиценту.

	 */
	static public function lerp(aLower : Float, aUpper : Float, aCoef : Float) : Float {
		return aLower + aCoef * (aUpper - aLower);
	}

	/**

	 * Проверяет пересечение двух отрезков.

	 * 

	 * @param	aLineX1	 Первая координата X первого отрезка.

	 * @param	aLineY1	 Первая координата Y первого отрезка.

	 * @param	aLineX2	 Вторая координата X первого отрезка.

	 * @param	aLineY2	 Вторая координата Y первого отрезка.

	 * @param	bLineX1	 Первая координата X второго отрезка.

	 * @param	bLineY1	 Первая координата Y второго отрезка.

	 * @param	bLineX2	 Вторая координата X второго отрезка.

	 * @param	bLineY2	 Вторая координата Y второго отрезка.

	 * @return		Возвращает true если отрезки пересекаются.

	 */
	static public function linesCross(aLineX1 : Float, aLineY1 : Float, aLineX2 : Float, aLineY2 : Float, bLineX1 : Float, bLineY1 : Float, bLineX2 : Float, bLineY2 : Float) : Bool {
		var d : Float = (aLineX2 - aLineX1) * (bLineY1 - bLineY2) - (bLineX1 - bLineX2) * (aLineY2 - aLineY1);
		// Отрезки паралельны.
		if(d == 0)  {
			return false;
		}
		var d1 : Float = (bLineX1 - aLineX1) * (bLineY1 - bLineY2) - (bLineX1 - bLineX2) * (bLineY1 - aLineY1);
		var d2 : Float = (aLineX2 - aLineX1) * (bLineY1 - aLineY1) - (bLineX1 - aLineX1) * (aLineY2 - aLineY1);
		var t1 : Float = d1 / d;
		var t2 : Float = d2 / d;
		return ((t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1)) ? true : false;
	}

	/**

	 * Проверят пересечение двух отрезков и рассчитывает точку пересечения.

	 * 

	 * @param	aLine1a	 Первая точка первого отрезка.

	 * @param	aLine1b	 Вторая точка первого отрезка.

	 * @param	aLine2a	 Первая точка второго отрезка.

	 * @param	aLine2b	 ВТорая точка второго отрезка.

	 * @param	aResultPoint	 Указатель на точку в которую будут записаны координаты персечения отрезков.

	 * @return		Возвращает true если отрезки пересекаются.

	 */
	static public function linesCrossPoint(aLine1a : AntPoint, aLine1b : AntPoint, aLine2a : AntPoint, aLine2b : AntPoint, aResultPoint : AntPoint = null) : Bool {
		var isCollided : Bool = false;
		var d : Float = (aLine2b.y - aLine2a.y) * (aLine1b.x - aLine1a.x) - (aLine2b.x - aLine2a.x) * (aLine1b.y - aLine1a.y);
		var na : Float = (aLine2b.x - aLine2a.x) * (aLine1a.y - aLine2a.y) - (aLine2b.y - aLine2a.y) * (aLine1a.x - aLine2a.x);
		var nb : Float = (aLine1b.x - aLine1a.x) * (aLine1a.y - aLine2a.y) - (aLine1b.y - aLine1a.y) * (aLine1a.x - aLine2a.x);
		if(d == 0)  {
			return isCollided;
		}
		var ua : Float = na / d;
		var ub : Float = nb / d;
		if(ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1)  {
			if(aResultPoint != null)  {
				aResultPoint.x = aLine1a.x + (ua * (aLine1b.x - aLine1a.x));
				aResultPoint.y = aLine1a.y + (ua * (aLine1b.y - aLine1a.y));
			}
			isCollided = true;
		}
		return isCollided;
	}

	/**

	 * Рассчитывает дистанцию между указанными точками.

	 * 

	 * @param	x1	 Координата X первой точки.

	 * @param	y1	 Координата Y первой точки.

	 * @param	x2	 Координата X второй точки.

	 * @param	y2	 Коордианат Y второй точки.

	 * @return		Возрвщает дистанцию между точками.

	 */
	static public function distance(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Float {
		var dx : Float = x2 - x1;
		var dy : Float = y2 - y1;
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**

	 * Рассчитывает угол между двумя точками в радианах.

	 * 

	 * @param	x1	 Координата X первой точки.

	 * @param	y1	 Координата Y первой точки.

	 * @param	x2	 Координата X второй точки.

	 * @param	y2	 Коордианат Y второй точки.

	 * @param	norm	 Если true, то угол будет нормализован.

	 * @return		Возвращает угол между двумя точками в радианах.

	 */
	static public function angle(x1 : Float, y1 : Float, x2 : Float, y2 : Float, norm : Bool = true) : Float {
		var dx : Float = x2 - x1;
		var dy : Float = y2 - y1;
		var angle : Float = Math.atan2(dy, dx);
		return ((norm)) ? normAngle(angle) : angle;
	}

	/**

	 * Рассчитывает угол между двумя точками в градусах.

	 * 

	 * @param	x1	 Координата X первой точки.

	 * @param	y1	 Координата Y первой точки.

	 * @param	x2	 Координата X второй точки.

	 * @param	y2	 Коордианат Y второй точки.

	 * @param	norm	 Если true, то угол будет нормализован.

	 * @return		Возвращает угол между двумя точками в градусах.

	 */
	static public function angleDeg(x1 : Float, y1 : Float, x2 : Float, y2 : Float, norm : Bool = true) : Float {
		var dx : Float = x2 - x1;
		var dy : Float = y2 - y1;
		var angle : Float = Math.atan2(dy, dx) / Math.PI * 180;
		return ((norm)) ? normAngleDeg(angle) : angle;
	}

	/**

	 * Вращает точку вокруг оси на указанный угол в градусах.

	 * 

	 * @param	aX	 Координата X точки которую необходимо повернуть.

	 * @param	aY	 Координата Y точки которую необходимо повернуть.

	 * @param	aPivotX	 Координата X оси вокруг которой необходимо вращать.

	 * @param	aPivotY	 Координата Y оси вокруг которой необходимо вращать.

	 * @param	aAngle	 Угол в радианах на который необходимо повернуть точку.

	 * @param	aResult	 Указатель на точку куда могут быть сохранены результаты вращения.

	 * @return		Возвращает новые координаты поворачиваемой точки в типе AntPoint.

	 */
	static public function rotateDeg(aX : Float, aY : Float, aPivotX : Float, aPivotY : Float, aAngle : Float, aResult : AntPoint = null) : AntPoint {
		if(aResult == null)  {
			aResult = new AntPoint();
		}
		var radians : Float = -aAngle / 180 * Math.PI;
		var dx : Float = aX - aPivotX;
		var dy : Float = aPivotY - aY;
		aResult.x = aPivotX + Math.cos(radians) * dx - Math.sin(radians) * dy;
		aResult.y = aPivotY - (Math.sin(radians) * dx + Math.cos(radians) * dy);
		return aResult;
	}

	/**

	 * Вращает точку вокруг оси на указанный угол в градусах.

	 * 

	 * @param	aPoint	 Точка которую необходимо повернуть.

	 * @param	aPivot	 Точка ось вокруг которой необходимо вращать.

	 * @param	aAngle	 Угол в радианах на который необходимо повернуть точку.

	 * @param	aResult	 Указатель на точку куда могут быть сохранены результаты вращения.

	 * @return		Возвращает новые координаты поворачиваемой точки в типе AntPoint.

	 */
	static public function rotatePointDeg(aPoint : AntPoint, aPivot : AntPoint, aAngle : Float, aResult : AntPoint) : AntPoint {
		if(aResult == null)  {
			aResult = new AntPoint();
		}
		var radians : Float = -aAngle / 180 * Math.PI;
		var dx : Float = aPoint.x - aPivot.x;
		var dy : Float = aPivot.y - aPoint.y;
		aResult.x = aPivot.x + Math.cos(radians) * dx - Math.sin(radians) * dy;
		aResult.y = aPivot.y - (Math.sin(radians) * dx + Math.cos(radians) * dy);
		return aResult;
	}

	/**

	 * Переводит радианы в градусы.

	 * 

	 * @param	aRadians	 Угол в радианах.

	 * @return		Возвращает угол в градусах.

	 */
	static public function toDegrees(aRadians : Float) : Float {
		return aRadians * 180 / Math.PI;
	}

	/**

	 * Переводит градусы в радианы.

	 * 

	 * @param	aDegrees	 Угол в градусах.

	 * @return		Возвращает угол в радианах.

	 */
	static public function toRadians(aDegrees : Float) : Float {
		return aDegrees * Math.PI / 180;
	}

	/**

	 * Нормализирует угол в градусах.

	 * 

	 * @param	aAngle	 Угол в градусах который необходимо нормализировать.

	 * @return		Возвращает нормализированный угол в градусах.

	 */
	static public function normAngleDeg(aAngle : Float) : Float {
		return ((aAngle < 0)) ? 360 + aAngle : ((aAngle >= 360)) ? aAngle - 360 : aAngle;
	}

	/**

	 * Нормализирует угол в радианах.

	 * 

	 * @param	aAngle	 Угол в радианах который необходимо нормализировать.

	 * @return		Возвращает нормализированный угол в радианах.

	 */
	static public function normAngle(aAngle : Float) : Float {
		return ((aAngle < 0)) ? Math.PI * 2 + aAngle : ((aAngle >= Math.PI * 2)) ? aAngle - Math.PI * 2 : aAngle;
	}

	/**

	 * Рассчитывает процент исходя из текущего и общего значения.

	 * 

	 * @param	aCurrent	 Текущее значание.

	 * @param	aTotal	 Общее значение.

	 * @return		Возвращает процент текущего значения.

	 */
	static public function toPercent(aCurrent : Float, aTotal : Float) : Float {
		return (aCurrent / aTotal) * 100;
	}

	/**

	 * Рассчитывает текущее значение исходя из текущего процента и общего значения.

	 * 

	 * @param	aPercent	 Текущий процент.

	 * @param	aTotal	 Общее значение.

	 * @return		Возвращает текущее значение.

	 */
	static public function fromPercent(aPercent : Float, aTotal : Float) : Float {
		return (aPercent * aTotal) / 100;
	}

	/**

	 * Определяет наибольшее число из указанного массива.

	 * 

	 * @param	aArray	 Массив значений.

	 * @return		Возвращает наибольшее число из массива.

	 */
	static public function maxFrom(aArray : Array<Dynamic>) : Float {
		return Math.max(aArray[0], aArray[1]);
	}

	/**

	 * Определяет наименьшее число из указанного массива.

	 * 

	 * @param	aArray	 Массив значений.

	 * @return		Возвращает наименьшее число из массива.

	 */
	static public function minFrom(aArray : Array<Dynamic>) : Float {
		return Math.min(aArray[0], aArray[1]);//.apply(null, aArray);
	}

	/**

	 * Рассчет скорости.

	 * 

	 * @param	aVelocity	 Текущая скорость.

	 * @param	aAcceleration	 Ускорение.

	 * @param	aDrag	 Замедление.

	 * @param	aMax	 Максимально допустимая скорость.

	 * @return		Возвращает новую скорость на основе входящих параметров.

	 */
	static public function calcVelocity(aVelocity : Float, aAcceleration : Float = 0, aDrag : Float = 0, aMax : Float = 10000) : Float {
		if(aAcceleration != 0)  {
			aVelocity += aAcceleration * AntG.elapsed;
		}

		else if(aDrag != 0)  {
			var dv : Float = aDrag * AntG.elapsed;
			if(aVelocity - dv > 0)  {
				aVelocity -= dv;
			}

			else if(aVelocity + dv < 0)  {
				aVelocity += dv;
			}

			else  {
				aVelocity = 0;
			}

		}
		if(aVelocity != 0 && aMax != 10000)  {
			if(aVelocity > aMax)  {
				aVelocity = aMax;
			}

			else if(aVelocity < -aMax)  {
				aVelocity = -aMax;
			}
		}
		return aVelocity;
	}

}

