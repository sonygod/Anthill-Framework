/**
 * Класс обработчик событий мыши.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  20.05.2011
 */
package ru.antkarlov.anthill;

import flash.events.MouseEvent;
import msignal.Signal;

class AntMouse extends AntPoint {

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**
	 * Указатель на объект в который был произведен последний клик мышкой.
	 * @default	null
	 */
	public var target : Dynamic;
	/**
	 * Значение глубины колеса при прокрутке.
	 * @default	0
	 */
	public var wheelDelta : Int;
	/**
	 * Позиция курсора мыши на экране по X.
	 * @default	0
	 */
	public var screenX : Int;
	/**
	 * Позиция курсора мыши на экране по Y.
	 * @default	0
	 */
	public var screenY : Int;
	/**
	 * Графическое представление курсора мышки.
	 * @default	null
	 */
	public var cursor : AntActor;
	/**
	 * Имя анимации курсора мышки по умолчанию.
	 * @default	null
	 */
	public var defCursorAnim : String;
	/**
	 * Событие выполняющиеся при нажатии кнопки мыши.
	 */
	public var eventDown : Signal0;
	/**
	 * Событие выполняющиеся при отпускании кнопки мыши.
	 */
	public var eventUp : Signal0;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**
	 * @private
	 */
	var _cursorOffset : AntPoint;
	/**
	 * Помошник для хранения текущих координат мыши.
	 */
	var _globalScreenPos : AntPoint;
	/**
	 * @private
	 */
	var _current : Int;
	/**
	 * @private
	 */
	var _last : Int;
	/**
	 * @private
	 */
	var _out : Bool;
	/**
	 * @private
	 */
	var _currentWheel : Int;
	/**
	 * @private
	 */
	var _lastWheel : Int;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new() {
		_current = 0;
		_last = 0;
		_out = false;
		_currentWheel = 0;
		_lastWheel = 0;
		super();
		_cursorOffset = new AntPoint();
		_globalScreenPos = new AntPoint();
		target = null;
		wheelDelta = 0;
		screenX = 0;
		screenY = 0;
		cursor = null;
		defCursorAnim = null;
		eventDown = new Signal0();
		eventUp = new Signal0();
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**
	 * @private
	 */
	public function destroy() : Void {
		//
	}

	/**
	 * @private
	 */
	public function makeCursor(aAnimName : String, aOffsetX : Int = 0, aOffsetY : Int = 0) : Void {
		var switchAnim : Bool = false;
		if(cursor == null)  {
			cursor = new AntActor();
			cursor.isScrolled = false;
			switchAnim = true;
			defCursorAnim = aAnimName;
		}
		cursor.addAnimationFromCache(aAnimName, null, switchAnim);
		_cursorOffset.set(aOffsetX, aOffsetY);
	}

	/**
	 * @private
	 */
	public function show() : Void {
		if(cursor != null)  {
			cursor.revive();
		}
	}

	/**
	 * @private
	 */
	public function hide() : Void {
		if(cursor != null)  {
			cursor.kill();
		}
	}

	/**
	 * @private
	 */
	public function changeCursor(aAnimName : String = null) : Void {
		if(aAnimName == null)  {
			if(cursor != null && defCursorAnim != null)  {
				cursor.switchAnimation(defCursorAnim);
			}
		}

		else if(cursor != null)  {
			cursor.switchAnimation(aAnimName);
		}
	}

	/**
	 * Возвращает координаты мыши на экране.
	 * 
	 * @param	aCamera	 Указатель на камеру для которой необходимо получить координаты мыши.
	 * @param	aResult	 Указатель на точку куда может быть записан результат.
	 * @return		Возвращает координаты мыши на экране для указанной камеры.
	 */
	public function getScreenPosition(aCamera : AntCamera = null, aResult : AntPoint = null) : AntPoint {
		if(aCamera == null)  {
			aCamera = AntG.getCamera();
		}
		if(aResult == null)  {
			aResult = new AntPoint();
		}
		aResult.x = (_globalScreenPos.x - aCamera.x) / aCamera.zoom;
		aResult.y = (_globalScreenPos.y - aCamera.y) / aCamera.zoom;
		return aResult;
	}

	/**
	 * Возвращает координаты мыши в игровом мире.
	 * 
	 * @param	aCamera	 Указатель на камеру для которой необходимо получить координаты мыши.
	 * @param	aResult	 Указатель на куда может быть записан результат.
	 * @return		Возвращает координаты мыши в игровом мире исходя из указанной камеры.
	 */
	public function getWorldPosition(aCamera : AntCamera = null, aResult : AntPoint = null) : AntPoint {
		if(aCamera == null)  {
			aCamera = AntG.camera;
		}
		if(aResult == null)  {
			aResult = new AntPoint();
		}
		getScreenPosition(aCamera, aResult);
		aResult.x = aResult.x + aCamera.scroll.x * -1;
		aResult.y = aResult.y + aCamera.scroll.y * -1;
		return aResult;
	}

	/**
	 * Обновление состояния мышки.
	 */
	public function update(aX : Int, aY : Int) : Void {
		_globalScreenPos.x = aX;
		_globalScreenPos.y = aY;
		updateCursor();
		if(_last == -1 && _current == -1)  {
			_current = 0;
		}

		else if(_last == 2 && _current == 2)  {
			_current = 1;
		}
		_last = _current;
		// Обработка колесика мышки.
		if(AntMath.abs(_lastWheel) == 1 && AntMath.abs(_currentWheel) == 1)  {
			_currentWheel = 0;
		}

		else if(AntMath.abs(_lastWheel) == 2 && AntMath.abs(_currentWheel) == 2)  {
			_currentWheel = ((_currentWheel < 0)) ? _currentWheel + 1 : _currentWheel - 1;
		}
		_lastWheel = _currentWheel;
	}

	/**
	 * Отрисовка курсора мышки.
	 */
	public function draw() : Void {
		if(cursor != null && cursor.exists && cursor.visible)  {
			var cam : AntCamera;
			var i : Int = 0;
			var n : Int = AntG.cameras.length;
			while(i < n) {
				cam = try cast(AntG.cameras[i++], AntCamera) catch(e:Dynamic) null;
				if(cam != null)  {
					cursor.drawActor(cam);
				}
			}

		}
	}

	/**
	 * Сбрасывает текущее состояние мышки.
	 */
	public function reset() : Void {
		_current = 0;
		_last = 0;
		_currentWheel = 0;
		_lastWheel = 0;
	}

	/**
	 * Проверят нажала-ли кнопка мыши. Срабатывает постоянно пока кнопка мыши удерживается.
	 * 
	 * @return		Возвращает true если кнопка мыши нажата.
	 */
	public function isDown() : Bool {
		return _current > 0;
	}

	/**
	 * Проверяет нажата-ли кнопка мыши. Срабатывает только однажды в момент нажатия кнопки мыши.
	 * 
	 * @return		Возвращает true если кнопка мыши нажата.
	 */
	public function isPressed() : Bool {
		return _current == 2;
	}

	/**
	 * Проверяет отпущена-ли кнопка мышки. Срабатывает только однажды в момент отпускания кнопки мышки.
	 * 
	 * @return		Возвращает true если кнопка мыши отпущена.
	 */
	public function isReleased() : Bool {
		return _current == -1;
	}

	/**
	 * Проверяет вращение колеса мыши вниз.
	 * 
	 * @return		Возвращает true если колесо мыши крутится вниз.
	 */
	public function isWheelDown() : Bool {
		return _currentWheel < 0;
	}

	/**
	 * Проверяет вращение колеса мыши вверх.
	 * 
	 * @return		Возвращает true если колесе мыши крутится вверх.
	 */
	public function isWheelUp() : Bool {
		return _currentWheel > 0;
	}

	//---------------------------------------
	// EVENT HANDLERS
	//---------------------------------------
	/**
	 * @private
	 */
	function updateCursor() : Void {
		if(cursor != null && cursor.exists && cursor.active)  {
			cursor.update();
			cursor.globalX = Std.int(_globalScreenPos.x + _cursorOffset.x);
			cursor.globalY = Std.int(_globalScreenPos.y + _cursorOffset.y);
		}
		var camera : AntCamera = AntG.camera;
		screenX = Std.int(((_globalScreenPos.x - camera.x) / camera.zoom)) ;/** WARNING check type **/
		screenY = Std.int(((_globalScreenPos.y - camera.y) / camera.zoom)) ;/** WARNING check type **/
		x = screenX + camera.scroll.x;
		y = screenY + camera.scroll.y;
	}

	/**
	 * Обработчик события нажатия кнопки мыши.
	 */
	public function mouseDownHandler(event : MouseEvent) : Void {
		target = event.target;
		_current = ((_current > 0)) ? 1 : 2;
		eventDown.dispatch();
	}

	/**
	 * Обработчик соыбтия отпускания кнопки мыши.
	 */
	public function mouseUpHandler(event : MouseEvent) : Void {
		_current = ((_current > 0)) ? -1 : 0;
		eventUp.dispatch();
	}

	/**
	 * Обработчик события выхода мышки за пределы сцены.
	 */
	public function mouseOutHandler(event : MouseEvent) : Void {
		/*
		TODO 
		*/
	}

	/**
	 * Обработчик события возвращаения мышки в пределы сцены.
	 */
	public function mouseOverHandler(event : MouseEvent) : Void {
		/*
		TODO 
		*/
	}

	/**
	 * Обработчик события вращения колеса мышки.
	 */
	public function mouseWheelHandler(event : MouseEvent) : Void {
		wheelDelta = event.delta;
		if(wheelDelta > 0)  {
			_currentWheel = ((_currentWheel > 0)) ? 1 : 2;
		}

		else  {
			_currentWheel = ((_currentWheel > 0)) ? -1 : -2;
		}

	}

}

