//import ru.antkarlov.anthill.debug.*;
/**

 * Глобальное хранилище с указателями на часто используемые утилитные классы и их методы.

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  22.08.2012

 */
package ru.antkarlov.anthill;

import flash.display.Stage;
import flash.Lib;
import flash.net.URLRequest;

import flash.ui.Mouse;
import ru.antkarlov.anthill.plugins.IPlugin;
using Lambda;

class AntG {
	 @:isVar static public var debugMode(get, set) : Bool;
	 @:isVar static public var useSystemCursor(get, set) : Bool;
	 @:isVar static public var frameRate(get, set) : UInt;
	 @:isVar static public var state(get, never) : AntState;
	 @:isVar static public var anthill(get, never) : Anthill;
	 @:isVar static public var numOfActive(get, never) : Int;
	 @:isVar static public var numOfVisible(get, never) : Int;
	 @:isVar static public var numOnScreen(get, never) : Int;

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	/**

	 * Название фреймворка.

	 */
	static public var LIB_NAME : String = "Anthill Alpha";
	/**

	 * Версия основного релиза.

	 */
	static public var LIB_MAJOR_VERSION : UInt = 0;
	/**

	 * Версия второстепенного релиза.

	 */
	static public var LIB_MINOR_VERSION : UInt = 3;
	/**

	 * Версия обслуживания.

	 */
	static public var LIB_MAINTENANCE : UInt = 2;
	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**

	 * Указатель на <code>stage</code>.

	 * Устанавливается автоматически при инициализации.

	 * @default	null

