/**

 * Анимированная маска которая может быть применена к любой сущности.

 * 

 * <p>Работа с маской очень похожа на работу с актером. Для маски подходят точно

 * такие же анимации как и для актеров. При использовании анимации прозрачные области

 * кадров считаются как не прозрачные, а непрозрачные области являются своеобразным

 * окном в которое можно видеть что находится под маской.</p>

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  26.02.2013

 */
package ru.antkarlov.anthill;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import msignal.Signal;

class AntMask extends AntBasic {
	@:isVar public var isPlaying(get, never) : Bool;
	@:isVar public var currentAnimation(get, never) : String;

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	public var buffer : BitmapData;
	/**

	 * Положение маски по X относительно сущности к которой она применена.

	 * @default	0

	 */
	public var x : Float;
	/**

	 * Положение маски по Y относительно сущности к которой она применена.

	 * @default	0

	 */
	public var y : Float;
	/**

	 * Размер маски по ширине, зависит от размера текущего кадра анимации.

	 * @default	0

	 */
	public var width : Int;
	/**

	 * Размер маски по высоте, зависит от размера текущего кадра анимации.

	 * @default	0

	 */
	public var height : Int;
	/**

	 * Глобальная позиция маски по X в игровом мире с учетом положения сущности

	 * к которой применена маска.

	 * @default	0

	 */
	public var globalX : Float;
	/**

	 * Глобальная позиция маски по Y в игровом мире с учетом положения сущности

	 * к которой применена маска.

	 * @default	0

	 */
	public var globalY : Float;
	/**

	 * Осевая точка маски.

	 * @default	(0,0)

	 */
	public var origin : AntPoint;
	/**

	 * Флаг определяющий следует ли выполнять заливку буфера маски.

	 * @default	false

	 */
	public var fillBackground : Bool;
	/**

	 * Цвет которым будет заливаться буфер маски.

	 * @default	0xFF000000

	 */
	public var backgroundColor : UInt;
	/**

	 * Номер текущего кадра с учетом скорости анимации. Значение может быть дробным.

	 * @default	1

	 */
	public var currentFrame : Float;
	/**

	 * Общее количество кадров для текущей анимации.

	 * @default	1

	 */
	public var totalFrames : Int;
	/**

	 * Проигрывание анимации в обратном порядке.

	 * @default	false

	 */
	public var reverse : Bool;
	/**

	 * Зациклинность воспроизведения анимации.

	 * @default	true

	 */
	public var repeat : Bool;
	/**

	 * Скорость воспроизведения анимации.

	 * @default	1

	 */
	public var animationSpeed : Float;
	/**

	 * Событие срабатывающее по окончанию проигрывания анимации.

	 * Добавляемый метод должен иметь аргумент типа <code>function onComplete(actor:AntActor):void {}</code>

	 */
	public var eventComplete : Signal1<Dynamic>;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	var _animations : AntStorage;
	var _curAnim : AntAnimation;
	var _curAnimName : String;
	var _playing : Bool;
	var _prevFrame : Int;
	var _pixels : BitmapData;
	var _backendBuffer : BitmapData;
	var _flashRect : Rectangle;
	var _flashPointZero : Point;
	var _flashPointTarget : Point;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new() {
		super();
		x = 0;
		y = 0;
		width = 0;
		height = 0;
		globalX = 0;
		globalY = 0;
		origin = new AntPoint();
		_flashRect = new Rectangle(0, 0, width, height);
		_flashPointZero = new Point();
		_flashPointTarget = new Point();
		fillBackground = false;
		backgroundColor = 0xFF000000;
		//--
		currentFrame = 1;
		totalFrames = 0;
		reverse = false;
		repeat = true;
		animationSpeed = 1;
		eventComplete = new Signal1(AntMask);
		_animations = new AntStorage();
		_curAnim = null;
		_curAnimName = null;
		_playing = false;
		_prevFrame = -1;
		_pixels = null;
	}

