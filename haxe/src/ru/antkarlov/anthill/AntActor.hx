/**

 * Данный класс занимается воспроизведением и отображением растеризированных анимаций.

 * От этого класса следует наследовать все визуальные игровые объекты.

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  21.08.2012

 */
//hi
//him,history,high
package ru.antkarlov.anthill;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import msignal.Signal;
import ru.antkarlov.anthill.AntBasic;

class AntActor extends AntEntity {
	@:isVar public var isPlaying(get, never) : Bool;
	@:isVar public var currentAnimation(get, never) : String;
	@:isVar public var alpha(get, set) : Float;
	@:isVar public var color(get, set) : UInt;

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**

	 * Режим смешивания цветов.

	 * @default	null

	 */
	public var blend : String;
	/**

	 * Сглаживание.

	 * @default	true

	 */
	public var smoothing : Bool;
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
	/**

	 * Текущая прозрачность.

	 * @default	1

	 */
	var _alpha : Float;
	/**

	 * Текущий цвет.

	 * @default	0x00FFFFFF

	 */
	var _color : UInt;
	/**

	 * Цветовая трансформация. Инициализируется автоматически если задан цвет отличный от 0x00FFFFFF.

	 * @default	null

	 */
	var _colorTransform : ColorTransform;
	/**

	 * Хранилище указателей на все добавленные анимации.

	 */
	var _animations : AntStorage;
	/**

	 * Указатель на текущую анимацию.

	 * @default	null

	 */
	var _curAnim : AntAnimation;
	/**

	 * Локальное имя текущей анимации.

	 * @default	null

	 */
	var _curAnimName : String;
	/**

	 * Флаг определяющий запущено ли проигрывание анимации.

	 * @default	false

	 */
	var _playing : Bool;
	/**

	 * Номер предыдущего кадра.

	 * @default	-1

	 */
	var _prevFrame : Int;
	/**

	 * Указатель на битмап кадра в текущей анимации.

	 */
	var _pixels : BitmapData;
	/**

	 * Вспомогательный буфер для рендера анимаций с цветовыми трансформациями.

	 * Инициализируется и удаляется автоматически при перекрашивании или прозрачности.

	 * @default	null

	 */
	var _buffer : BitmapData;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _flashRect : Rectangle;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _flashPoint : Point;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _flashPointZero : Point;
	/**

	 * Внутренний помошник для отрисовки графического контента.

	 */
	var _matrix : Matrix;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new() {
		blend = null;
		smoothing = true;
		currentFrame = 1;
		totalFrames = 0;
		reverse = false;
		repeat = true;
		animationSpeed = 1;
		eventComplete = new Signal1(AntActor);
		//new AntSignal(AntActor);
		_alpha = 1;
		_color = 0x00FFFFFF;
		_colorTransform = null;
		_animations = new AntStorage();
		_curAnim = null;
		_curAnimName = null;
		_playing = false;
		_prevFrame = -1;
		_pixels = null;
		_buffer = null;
		_flashRect = new Rectangle();
		_flashPoint = new Point();
		_flashPointZero = new Point();
		_matrix = new Matrix();
		super();
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
		_colorTransform = null;
		if(_buffer != null)  {
			_buffer.dispose();
			_buffer = null;
		}
		_pixels = null;
		super.destroy();
	}

	/**

	 * @inheritDoc

	 */
	override public function update() : Void {
		updateAnimation();
		super.update();
	}