	 */
	static public var stage : Stage;
	/**

	 * Размер окна по ширине. 

	 * Определяется автоматически при инициализации.

	 * @default	stage.stageWidth

	 */
	static public var width : Int;
	/**

	 * Размер окна по высоте.

	 * Определяется автоматически при инициализации.

	 * @default	stage.stageHeight

	 */
	static public var height : Int;
	/**

	 * Половина ширины окна или центр экрана по X.

	 * Определяется автоматически при инициализации.

	 * @default	(stage.stageWidth / 2)

	 */
	static public var widthHalf : Int;
	/**

	 * Половина высоты окна или центр экрана по Y.

	 * Определяется автоматически при инициализации.

	 * @default	(stage.stageHeight / 2)

	 */
	static public var heightHalf : Int;
	/**

	 * Как быстро протекает время в игровом мире. 

	 * Изменяя этот параметр можно получить эффект слоу-мо.

	 * @default	0.5

	 */
	static public var timeScale : Float;
	/**

	 * Временной промежуток прошедший между предыдущим и текущим кадром (deltaTime).

	 * @default	0.02

	 */
	static public var elapsed : Float;
	/**

	 * Максимально допустимый временной промежуток прошедший между предыдущим и текущим кадром.

	 * @default	0.0333333

	 */
	static public var maxElapsed : Float;
	/**

	 * Массив добавленных камер.

	 */
	static public var cameras : Array<Dynamic>;
	/**

	 * Указатель на последнюю добавленную камеру. Для безопасного получения указателя

	 * на текущую камеру используйте метод: <code>AntG.getCamera();</code>

	 * @default	null

	 */
	static public var camera : AntCamera;
	/**

	 * Список добавленных плагинов.

	 */
	static public var plugins : Vector<IPlugin>;
	/**

	 * Указатель на класс для работы с мышкой.

	 */
	static public var mouse : AntMouse;
	/**

	 * Указатель на класс для работы с клавиатурой.

	 */
	static public var keys : AntKeyboard;
	/**

	 * Указатель на класс для работы со звуками.

	 */
	static public var sounds : AntSoundManager;
	/**

	 * Указатель на отладчик.

	 */
	static public var debugger;
	//:AntDebugger;
	/**

	 * Указатель на дебаг отрисовщик.

	 * @default	null

	 */
	//public static var debugDrawer:AntDrawer;
	/**

	 * Указатель на класс следящий за удалением объектов из памяти.

	 */
	//public static var memory:AntMemory;
	/**

	 * Указатель на метод <code>track()</code> класса <code>AntMemory</code>, для добавления объектов в список слежения.

	 * 

	 * <p>Чтобы посмотреть содержимое <code>AntMemory</code>, наберите в консоли команду "-gc", после чего будет 

	 * принудительно вызван сборщик мусора и выведена информация о всех объектах которые по каким-либо причинам 

	 * сохранились в <code>AntMemory</code>.</p>

	 * 

	 * <p>Пример использования:</p>

	 * <pre>AntG.track(myObject);</pre>

	 */
	static public var track : Dynamic;
	/**

	 * Указатель на метод <code>registerCommand()</code> класса <code>AntConsole</code> 

	 * для добавления простых пользовательских команд в консоль.

	 * 

	 * <p>Пример использования:</p>

	 * <pre>AntG.registerCommand("test", myMethod, "Тестовый метод.");</pre>

	 */
	static public var registerCommand : Dynamic;
	/**

	 * Указатель на метод <code>registerCommandWithArgs()</code> класса <code>AntConsole</code>

	 * для добавления пользовательских команд с поддержкой аргументов в консоль.

	 * 

	 * <p>Пример использования:</p>

	 * <pre>AntG.registerCommandWithArgs("test", myMethod, [ String, int ], "Тестовый метод с аргументами.");</pre>

	 */
	static public var registerCommandWithArgs : Dynamic;
	/**

	 * Указатель на метод <code>unregisterCommand()</code> класса <code>AntConsole</code> для быстрого удаления 

	 * зарегистрированных пользовальских команд из консоли.

	 * 

	 * <p>Примичание: в качестве идентификатора команды может быть указатель на метод который выполняет команда.</p>

	 * 

	 * <p>Пример использования:</p>

	 * <pre>AntG.unregisterCommand("test");</pre>

	 */
	static public var unregisterCommand : Dynamic;
	/**

	 * Указатель на метод <code>log()</code> класса <code>AntConsole</code> для быстрого 

	 * вывода любой информации в консоль.

	 * 

	 * <p>Пример использования:</p>

	 * <pre>AntG.log(someData);</pre>

	 */
	static public var log : Dynamic;
	/**

	 * Указатель на метод <code>watchValue()</code> класса <code>AntMonitor</code> используется 

	 * для добавления или обновления значения в "мониторе". 

	 * 

	 * <p>Пример использования:</p>

	 * <pre>AntG.watchValue("valueName", value);</pre>

	 */
	static public var watchValue : Dynamic;
	/**

	 * Указатель на метод <code>unwatchValue()</code> класса <code>AntMonitor</code> используется

	 * для удаления записи о значении из "монитора". 

	 * 

	 * <p>Пример использования:</p> 

	 * <pre>AntG.unwatchValue("valueName");</pre>

	 */
	static public var unwatchValue : Dynamic;
	/**

	 * Указатель на метод <code>beginWatch()</code> класса <code>AntMonitor</code> используется

	 * для блокировки обновления окна монитора при обновлении сразу двух и более значений 

	 * в мониторе.

	 * 

	 * <p>Пример использования:</p>

	 * 

	 * <listing>

	 * AntG.beginWatch();

	 * AntG.watchValue("someValue1", value1);

	 * AntG.watchValue("someValue2", value2);

	 * AntG.endWatch();

	 * </listing>

	 */
	static public var beginWatch : Dynamic;
	/**

	 * Указатель на метод <code>endWatch()</code> класса <code>AntMonitor</code> используется 

	 * для снятия блокировки обновления окна монитора при обновлнии сразу двух и более значений 

	 * в мониторе.

	 */
	static public var endWatch : Dynamic;
	/**

	 * Блокирует переход по внешним ссылкам.

	 * @default	false

	 */
	static public var lockExternalLinks : Bool;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * Указатель на экземпляр класса <code>Anthill</code>.

	 */
	static var _anthill : Anthill;
	/**

	 * Определяет отладочный режим для Anthill.

	 * 

	 * <p>Если отладочный режим отключен, то консоль и другие отладочные инструменты не доступны 

	 * для просмотра.</p>

	 * 

	 * @default	true

	 */
	static var _debugMode : Bool;
	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Инициализация глобального хранилища и его переменных. Вызывается автоматически при инициализации игрового движка.

	 * @param	aAnthill	 Указатель на ядро фреймворка.

	 */
	static public function init(aAnthill : Anthill) : Void {
		timeScale = 0.5;
		elapsed = 0.02;
		maxElapsed = 0.0333333;
		_anthill = aAnthill;
		_debugMode = true;
		stage = _anthill.stage;
		width = stage.stageWidth;
		height = stage.stageHeight;
		widthHalf = Std.int(stage.stageWidth * 0.5);
		heightHalf = Std.int(stage.stageHeight * 0.5);
		cameras = [];
		plugins = new Vector<IPlugin>();
		mouse = new AntMouse();
		keys = new AntKeyboard();
		sounds = new AntSoundManager();
		/*debugger = new AntDebugger();

		debugDrawer = null;



		track = AntMemory.track;

		

		registerCommand = debugger.console.registerCommand;

		registerCommandWithArgs = debugger.console.registerCommandWithArgs;

		unregisterCommand = debugger.console.unregisterCommand;

		log = debugger.console.log;

		

		watchValue = debugger.monitor.watchValue;

		unwatchValue = debugger.monitor.unwatchValue;

		beginWatch = debugger.monitor.beginWatch;

		endWatch = debugger.monitor.endWatch;*/
		lockExternalLinks = false;
	}

