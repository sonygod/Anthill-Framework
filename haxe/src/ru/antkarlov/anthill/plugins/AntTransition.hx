/**

 * Данный класс содержит статические методы для реализации сглаживаний.

 * Все эти методы используются классом AntTween.

 * 

 * <p>Вы можете определить свои методы для реализации сглаживаний используя метод

 * <code>registerTransition()</code>. Метод для реализации должен следовать одному простому правилу:

 * в качестве атрибута должен передаваться текущий прогресс в промежутке от 0 до 1.</p>

 * 

 * <pre>function myTransition(aRatio:Number):Number</pre>

 * 

 * <p>Идея и реализация подсмотрена у <a href="http://gamua.com/starling/">Starling Framework</a>.</p>

 * 

 * @author Антон Карлов

 * @since  26.01.2013

 */
package ru.antkarlov.anthill.plugins;

import ru.antkarlov.anthill.*;

class AntTransition {

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	static public var LINEAR : String = "linear";
	static public var EASE_IN : String = "easeIn";
	static public var EASE_OUT : String = "easeOut";
	static public var EASE_IN_OUT : String = "easeInOut";
	static public var EASE_OUT_IN : String = "easeOutIn";
	static public var EASE_IN_BACK : String = "easeInBack";
	static public var EASE_OUT_BACK : String = "easeOutBack";
	static public var EASE_IN_OUT_BACK : String = "easeInOutBack";
	static public var EASE_OUT_IN_BACK : String = "easeOutInBack";
	static public var EASE_IN_ELASTIC : String = "easeInElastic";
	static public var EASE_OUT_ELASTIC : String = "easeOutElastic";
	static public var EASE_IN_OUT_ELASTIC : String = "easeInOutElastic";
	static public var EASE_OUT_IN_ELASTIC : String = "easeOutInElastic";
	static public var EASE_IN_BOUNCE : String = "easeInBounce";
	static public var EASE_OUT_BOUNCE : String = "easeOutBounce";
	static public var EASE_IN_OUT_BOUNCE : String = "easeInOutBounce";
	static public var EASE_OUT_IN_BOUNCE : String = "easeOutInBounce";
	static var _transitions : AntStorage;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new() {
		//super()
		throw new flash.errors.Error();
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Извлекает зарегистрированный метод под указанным именем.

	 * 

	 * @param	aName	 Имя под которым зарегистрирован необходимый метод.

	 * @return		Возвращает указатель на метод.

	 */
	static public function getTransition(aName : String) : Dynamic {
		if(_transitions == null)  {
			registerDefaults();
		}
		return _transitions.get(aName);//try cast(_transitions.get(aName), Function) catch(e:Dynamic) null;
	}

	/**

	 * Регистрирует указанный метод под указанным именем для последующего его использования в

	 * классе AntTween для реализации рассчетов.

	 * 

	 * @param	aName	 Имя метода.

	 * @param	aFunc	 Указатель на регистрируемый метод.

	 */
	static public function register(aName : String, aFunc : Dynamic) : Void {
		if(_transitions == null)  {
			registerDefaults();
		}
		_transitions.set(aName, aFunc);
	}

	/**

	 * Регистрирует стандартные методы для реализации рассчетов.

	 */
	static function registerDefaults() : Void {
		_transitions = new AntStorage();
		register(LINEAR, linear);
		register(EASE_IN, easeIn);
		register(EASE_OUT, easeOut);
		register(EASE_IN_OUT, easeInOut);
		register(EASE_OUT_IN, easeOutIn);
		register(EASE_IN_BACK, easeInBack);
		register(EASE_OUT_BACK, easeOutBack);
		register(EASE_IN_OUT_BACK, easeInOutBack);
		register(EASE_OUT_IN_BACK, easeOutInBack);
		register(EASE_IN_ELASTIC, easeInElastic);
		register(EASE_OUT_ELASTIC, easeOutElastic);
		register(EASE_IN_OUT_ELASTIC, easeInOutElastic);
		register(EASE_OUT_IN_ELASTIC, easeOutInElastic);
		register(EASE_IN_BOUNCE, easeInBounce);
		register(EASE_OUT_BOUNCE, easeOutBounce);
		register(EASE_IN_OUT_BOUNCE, easeInOutBounce);
		register(EASE_OUT_IN_BOUNCE, easeOutInBounce);
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * @private

	 */
	static function linear(aRatio : Float) : Float {
		return aRatio;
	}

	/**

	 * @private

	 */
	static function easeIn(aRatio : Float) : Float {
		return aRatio * aRatio * aRatio;
	}

	/**

	 * @private

	 */
	static function easeOut(aRatio : Float) : Float {
		var invRatio : Float = aRatio - 1.0;
		return invRatio * invRatio * invRatio + 1;
	}

	/**

	 * @private

	 */
	static function easeInOut(aRatio : Float) : Float {
		return easeCombined(easeIn, easeOut, aRatio);
	}

	/**

	 * @private

	 */
	static function easeOutIn(aRatio : Float) : Float {
		return easeCombined(easeOut, easeIn, aRatio);
	}

	/**

	 * @private

	 */
	static function easeInBack(aRatio : Float) : Float {
		var s : Float = 1.70158;
		return Math.pow(aRatio, 2) * ((s + 1.0) * aRatio - s);
	}

	/**

	 * @private

	 */
	static function easeOutBack(aRatio : Float) : Float {
		var invRatio : Float = aRatio - 1.0;
		var s : Float = 1.70158;
		return Math.pow(invRatio, 2) * ((s + 1.0) * aRatio + s) + 1.0;
	}

	/**

	 * @private

	 */
	static function easeInOutBack(aRatio : Float) : Float {
		return easeCombined(easeInBack, easeOutBack, aRatio);
	}

	/**

	 * @private

	 */
	static function easeOutInBack(aRatio : Float) : Float {
		return easeCombined(easeOutBack, easeInBack, aRatio);
	}

	/**

	 * @private

	 */
	static function easeInElastic(aRatio : Float) : Float {
		if(aRatio == 0 || aRatio == 1)  {
			return aRatio;
		}

		else  {
			var p : Float = 0.3;
			var s : Float = p / 4.0;
			var invRatio : Float = aRatio - 1;
			return -1.0 * Math.pow(2.0, 10.0 * invRatio) * Math.sin((invRatio - s) * (2.0 * Math.PI) / p);
		}

	}

	/**

	 * @private

	 */
	static function easeOutElastic(aRatio : Float) : Float {
		if(aRatio == 0 || aRatio == 1)  {
			return aRatio;
		}

		else  {
			var p : Float = 0.3;
			var s : Float = p / 4.0;
			return Math.pow(2.0, -10.0 * aRatio) * Math.sin((aRatio - s) * (2.0 * Math.PI) / p) + 1;
		}

	}

	/**

	 * @private

	 */
	static function easeInOutElastic(aRatio : Float) : Float {
		return easeCombined(easeInElastic, easeOutElastic, aRatio);
	}

	/**

	 * @private

	 */
	static function easeOutInElastic(aRatio : Float) : Float {
		return easeCombined(easeOutElastic, easeInElastic, aRatio);
	}

	/**

	 * @private

	 */
	static function easeInBounce(aRatio : Float) : Float {
		return 1.0 - easeOutBounce(1.0 - aRatio);
	}

	/**

	 * @private

	 */
	static function easeOutBounce(aRatio : Float) : Float {
		var s : Float = 7.5625;
		var p : Float = 2.75;
		var l : Float;
		if(aRatio < (1.0 / p))  {
			l = s * Math.pow(aRatio, 2);
		}

		else  {
			if(aRatio < (2.0 / p))  {
				aRatio -= 1.5 / p;
				l = s * Math.pow(aRatio, 2) + 0.75;
			}

			else  {
				if(aRatio < 2.5 / p)  {
					aRatio -= 2.25 / p;
					l = s * Math.pow(aRatio, 2) + 0.9375;
				}

				else  {
					aRatio -= 2.625 / p;
					l = s * Math.pow(aRatio, 2) + 0.984375;
				}

			}

		}

		return l;
	}

	/**

	 * @private

	 */
	static function easeInOutBounce(aRatio : Float) : Float {
		return easeCombined(easeInBounce, easeOutBounce, aRatio);
	}

	/**

	 * @private

	 */
	static function easeOutInBounce(aRatio : Float) : Float {
		return easeCombined(easeOutBounce, easeInBounce, aRatio);
	}

	/**

	 * @private

	 */
	static function easeCombined(aStartFunc : Dynamic, aEndFunc : Dynamic, aRatio : Float) : Float {
		if(aRatio < 0.5)  {
			return 0.5 * aStartFunc(aRatio * 2.0);
		}

		else  {
			return 0.5 * aEndFunc((aRatio - 0.5) * 2.0) + 0.5;
		}

	}

}

