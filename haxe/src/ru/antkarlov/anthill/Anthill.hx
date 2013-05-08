//import ru.antkarlov.anthill.debug.AntPerfomance;
package ru.antkarlov.anthill;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Mouse;


class Anthill extends Sprite {

	//Flex v4.x SDK
	// Обычное подключение шрифта.
	//[Embed(source="resources/iFlash706.ttf",fontFamily="system",embedAsCFF="false")] protected var junk:String;
	// Обычное подключение шрифта с кирилицой.
	@:meta(Embed(source="resources/iFlash706.ttf",fontFamily="system",embedAsCFF="false",unicodeRange="U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+0400-U+04CE,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183"))
	var junk : String;
	//*/
	//Flex v3.x SDK
	// Подключение шрифта.
	//[Embed(source="resources/iFlash706.ttf",fontFamily="system")] protected var junk:String;
	// Подключение шрифта с кирилицой.
	/*[Embed(source= "resources/iFlash706.ttf",fontFamily="system",mimeType="application/x-font",

	unicodeRange="U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+0400-U+04CE,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183")] protected var junk:String;

	//*/
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * Указатель на текущее игровое состояние.

	 */
	public var state : AntState;
	public var cameras : Array<Dynamic>;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * @private

	 */
	var _defaultCamera : AntCamera;
	/**

	 * Класс игрового состояния которое будет создано при инициализации.

	 */
	var InitialState : Class<Dynamic>;
	/**

	 * Количество кадров в секунду при инициализации.

	 * @default	35

	 */
	var _frameRate : UInt;
	/**

	 * Флаг определяющий инициализацию фреймворка.

	 * @default	false

	 */
	var _isCreated : Bool;
	/**

	 * Флаг определяющий запуск процесса обработки фреймворка.

	 */
	var _isStarted : Bool;
	/**

	 * Помошник для рассчета игрового времени.

	 */
	var _elapsed : Float;
	/**

	 * Помошник для рассчета игрового времени.

	 */
	public var _total : UInt;
	/**

	 * Указатель на сборщик информации о производительности.

	 */
	//	protected var _perfomance:AntPerfomance;
	/**

	 * Определяет используется в игре системный курсор или нет.

	 * @default	true

	 */
	public var _useSystemCursor : Bool;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new(aInitialState : Class<Dynamic> = null, aFrameRate : UInt = 35, aUseSystemCursor : Bool = true) {
		super();
		_useSystemCursor = aUseSystemCursor;
		if(!_useSystemCursor)  {
			Mouse.hide();
		}
		InitialState = aInitialState;
		_frameRate = aFrameRate;
		_isCreated = false;
		_isStarted = false;
		((stage == null)) ? addEventListener(Event.ADDED_TO_STAGE, create) : create(null);
	}