	/**

	 * Позволяет задать размеры окна вручную.

	 * 

	 * <p>Примичание: по умолчанию размер экрана определятся исходя из размера <code>stage.stageWidth</code>

	 * и <code>stage.stageHeight.</code></p>

	 * 

	 * <p>Внимание: изменение размеров экрана никак не влияет на работу с камерами.</p>

	 * 

	 * @param	aWidth	 Новая ширина экрана.

	 * @param	aHeight	 Новая высота экрана.

	 */
	static public function setScreenSize(aWidth : Int, aHeight : Int) : Void {
		width = aWidth;
		height = aHeight;
		widthHalf = Std.int(aWidth * 0.5);
		heightHalf = Std.int(aHeight * 0.5);
	}

	/**

	 * Сбрасывает текущее состояние средств пользовательского ввода.

	 */
	static public function resetInput() : Void {
		mouse.reset();
		keys.reset();
	}

	/**

	 * Обработка классов пользовательского ввода.

	 */
	static public function updateInput() : Void {
		mouse.update(Std.int(stage.mouseX), Std.int(stage.mouseY));
		keys.update();
	}

	/**

	 * Обработка классов звука.

	 */
	static public function updateSounds() : Void {
		sounds.update();
	}

	/**

	 * Обработка плагинов.

	 */
	static public function updatePlugins() : Void {
		var i : Int = 0;
		var n : Int = plugins.length;
		var plugin : IPlugin;
		while(i < n) {
			plugin = try cast(plugins[i++], IPlugin) catch(e:Dynamic) null;
			if(plugin != null)  {
				plugin.update();
			}
		}

	}

	/**

	 * Отрисовка плагинов.

	 */
	static public function drawPlugins(aCamera : AntCamera) : Void {
		var i : Int = 0;
		var n : Int = plugins.length;
		var plugin : IPlugin;
		while(i < n) {
			plugin = try cast(plugins[i++], IPlugin) catch(e:Dynamic) null;
			if(plugin != null)  {
				plugin.draw(aCamera);
			}
		}

	}

	/**

	 * Добавляет плагин в список для обработки.

	 * 

	 * @param	aPlugin	 Плагин который необходимо добавить.

	 * @param	aSingle	 Если true то один и тот же экземпляр плагина не может быть добавлен дважды.

	 * @return		Возвращает указатель на добавленный плагин.

	 */
	static public function addPlugin(aPlugin : IPlugin, aSingle : Bool = true) : IPlugin {
		if(aSingle && plugins.indexOf(aPlugin) > -1)  {
			return aPlugin;
		}
		var i : Int = 0;
		var n : Int = plugins.length;
		while(i < n) {
			if(plugins[i] == null)  {
				plugins[i] = aPlugin;
				return aPlugin;
			}
			i++;
		}

		plugins.push(aPlugin);
		return aPlugin;
	}

	/**

	 * Удаляет плагин из списка для обработки.

	 * 

	 * @param	aPlugin	 Плагин который необходимо удалить.

	 * @param	aSplice	 Если true то элемент массива в котором размещался плагин так же будет удален.

	 * @default	Возвращает указатель на удаленный плагин.

	 */
	static public function removePlugin(aPlugin : IPlugin, aSplice : Bool = false) : IPlugin {
		var i : Int = plugins.indexOf(aPlugin);
		if(i >= 0 && i < plugins.length)  {
			plugins[i] = null;
			if(aSplice)  {
				plugins.splice(i, 1);
			}
		}
		return aPlugin;
	}

	/**

	 * Добавляет камеру в список для обработки.

	 * 

	 * @param	aCamera	 Камера которую необходимо добавить.

	 * @return		Возвращает указатель на добавленную камеру.

	 */
	static public function addCamera(aCamera : AntCamera) : AntCamera {
		if(cameras.indexOf(aCamera) > -1)  {
			return aCamera;
		}
		if(_anthill.state == null)  {
			throw new flash.errors.Error("Before adding the Camera need to initialize game state.");
		}
		if(!_anthill.state.contains(aCamera._flashSprite))  {
			_anthill.state.addChild(aCamera._flashSprite);
		}
		var i : Int = 0;
		var n : Int = cameras.length;
		while(i < n) {
			if(cameras[i] == null)  {
				cameras[i] = aCamera;
				camera = aCamera;
				return aCamera;
			}
			i++;
		}

		cameras.push(aCamera);
		camera = aCamera;
		return aCamera;
	}

