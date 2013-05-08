/**
 * Description
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  05.02.2013
 */
package ru.antkarlov.anthill.utils;

using Lambda;

class AntFormat {

	/**
	 * Корректное форматирование дробных чисел в строку.
	 * 
	 * @param	aValue	 Значение которое необходимо перевести в строку.
	 * @param	aMaxDecimals	 Максимально допустимое количество цифр в дробной части.
	 * @param	aForceDecimals	 Определяет принудительное добавление дробной части даже если значение не является дробным.
	 * @param	aSiStyle	 Определяет стиль отображения, если <code>true</code> то в качестве разделителя используется точка, иначе запятая.
	 * @return		Возвращает текстовое отформатированное значение.
	 */
	static public function formatNumber(aValue : Dynamic, aMaxDecimals : Int = 2, aForceDecimals : Bool = true, aSiStyle : Bool = false) : String {
		var i : Int = 0;
		var inc : Float = Math.pow(10, aMaxDecimals);
		var str : String = Std.string(Math.round(inc * Std.parseFloat(aValue); /* WARNING check type */) / inc);
		var hasSep : Bool = str.indexOf(".") == -1;
		var sep : Int = (hasSep) ? str.length : str.indexOf(".");
		var ret : String = (hasSep && !(aForceDecimals) ? "" : ((aSiStyle) ? "," : ".")) + str.substr(sep + 1);
		if(aForceDecimals)  {
			var j : Int = 0;
			while(j <= aMaxDecimals - (str.length - ((hasSep) ? sep - 1 : sep))) {
				ret += "0";
				j++;
			}
		}
		while(i + 3 < (str.substr(0, 1) == ("-") ? sep - 1 : sep)) {
			ret = ((aSiStyle) ? "." : ",") + str.substr(sep - (i += 3), 3) + ret;
		}

		return str.substr(0, sep - i) + ret;
	}

	/**
	 * Форматирует строку в .Net стиль, заменяет значение в фигурных скобках на переданные аргументы.
	 * 
	 * <p>Пример использования:</p>
	 * 
	 * <listing>
	 * var str:String = AntFormat.formatString("Hello {0}! It's a {1}.", "World", "UFO");
	 * trace(str); - // Output the "Hello World! It's a UFO.";
	 * </listing>
	 * 
	 * @param	aFormat	 Текст который будет отформатирован.
	 * @param	...args	 Аргументы через запятую которые будут добавлены в форматируемую строку.
	 * @return		Возвращает отформатированную строку.
	 */
	static public function formatString(aFormat : String) : String {
		var i : Int = 0;
		var n : Int = args.length;
		while(i < n) {
			aFormat = aFormat.replace(new RegExp("\{" + i + "\}", "g"), args[i]);
			i++;
		}

		return aFormat;
	}

	/**
	 * @private
	 */
	static public function formatCommas(aValue : Dynamic) : String {
		var numString : String = Std.string(aValue);
		var res : String = "";
		while(numString.length > 3) {
			var chunk : String = numString.substr(-3);
			numString = numString.substr(0, numString.length - 3);
			res = "," + chunk + res;
		}

		if(numString.length > 0)  {
			res = numString + res;
		}
		return res;
	}

}

