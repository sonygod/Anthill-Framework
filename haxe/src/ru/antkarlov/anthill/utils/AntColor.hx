/**
 * Утилитный класс предназначенный для работы с цветами. Содержит константы базовых цветов 
 * и статические методы для конвертации цветов в разные представления.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  19.01.2013
 */
package ru.antkarlov.anthill.utils;

class AntColor {

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	static public var WHITE : UInt = 0xffffff;
	static public var SILVER : UInt = 0xc0c0c0;
	static public var GRAY : UInt = 0x808080;
	static public var BLACK : UInt = 0x000000;
	static public var RED : UInt = 0xff0000;
	static public var MAROON : UInt = 0x800000;
	static public var YELLOW : UInt = 0xffff00;
	static public var OLIVE : UInt = 0x808000;
	static public var LIME : UInt = 0x00ff00;
	static public var GREEN : UInt = 0x008000;
	static public var AQUA : UInt = 0x00ffff;
	static public var TEAL : UInt = 0x008080;
	static public var BLUE : UInt = 0x0000ff;
	static public var NAVY : UInt = 0x000080;
	static public var FUCHSIA : UInt = 0xff00ff;
	static public var PURPLE : UInt = 0x800080;
	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**
	 * Извлекает целочисленное значение прозрачности из шестнадцатиричного значения цвета.
	 * 
	 * @param	aColor	 Шестнадцатиричное значение цвета.
	 * @return		Значение прозрачности от 0 до 255.
	 */
	static public function extractAlpha(aColor : UInt) : Int {
		return (aColor >> 24) & 0xFF;
	}

	/**
	 * Извлекает целочисленное значение красного цвета из шестнадцатиричного значения цвета.
	 * 
	 * @param	aColor	 Шестнадцатиричное значение цвета.
	 * @return		Значение красного цвета от 0 до 255.
	 */
	static public function extractRed(aColor : UInt) : Int {
		return (aColor >> 16) & 0xFF;
	}

	/**
	 * Извлекает целочисленное значение зеленого цвета из шестнадцатиричного значения цвета.
	 * 
	 * @param	aColor	 Шестнадцатиричное значение цвета.
	 * @return		Значение зеленого цвета от 0 до 255.
	 */
	static public function extractGreen(aColor : UInt) : Int {
		return (aColor >> 8) & 0xFF;
	}

	/**
	 * Извлекает целочисленное значение синего цвета из шестнадцатиричного значения цвета.
	 * 
	 * @param	aColor	 Шестнадцатиричное значение цвета.
	 * @return		Значение синего цвета от 0 до 255.
	 */
	static public function extractBlue(aColor : UInt) : Int {
		return aColor & 0xFF;
	}

	/**
	 * Комбинирует целочисленные значения цвета в шестнадцатиричный формат.
	 * 
	 * @param	aRed	 Значение красного цвета от 0 до 255.
	 * @param	aGreen	 Значение зеленого цвета от 0 до 255.
	 * @param	aBlue	 Значение синего цвета от 0 до 255.
	 * @return		Возвращает шестнадцатиричное значение цвета.
	 */
	static public function combineRGB(aRed : Int, aGreen : Int, aBlue : Int) : UInt {
		return (aRed << 16) | (aGreen << 8) | aBlue;
	}

	/**
	 * Комбинирует целочисленные значения цвета с прозрачностью в шастнадцатиричный формат.
	 * 
	 * @param	aRed	 Значение красного цвета от 0 до 255.
	 * @param	aGreen	 Значение зеленого цвета от 0 до 255.
	 * @param	aBlue	 Значение синего цвета от 0 до 255.
	 * @return		Возвращает шестнадцатиричное значение цвета.
	 */
	static public function combineARGB(aAlpha : Int, aRed : Int, aGreen : Int, aBlue : Int) : UInt {
		return (aAlpha << 24) | (aRed << 16) | (aGreen << 8) | aBlue;
	}

}