	/**

	 * Удаляет камеру из игрового движка.

	 * 

	 * @param	aCamera	 Камера которую необходимо удалить.

	 * @param	aSplice	 Если true то элемент массива в котором размещалась камера так же будет удален.

	 * @return		Возвращает указатель на удаленную камеру.

	 */
	static public function removeCamera(aCamera : AntCamera, aSplice : Bool = false) : AntCamera {
		var i : Int = cameras.indexOf(aCamera);
		if(i < 0 || i >= cameras.length)  {
			return aCamera;
		}
		if(_anthill.state != null && _anthill.state.contains(aCamera._flashSprite))  {
			_anthill.state.removeChild(aCamera._flashSprite);
		}
		cameras[i] = null;
		if(aSplice)  {
			cameras.splice(i, 1);
		}
		if(camera == aCamera)  {
			camera = null;
		}
		return aCamera;
	}

	/**

	 * Безопасный метод извлечения камеры.

	 * 

	 * @param	aIndex	 Индекс камеры которую необходимо получить.

	 * @return		Указатель на камеру.

	 */
	static public function getCamera(aIndex : Int = -1) : AntCamera {
		if(aIndex == -1)  {
			return camera;
		}
		if(aIndex >= 0 && aIndex < cameras.length)  {
			return cameras[aIndex];
		}
		return null;
	}

	/**

	 * Переключает игровые состояния.

	 * 

	 * @param	aState	 Новое состояние на которое необходимо произвести переключение.

	 */
	static public function switchState(aState : AntState) : AntState {
		if(_anthill != null)  {
			_anthill.switchState(aState);
		}
		return aState;
	}

	/**

	 * Выполняет переход по внешней ссылке.

	 * 

	 * @param	aUrl	 Внешняя ссылка по которой необходимо выполнить переход.

	 * @param	aTarget	 Атрибут target для ссылки.

	 */
	static public function openUrl(aUrl : String, aTarget : String = "_blank") : Void {
		if(!lockExternalLinks)  {
			//navigateToURL(new URLRequest(aUrl), aTarget);
			Lib.getURL(new URLRequest(aUrl), aTarget);
		}
	}

	//---------------------------------------
	// GETTER / SETTERS
	//---------------------------------------
	/**

	 * @private

	 */
	static function get_debugMode() : Bool {
		return _debugMode;
	}

	static function set_debugMode(value : Bool) : Bool {
		/*_debugMode = value;

		if (!_debugMode && debugger.visible)

		{

		debugger.hide();

		}*/
		return value;
	}

	/**

	 * Определяет используется в игре системный курсор или нет.

	 */
	static function get_useSystemCursor() : Bool {
		return ((_anthill != null)) ? _anthill._useSystemCursor : true;
	}

	static function set_useSystemCursor(value : Bool) : Bool {
		if(_anthill != null)  {
			if(_anthill._useSystemCursor != value)  {
				_anthill._useSystemCursor = value;
				/*if (!debugger.visible)

				{

				(value) ? Mouse.show() : Mouse.hide();

				}*/
			}
		}
		return value;
	}

	/**

	 * Определяет частоту кадров.

	 */
	static function get_frameRate() : UInt {
		return ((stage != null)) ? cast stage.frameRate : 0;
	}

	static function set_frameRate(value : UInt) : UInt {
		if(stage != null)  {
			stage.frameRate = value;
		}
		return value;
	}

	/**

	 * Возвращает указатель на текущее игровое состояние.

	 */
	static function get_state() : AntState {
		return ((_anthill != null)) ? _anthill.state : null;
	}

	/**

	 * Возвращает указатель на экземпляр Anthill.

	 */
	static function get_anthill() : Anthill {
		return _anthill;
	}

	/**

	 * Возвращает кол-во объектов для которых были вызваны методы процессинга (exist = true).

	 */
	static function get_numOfActive() : Int {
		return AntBasic.NUM_OF_ACTIVE;
	}

	/**

	 * Возвращает кол-во объектов для которых был вызван метод отрисовки (visible = true).

	 */
	static function get_numOfVisible() : Int {
		return AntBasic.NUM_OF_VISIBLE;
	}

	/**

	 * Возвращает кол-во объектов которые были отрисованы (попали в видимость одной или нескольких камер).

	 * 

	 * <p>Примичание: если один и тот же объект попадет в видимость двух камер, то такой объект будет 

	 * посчитан дважды.</p>

	 */
	static function get_numOnScreen() : Int {
		return AntBasic.NUM_ON_SCREEN;
	}

}
