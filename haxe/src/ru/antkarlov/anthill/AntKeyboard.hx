/**

 * Класс обработчик событий клавиатуры.

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  19.05.2011

 */
package ru.antkarlov.anthill;

import flash.errors.Error;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.utils.*;
using Reflect;
import Object;
class AntKeyboard {

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	// Буквы.
	public var A : Bool;
	public var B : Bool;
	public var C : Bool;
	public var D : Bool;
	public var E : Bool;
	public var F : Bool;
	public var G : Bool;
	public var H : Bool;
	public var I : Bool;
	public var J : Bool;
	public var K : Bool;
	public var L : Bool;
	public var M : Bool;
	public var N : Bool;
	public var O : Bool;
	public var P : Bool;
	public var Q : Bool;
	public var R : Bool;
	public var S : Bool;
	public var T : Bool;
	public var U : Bool;
	public var V : Bool;
	public var W : Bool;
	public var X : Bool;
	public var Y : Bool;
	public var Z : Bool;
	// Цифры.
	public var ZERO : Bool;
	public var ONE : Bool;
	public var TWO : Bool;
	public var THREE : Bool;
	public var FOUR : Bool;
	public var FIVE : Bool;
	public var SIX : Bool;
	public var SEVEN : Bool;
	public var EIGHT : Bool;
	public var NINE : Bool;
	// Цифровая клавиатура.
	public var NUMPAD_0 : Bool;
	public var NUMPAD_1 : Bool;
	public var NUMPAD_2 : Bool;
	public var NUMPAD_3 : Bool;
	public var NUMPAD_4 : Bool;
	public var NUMPAD_5 : Bool;
	public var NUMPAD_6 : Bool;
	public var NUMPAD_7 : Bool;
	public var NUMPAD_8 : Bool;
	public var NUMPAD_9 : Bool;
	public var NUMPAD_MULTIPLY : Bool;
	public var NUMPAD_ADD : Bool;
	public var NUMPAD_ENTER : Bool;
	public var NUMPAD_SUBTRACT : Bool;
	public var NUMPAD_DECIMAL : Bool;
	public var NUMPAD_DIVIDE : Bool;
	// Функциональные клафиши.
	public var F1 : Bool;
	public var F2 : Bool;
	public var F3 : Bool;
	public var F4 : Bool;
	public var F5 : Bool;
	public var F6 : Bool;
	public var F7 : Bool;
	public var F8 : Bool;
	public var F9 : Bool;
	public var F10 : Bool;
	public var F11 : Bool;
	public var F12 : Bool;
	public var F13 : Bool;
	public var F14 : Bool;
	public var F15 : Bool;
	// Символы.
	public var COLON : Bool;
	public var EQUALS : Bool;
	public var UNDERSCORE : Bool;
	public var QUESTION_MARK : Bool;
	public var TILDE : Bool;
	public var OPEN_BRACKET : Bool;
	public var BACKWARD_SLASH : Bool;
	public var CLOSED_BRACKET : Bool;
	public var QUOTES : Bool;
	public var LESS_THAN : Bool;
	public var GREATER_THAN : Bool;
	// Другие клавиши.
	public var BACKSPACE : Bool;
	public var TAB : Bool;
	public var CLEAR : Bool;
	public var ENTER : Bool;
	public var SHIFT : Bool;
	public var CONTROL : Bool;
	public var ALT : Bool;
	public var CAPS_LOCK : Bool;
	public var ESC : Bool;
	public var SPACEBAR : Bool;
	public var PAGE_UP : Bool;
	public var PAGE_DOWN : Bool;
	public var END : Bool;
	public var HOME : Bool;
	public var LEFT : Bool;
	public var UP : Bool;
	public var RIGHT : Bool;
	public var DOWN : Bool;
	public var INSERT : Bool;
	public var DELETE : Bool;
	public var HELP : Bool;
	public var NUM_LOCK : Bool;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * Список всех клавиш доступных для использования.