	/**

	 * Инициализация фреймворка.

	 * 

	 * @param	event	 Стандартное события Flash.

	 */
	function create(event : Event) : Void {
		if(event != null)  {
			removeEventListener(Event.ADDED_TO_STAGE, create);
		}
		AntG.init(this);
		//_perfomance = AntG.debugger.perfomance;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = _frameRate;
		//stage.addEventListener(KeyboardEvent.KEY_DOWN, AntG.debugger.console.keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, AntG.keys.keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, AntG.keys.keyUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, AntG.mouse.mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, AntG.mouse.mouseUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_OUT, AntG.mouse.mouseOutHandler);
		stage.addEventListener(MouseEvent.MOUSE_OVER, AntG.mouse.mouseOverHandler);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, AntG.mouse.mouseWheelHandler);
		//_perfomance.start();
		_isCreated = true;
		if(InitialState != null)  {
			switchState(cast(Type.createInstance(InitialState, []), AntState));
			start();
		}
	}

	/**

	 * Запускает процессинг фреймворка.

	 */
	public function start() : Void {
		if(!_isStarted && _isCreated)  {
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_isStarted = true;
		}
	}

	/**

	 * Останавливает процессинг фреймворка.

	 */
	public function stop() : Void {
		if(_isStarted && _isCreated)  {
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_isStarted = false;
		}
	}

	/**

	 * Переключает игровые состояния.

	 * 

	 * @param	aState	 Новое состояние на которое необходимо произвести переключение.

	 */
	public function switchState(aState : AntState) : Void {
		addChild(aState);
		if(state != null)  {
			state.destroy();
			swapChildren(state, aState);
			removeChild(state);
			if(_defaultCamera != null && AntG.camera == _defaultCamera)  {
				AntG.removeCamera(_defaultCamera);
			}
		}
		state = aState;
		state.create();
		// Если камера не создана состоянием, создаем камеру по умолчанию.
		if(AntG.camera == null)  {
			if(_defaultCamera == null)  {
				_defaultCamera = new AntCamera(0, 0, AntG.width, AntG.height);
				_defaultCamera.fillBackground = true;
			}
			AntG.addCamera(_defaultCamera);
		}

		else if(AntG.camera != null && _defaultCamera != null && AntG.camera != _defaultCamera)  {
			_defaultCamera.destroy();
			_defaultCamera = null;
		}
		if(!_isStarted)  {
			start();
		}
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * Основной обработчик.

	 */
	function enterFrameHandler(event : Event) : Void {
		// Рассчет времени между кадрами.
		var curTime : UInt = flash.Lib.getTimer();
		var elapsedMs : UInt = curTime - _total;
		//_perfomance.ratingTotal.add(elapsedMs);
		_elapsed = elapsedMs / 1000;
		_total = curTime;
		AntG.elapsed = ((_elapsed > AntG.maxElapsed)) ? AntG.maxElapsed : _elapsed;
		AntG.elapsed *= AntG.timeScale;
		// Процессинг.
		update();
		// Расчет времени ушедшего на процессинг.
		var updTime : UInt = flash.Lib.getTimer();
		//_perfomance.ratingUpdate.add(updTime - curTime);
		// Рендер графического контента.
		render();
		// Рассчет времени ушедшего на рендер.
		var rndTime : UInt = flash.Lib.getTimer();
		//_perfomance.ratingRender.add(rndTime - updTime);
		AntG.updatePlugins();
		// Рассчет времени ушедшего на плагины.
		//	_perfomance.ratingPlugins.add(flash.Lib.getTimer() - rndTime);
		//AntG.debugger.update();
	}

	/**

	 * Выполняет процессинг содержимого игры.

	 */
	function update() : Void {
		AntG.updateInput();
		AntG.updateSounds();
		AntBasic.NUM_OF_ACTIVE = 0;
		AntEntity.DEPTH_ID = 0;
		if(state != null)  {
			state.preUpdate();
			state.update();
			state.postUpdate();
		}
	}

	/**

	 * Выполняет рендеринг содержимого игры.

	 */
	function render() : Void {
		AntBasic.NUM_OF_VISIBLE = 0;
		AntBasic.NUM_ON_SCREEN = 0;
		if(cameras == null)  {
			cameras = AntG.cameras;
		}
		var debugDraw : Bool = false;
		//(AntG.debugDrawer != null);
		var i : Int = 0;
		var n : Int = cameras.length;
		var camera : AntCamera;
		while(i < n) {
			camera = try cast(cameras[i++], AntCamera) catch(e:Dynamic) null;
			if(camera != null && camera.exists)  {
				camera.update();
				if(debugDraw)  {
					//AntG.debugDrawer.buffer = camera.buffer;
				}
				camera.beginDraw();
				// Отрисовка содержимого для текущего состояния.
				if(state != null && state.defGroup.exists && state.defGroup.visible)  {
					state.defGroup.draw(camera);
					if(debugDraw)  {
						state.defGroup.debugDraw(camera);
					}
				}
				AntG.drawPlugins(camera);
				camera.endDraw();
				if(debugDraw)  {
					//AntG.debugDrawer.buffer = null;
				}
			}
		}

		AntG.mouse.draw();
	}

}