	/**

	 * @inheritDoc

	 */
	override public function destroy() : Void {
		_animations.clear();
		_animations = null;
		_curAnim = null;
		eventComplete.destroy();
		eventComplete = null;
		_pixels = null;
		super.destroy();
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Добавляет новую анимацию. Если локальное имя анимации не указано, то добавленная анимация будет доступна

	 * по глобальному имени.

	 * 

	 * @param	aAnim	 Анимация которую необходимо добавить.

	 * @param	aName	 Локальное имя анимации по которому можно будет произвести переключение на эту анимацию.

	 * @param	aSwitch	 Переключение на добавленную анимацию.

	 */
	public function addAnimation(aAnim : AntAnimation, aName : String = null, aSwitch : Bool = true) : Void {
		if(aName == null)  {
			aName = aAnim.name;
		}
		_animations.set(aName, aAnim);
		if(aSwitch)  {
			switchAnimation(aName);
		}
	}

	/**

	 * Добавляет новую анимацию из кэша анимаций. Если локальное имя анимации не указано, то добавленная анимация 

	 * будет доступна по глобальному имени.

	 * 

	 * @param	aKey	 Имя анимации в кэше которую необходимо добавить.

	 * @param	aName	 Локальное имя анимации по которому можно будет произвести переключение на эту анимацию.

	 * @param	aSwitch	 Переключение на добавленную анимацию.

	 */
	public function addAnimationFromCache(aKey : String, aName : String = null, aSwitch : Bool = true) : Void {
		addAnimation(AntAnimation.fromCache(aKey), aName, aSwitch);
	}

	/**

	 * Переключение анимации.

	 * 

	 * @param	aName	 Локальное имя анимации на которую следует переключится.

	 */
	public function switchAnimation(aName : String) : Void {
		if(_curAnimName == aName)  {
			return;
		}
		if(_animations.containsKey(aName))  {
			_curAnim =  cast(_animations.get(aName), AntAnimation);
			_curAnimName = aName;
			currentFrame = 1;
			totalFrames = _curAnim.totalFrames;
			resetHelpers();
		}

		else  {
			throw new flash.errors.Error("AntMask: Missing animation '" + aName + "'.");
		}

	}

	/**

	 * Удаляет анимацию с указанным именем.

	 * 

	 * @param	aName	 Локальное имя анимации которую необходимо удалить.

	 */
	public function removeAnimation(aName : String) : Void {
		if(_animations.containsKey(aName))  {
			_animations.remove(aName);
		}
	}

	/**

	 * Удаляет все анимации из актера.

	 */
	public function clearAnimations() : Void {
		_animations.clear();
	}

	/**

	 * Запускает воспроизведение текущией анимации.

	 */
	public function play() : Void {
		_playing = true;
	}

	/**

	 * Останавливает воспроизведение текущей анимации.

	 */
	public function stop() : Void {
		_playing = false;
	}

	/**

	 * Переводит текущую анимацию на указанный кадр и останавливает воспроизведение.

	 * 

	 * @param	aFrame	 Номер кадра на который необходимо перевести текущую анимацию.

	 */
	public function gotoAndStop(aFrame : Float) : Void {
		currentFrame = ((aFrame <= 0)) ? 1 : ((aFrame > totalFrames)) ? totalFrames : aFrame;
		goto(currentFrame);
		stop();
	}

	/**

	 * Переводит текущую анимацию актера на указанный кадр и запускает воспроизведение.

	 * 

	 * @param	aFrame	 Номер кадра на который необходимо перевести текущую анимацию.

	 */
	public function gotoAndPlay(aFrame : Float) : Void {
		currentFrame = ((aFrame <= 0)) ? 1 : ((aFrame > totalFrames)) ? totalFrames : aFrame;
		goto(currentFrame);
		play();
	}

	/**

	 * Запускает воспроизведение текущей анимации со случайного кадра.

	 */
	public function playRandomFrame() : Void {
		gotoAndPlay(AntMath.randomRangeInt(1, totalFrames));
	}

	/**

	 * Выполняет переход к следущему кадру текущей анимации.

	 * 

	 * @param	aUseSpeed	 Флаг определяющий следует ли при переходе к следущему кадру использовать скорость анимации.

	 */
	public function nextFrame(aUseSpeed : Bool = false) : Void {
		(aUseSpeed) ? currentFrame += animationSpeed * AntG.timeScale : currentFrame++;
		goto(currentFrame);
	}

	/**

	 * Выполняет переход к предыдущему кадру текущей анимации.

	 * 

	 * @param	aUseSpeed	 Флаг определяющий следует ли при переходе к предыдущему кадру использовать скорость анимации.

	 */
	public function prevFrame(aUseSpeed : Bool = false) : Void {
		(aUseSpeed) ? currentFrame -= animationSpeed * AntG.timeScale : currentFrame--;
		goto(currentFrame);
	}

	/**

	 * Обновляет позицию маски с учетом родительской сущности и текущей камеры.

	 * 

	 * @param	aParent	 Указатель на сущность для которой применена маска.

	 * @param	aCamera	 Текущая камера.

	 */
	public function updatePosition(aParent : AntEntity, aCamera : AntCamera) : Void {
		globalX = aParent.globalX + aCamera.scroll.x * aParent.scrollFactor.x + x + origin.x;
		globalY = aParent.globalY + aCamera.scroll.y * aParent.scrollFactor.y + y + origin.y;
	}

	/**

	 * @inheritDoc

	 */
	override public function update() : Void {
		updateAnimation();
		if(fillBackground && _curAnim != null)  {
			buffer.fillRect(_flashRect, backgroundColor);
		}
		super.update();
	}

	/**

	 * Применяет альфа канал к буферу маски и выполняет отрисовку содержимого буфера в указанный битмап.

	 * 

	 * @param	aTarget	 Битмап в который будет отрисовано содержимое буфера маски.

	 */
	public function drawTo(aTarget : BitmapData) : Void {
		if(_curAnim != null && _pixels != null)  {
			_flashPointTarget.x = globalX;
			_flashPointTarget.y = globalY;
			_backendBuffer.copyPixels(_pixels, _flashRect, _flashPointZero, null, null, false);
			_backendBuffer.merge(buffer, _flashRect, _flashPointZero, 0x100, 0x100, 0x100, 0);
			aTarget.copyPixels(_backendBuffer, _flashRect, _flashPointTarget, null, null, true);
		}
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * Сброс внутренних помошников.

	 */
	function resetHelpers() : Void {
		_flashRect.x = _flashRect.y = 0;
		if(buffer == null || buffer.width != _curAnim.width || buffer.height != _curAnim.height)  {
			if(buffer != null) buffer.dispose();
			if(_backendBuffer != null) _backendBuffer.dispose();
			buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
			_backendBuffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
		}
		calcFrame();
	}

	/**

	 * Перерасчет текущего кадра.

	 */
	function calcFrame(aFrame : Int = 0) : Void {
		origin.set(_curAnim.offsetX[aFrame], _curAnim.offsetY[aFrame]);
		_pixels = _curAnim.frames[aFrame];
		width = _pixels.width;
		height = _pixels.height;
		_flashRect.width = _pixels.width; //try cast(_pixels.width, Float) catch(e:Dynamic) null;
		_flashRect.height = _pixels.height; //try cast(_pixels.height, Float) catch(e:Dynamic) null;
	}

	/**

	 * Обновление текущей анимации.

	 */
	function updateAnimation() : Void {
		if(_playing && _curAnim != null)  {
			if(reverse)  {
				currentFrame = ((currentFrame <= 1)) ? totalFrames : currentFrame;
				prevFrame(true);
				if(AntMath.floor(currentFrame) <= 1)  {
					currentFrame = 1;
					animComplete();
				}
			}

			else  {
				currentFrame = ((currentFrame >= totalFrames)) ? 1 : currentFrame;
				nextFrame(true);
				if(AntMath.floor(currentFrame) >= totalFrames)  {
					currentFrame = totalFrames;
					animComplete();
				}
			}

		}
	}

	/**

	 * Переводит текущую анимацию на указанный кадр.

	 * 

	 * @param	aFrame	 Кадр на который необходимо перевести текущую анимацию.

	 */
	function goto(aFrame : Float) : Void {
		var i : Int = Std.int(AntMath.floor(aFrame - 1)) ;/** WARNING check type **/
		i = ((i <= 0)) ? 0 : ((i >= totalFrames - 1)) ? totalFrames - 1 : i;
		if(_prevFrame != i)  {
			calcFrame(i);
			_prevFrame = i;
		}
	}

	/**

	 * Выполняется когда цикл проигрывания текущей анимации завершен.

	 */
	function animComplete() : Void {
		if(!repeat) stop();
		eventComplete.dispatch(this);
	}

	//---------------------------------------
	// GETTER / SETTERS
	//---------------------------------------
	/**

	 * Определяет проигрывается ли анимация.

	 */
	function get_isPlaying() : Bool {
		return _playing;
	}

	/**

	 * Возвращает имя текущей анимации.

	 */
	function get_currentAnimation() : String {
		return _curAnimName;
	}

}