	 */
	var _keys : Dynamic;
	/**

	 * Массив с технической информацией для определения текущего состояния для каждой из клавиш.

	 */
	var _map : Array<Dynamic>;
	/**

	 * Хранилище указателей на методы которые подписаны на вызов при нажатии определенных клавиш.

	 */
	var _functions : AntStorage;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new() {
		//super()
		_keys = { };
		_map = new Array<Dynamic>();
		_functions = new AntStorage();
		// Буквы.
		var i : Int = 0;
		while(i <= 90) {
			addKey(String.fromCharCode(i), i);
			i++;
		}
		// Цифры.
		addKey("ZERO", 48);
		addKey("ONE", 49);
		addKey("TWO", 50);
		addKey("THREE", 51);
		addKey("FOUR", 52);
		addKey("FIVE", 53);
		addKey("SIX", 54);
		addKey("SEVEN", 55);
		addKey("EIGHT", 56);
		addKey("NINE", 57);
		// Цифровая клавиатура.
		addKey("NUMPAD_0", 96);
		addKey("NUMPAD_1", 97);
		addKey("NUMPAD_2", 98);
		addKey("NUMPAD_3", 99);
		addKey("NUMPAD_4", 100);
		addKey("NUMPAD_5", 101);
		addKey("NUMPAD_6", 102);
		addKey("NUMPAD_7", 103);
		addKey("NUMPAD_8", 104);
		addKey("NUMPAD_9", 105);
		addKey("NUMPAD_MULTIPLY", 106);
		addKey("NUMPAD_ADD", 107);
		addKey("NUMPAD_ENTER", 108);
		addKey("NUMPAD_SUBTRACT", 109);
		addKey("NUMPAD_DECIMAL", 110);
		addKey("NUMPAD_DIVIDE", 111);
		// Функциональные клавиши.
		i = 1;
		while(i <= 12) {
			addKey("F" + Std.string(i), 111 + i);
			i++;
		}
		// Символы.
		addKey("COLON", 186);
		addKey("EQUALS", 187);
		addKey("UNDERSCORE", 189);
		addKey("QUESTION_MARK", 191);
		addKey("TILDE", 192);
		addKey("OPEN_BRACKET", 219);
		addKey("BACKWARD_SLASH", 220);
		addKey("CLOSED_BRACKET", 221);
		addKey("QUOTES", 222);
		addKey("LESS_THAN", 188);
		addKey("GREATER_THAN", 190);
		// Другие кнопки.
		addKey("BACKSPACE", 8);
		addKey("TAB", 9);
		addKey("CLEAR", 12);
		addKey("ENTER", 13);
		addKey("SHIFT", 16);
		addKey("CONTROL", 17);
		addKey("ALT", 18);
		addKey("CAPS_LOCK", 20);
		addKey("ESC", 27);
		addKey("SPACEBAR", 32);
		addKey("PAGE_UP", 33);
		addKey("PAGE_DOWN", 34);
		addKey("END", 35);
		addKey("HOME", 36);
		addKey("LEFT", 37);
		addKey("UP", 38);
		addKey("RIGHT", 39);
		addKey("DOWN", 40);
		addKey("INSERT", 45);
		addKey("DELETE", 46);
		addKey("HELP", 47);
		addKey("NUM_LOCK", 144);
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Проверяет нажата ли указанная клавиша.

	 * 

	 * @param	aKey	 Имя клавиши которую нужно проверить.

	 * @return		Возвращает true всегда пока клавиша зажата.

	 */
	public function isDown(aKey : String) : Bool {
		return this.field(aKey);
	}

	/**

	 * Проверяет нажата ли указанная клавиша.

	 * 

	 * @param	aKey	 Имя клавиши которую нужно проверить.

	 * @return		Возвращает true только в момент нажатия клавиши.

	 */
	public function isPressed(aKey : String) : Bool {
		return _map[_keys.field(aKey)].current == 2;
	}

	/**

	 * Проверяет нажата ли любая клавиша.

	 * 

	 * @return		Возвращает true только в момент нажатия любой клавиши.

	 */
	public function isPressedAny() : Bool {
		var o : Dynamic;
		var i : Int = 0;
		while(i < 256) {
			if(_map[i] == null)  {
				 {
					i++;
					continue;
				}

			}
			o = _map[i];
			if(o != null && o.current == true)  {
				return true;
			}
			i++;
		}
		return false;
	}

	/**

	 * Проверяет отпущена ли указанная клавиша.

	 * 

	 * @param	aKey	 Имя клавиши которую нужно проверить.

	 * @return		Возвращает true только в момент отпускания клавиши.

	 */
	public function isReleased(aKey : String) : Bool {
		return _map[_keys.field(aKey)].current == -1;
	}

	/**

	 * Обработка клавиш.

	 */
	public function update() : Void {
		var o : Dynamic;
		var i : Int = 0;
		while(i < 256) {
			o = _map[i];
			if(o == null)  {
				 {
					i++;
					continue;
				}

			}
			if(o.last == -1 && o.current == -1)  {
				o.current = 0;
			}

			else if(o.last == 2 && o.current == 2)  {
				o.current = 1;
			}
			o.last = o.current;
			i++;
		}
	}

	/**

	 * Сбрасывает состояние всех клавиш.

	 */
	public function reset() : Void {
		var o : Dynamic;
		var i : Int = 0;
		while(i < 256) {
			if(_map[i] == null)  {
				 {
					i++;
					continue;
				}

			}
			o = _map[i];
			if(o != null)  {
				if(this.hasField(o.name))  {
					this.setField(o.name, false);//this[o.name] = false;
				}
				o.current = 0;
				o.last = 0;
			}
			i++;
		}
	}

	/**

	 * Регистрирует методы на нажатие определенной клавиши (hotkey).

	 * <p>Примечание: На одну клавишу может быть зарегистрирован только один метод,

	 * в противном случае уже существующий метод будет перезаписан новым.</p>

	 * 

	 * @param	aKey	 Имя клавиши которая будет вызывать метод.

	 * @param	aFunc	 Указатель на метод который будет выполнен при нажатии клавиши.

	 */
	public function registerFunction(aKey : String, aFunc : Dynamic) : Void {
		_functions.set(aKey, aFunc);
	}

	/**

	 * Удаляет метод на нажатие определенной клавиши (hotkey).

	 * 

	 * @param	aKey	 Имя клавиши или указатель на метод который был зарегистрирован.

	 */
	public function unregisterFunction(aKey : Dynamic) : Void {
		
		if(Type.getClassName(Type.getSuperClass(aKey))== "Function")  {
			_functions.remove(_functions.getKey(aKey));
		}

		else  {
			_functions.remove(Std.string(aKey));
		}

	}

	//---------------------------------------
	// EVENT HANDLERS
	//---------------------------------------
	/**

	 * Обработчик нажатия клавиши.

	 */
	public function keyDownHandler(event : KeyboardEvent) : Void {
		var o : Dynamic = _map[event.keyCode];
		if(o == null) return;
		o.current = ((o.current > 0)) ? 1 : 2;
		this.setField(o.name, true);//this[o.name] = true;
		if(_functions.containsKey(o.name))  {
			//_functions[o.name]();
			Reflect.callMethod(null, _functions.field(o.name), []);
			
		}
	}

	/**

	 * Обработчик отпускания клавиши.

	 */
	public function keyUpHandler(event : KeyboardEvent) : Void {
		var o : Dynamic = _map[event.keyCode];
		if(o == null)  {
			return;
		}
		try {
			o.current = ((o.current > 0)) ? -1 : 0;
			this.setField(o.name, false);//this[o.name] = false;
		}
		catch(error : Error){ };
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * Метод помошник для быстрой и понятной инициализации списка клавиш.

	 */
	function addKey(aKeyName : String, aKeyCode : UInt) : Void {
		//Lib.as([aKeyName],Object)[aKeyName ] = aKeyCode;
		
			//Object(_keys)[aKeyName] = aKeyCode;

       

          //  var obj:Object= { name:aKeyName, current:0, last:0 };
           // Object(_map)[aKeyCode] =  obj
			
		 
		     _keys.setField(aKeyName, aKeyCode);
			
		
		var obj : Dynamic = {
			name : aKeyName,
			current : 0,
			last : 0,

		};
		//cast((_map), Object)[aKeyCode] = obj;
		_map[aKeyCode] = obj;
	}

}