	/**

	 * @inheritDoc

	 */
	override public function draw(aCamera : AntCamera) : Void {
		updateBounds();
		drawActor(aCamera);
		super.draw(aCamera);
	}

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
			_curAnim = cast(_animations.get(aName), AntAnimation);
			_curAnimName = aName;
			currentFrame = 1;
			totalFrames = _curAnim.totalFrames;
			resetHelpers();
		}

		else  {
			throw new flash.errors.Error("AntActor: Missing animation '" + aName + "'.");
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

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * Отрисовка актера в буффер указанной камеры.

	 * 

	 * @param	aCamera	 Камера в буффер которой необходимо отрисовать актера.

	 */
	public function drawActor(aCamera : AntCamera) : Void {
		AntBasic.NUM_OF_VISIBLE++;
		// Если нет текущего кадра или объект не попадает в камеру.
		if(_pixels == null || !onScreen(aCamera))  {
			return;
		}
		AntBasic.NUM_ON_SCREEN++;
		var p : AntPoint = getScreenPosition(aCamera);
		if(aCamera._isMasked)  {
			p.x -= aCamera._maskOffset.x;
			p.y -= aCamera._maskOffset.y;
		}
		_flashPoint.x = p.x + origin.x;
		_flashPoint.y = p.y + origin.y;
		_flashRect.width = _pixels.width;
		_flashRect.height = _pixels.height;
		var targetB : BitmapData = ((_buffer != null)) ? _buffer : _pixels;
		// Если не применено никаких трансформаций то выполняем простой рендер через copyPixels().
		if(globalAngle == 0 && scaleX == 1 && scaleY == 1 && blend == null)  {
			aCamera.buffer.copyPixels(targetB, _flashRect, _flashPoint, null, null, true);
		}

		else // Если объект имеет какие-либо трансформации, используем более сложный рендер через draw().
		 {
			_matrix.identity();
			_matrix.translate(origin.x, origin.y);
			_matrix.scale(scaleX, scaleY);
			if(globalAngle != 0)  {
				_matrix.rotate(Math.PI * 2 * (globalAngle / 360));
			}
			_matrix.translate(_flashPoint.x - origin.x, _flashPoint.y - origin.y);
			aCamera.buffer.draw(targetB, _matrix, null, cast blend, null, smoothing);
		}

	}

	/**

	 * Сброс внутренних помошников.

	 */
	function resetHelpers() : Void {
		_flashRect.x = _flashRect.y = 0;
		if(_colorTransform != null)  {
			if(_buffer == null || _buffer.width != _curAnim.width || _buffer.height != _curAnim.height)  {
				if(_buffer != null)  {
					_buffer.dispose();
				}
				_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
			}
		}
		calcFrame();
		updateBounds();
	}

	/**

	 * Перерасчет текущего кадра.

	 */
	function calcFrame(aFrame : Int = 0) : Void {
		origin.set(_curAnim.offsetX[aFrame], _curAnim.offsetY[aFrame]);
		if(_buffer != null)  {
			_flashRect.width = _buffer.width;
			_flashRect.height = _buffer.height;
			_buffer.fillRect(_flashRect, 0x00FFFFFF);
		}
		_pixels = _curAnim.frames[aFrame];
		width = _flashRect.width = _pixels.width;
		height = _flashRect.height = _pixels.height;
		// Если имеются какие-либо цветовые трансформации, то используем внутренний буффер для применения эффектов.
		if(_colorTransform != null)  {
			_buffer.copyPixels(_pixels, _flashRect, _flashPointZero, null, null, false);
			_buffer.colorTransform(_flashRect, _colorTransform);
		}
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
			calcFrame(Std.int(i));
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

	/**

	 * Определяет прозрачность.

	 */
	function get_alpha() : Float {
		return _alpha;
	}

	function set_alpha(value : Float) : Float {
		value = ((value > 1)) ? 1 : ((value < 0)) ? 0 : value;
		if(_alpha != value)  {
			_alpha = value;
			if(_alpha != 1 || _color != 0x00FFFFFF)  {
				_colorTransform = new ColorTransform((_color >> 16) * 0.00392, (_color >> 8 & 0xFF) * 0.00392, (_color & 0xFF) * 0.00392, _alpha);
				if(_buffer == null && _curAnim != null)  {
					_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
				}
			}

			else  {
				_colorTransform = null;
				if(_buffer != null)  {
					_buffer.dispose();
					_buffer = null;
				}
			}

			calcFrame(Std.int(currentFrame - 1));
		}
		return value;
	}

	/**

	 * Определяет цвет.

	 */
	function get_color() : UInt {
		return _color;
	}

	function set_color(value : UInt) : UInt {
		value &= 0x00FFFFFF;
		if(_color != value)  {
			_color = value;
			if(_alpha != 1 || _color != 0x00FFFFFF)  {
				_colorTransform = new ColorTransform((_color >> 16) * 0.00392, (_color >> 8 & 0xFF) * 0.00392, (_color & 0xFF) * 0.00392, _alpha);
				if(_buffer == null && _curAnim != null)  {
					_buffer = new BitmapData(_curAnim.width, _curAnim.height, true, 0x00FFFFFF);
				}
			}

			else  {
				_colorTransform = null;
				if(_buffer != null)  {
					_buffer.dispose();
					_buffer = null;
				}
			}

			calcFrame(Std.int(currentFrame - 1));
		}
		return value;
	}

}

