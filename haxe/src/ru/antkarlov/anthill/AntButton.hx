/**

 * Кнопка обыкновенная.

 * 

 * <p>Для визуального представления кнопки используются заранее растеризированные анимации 

 * как и для AntActor, но с определенными условиями. Анимация кнопки должна состоять 

 * как минимум из двух кадров, каждый из которых должен представлять определенное состояние 

 * кнопки: первый кадр - нормальное состояние, второй кадр - подсвеченное состояние при наведении мыши,

 * третий кадр - нажатое состояние. Если нет необходимости подсвечивать кнопку при наведении мыши,

 * то нажатое состояние должно быть вторым кадром.</p>

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  24.08.2012

 */
package ru.antkarlov.anthill;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import msignal.Signal;

class AntButton extends AntEntity {
	@:isVar public var text(get, set) : String;
	@:isVar public var selected(get, set) : Bool;
	@:isVar public var toggle(get, set) : Bool;
	@:isVar public var currentAnimation(get, never) : String;
	@:isVar public var alpha(get, set) : Float;
	@:isVar public var color(get, set) : UInt;

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	static public var NORMAL : UInt = 1;
	static public var OVER : UInt = 2;
	static public var DOWN : UInt = 3;
	/**

	 * Определяет имя анимации пользовательского курсора при наведении на кнопку по умолчанию.

	 * @default	null

	 */
	static public var defOverCursorAnim : String;
	/**

	 * Определяет имя анимации пользовательского курсора при нажатии на кнопку по умолчанию.

	 * @default	null

	 */
	static public var defDownCursorAnim : String;
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

	 * Текущее состояние кнопки.

	 * @default	NORMAL

	 */
	public var status : UInt;
	/**

	 * Событие выполняющееся когда кнопка нажата. 

	 * В качестве атрибута в метод подписчика передается указатель на кнопку.

	 */
	public var eventDown : Signal1<Dynamic>;
	/**

	 * Событие выполняющееся когда на кнопку наведен курсор мыши. 

	 * В качестве атрибута в метод подписчика передается указатель на кнопку.

	 */
	public var eventOver : Signal1<Dynamic>;
	/**

	 * Событие выполняющееся когда курсор мыши вышел за пределы кнопки. 

	 * В качестве атрибута в метод подписчика передается указатель на кнопку.

	 */
	public var eventOut : Signal1<Dynamic>;
	/**

	 * Событие выполняющееся когда кнопка отпущена. 

	 * В качестве атрибута в метод подписчика передается указатель на кнопку.

	 */
	public var eventUp : Signal1<Dynamic>;
	/**

	 * Событие выполняющееся когда был произведен клик по кнопке (нажатие и отпускание мыши в пределах кнопки). 

	 * В качестве атрибута в метод подписчика передается указатель на кнопку.

	 */
	public var eventClick : Signal1<Dynamic>;
	/**

	 * Указатель на текстовую метку кнопки.

	 * @default	null

	 */
	public var label : AntLabel;
	/**

	 * Смещение текстовой метки при нажатии.

	 * @default	(0,1)

	 */
	public var labelOffset : AntPoint;
	/**

	 * Определяет имя анимации пользовательского курсора при наведении на кнопку.

	 * @default	null

	 */
	public var overCursorAnim : String;
	/**

	 * Определяет имя анимации пользовательского курсора при нажатии на кнопку.

	 * @default	null

	 */
	public var downCursorAnim : String;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * Определяет наведен ли курсор мышки на кнопку.

	 * @default	false

	 */
	var _over : Bool;
	/**

	 * Определяет нажата ли кнопка.

	 * @default	false

	 */
	var _down : Bool;
	/**

	 * Определяет является ли кнопка в данный момент выбранной (зажатой). 

	 * @default	false

	 */
	var _selected : Bool;
	/**

	 * Определяет может ли быть кнопка выбрана (зажата).

	 * @default	false

	 */
	var _toggle : Bool;
	/**

	 * Текущая прозрачность кнопки.

	 * @default	1

	 */
	var _alpha : Float;
	/**

	 * Текущий цвет кнопки.

	 * @default	0x00FFFFFF

	 */
	var _color : UInt;
	/**

	 * Цветовая трансформация кнопки. Инициализируется автоматически если кнопке задан цвет отличный от 0x00FFFFFF.

	 * @default	null

	 */
	var _colorTransform : ColorTransform;
	/**

	 * Хранилище указателей на все добавленные анимации.

	 * @default	AntStorage

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

	 * Инициализируется автоматически при перекрашивании или прозрачности.

	 * @default	null

	 */
	var _buffer : BitmapData;
	/**

	 * Помошник для определения пересечения курсора мышки с кнопкой.

	 */
	var _point : AntPoint;
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
		status = NORMAL;
		_over = false;
		_down = false;
		_selected = false;
		_toggle = false;
		_alpha = 1;
		_color = 0x00FFFFFF;
		_colorTransform = null;
		_animations = new AntStorage();
		_curAnim = null;
		_curAnimName = null;
		_prevFrame = -1;
		_pixels = null;
		_buffer = null;
		_point = new AntPoint();
		_flashRect = new Rectangle();
		_flashPoint = new Point();
		_flashPointZero = new Point();
		_matrix = new Matrix();
		super();
		eventDown = new Signal1(AntButton);
		eventOver = new Signal1(AntButton);
		eventOut = new Signal1(AntButton);
		eventUp = new Signal1(AntButton);
		eventClick = new Signal1(AntButton);
		label = null;
		labelOffset = new AntPoint(0, 1);
		overCursorAnim = defOverCursorAnim;
		downCursorAnim = defDownCursorAnim;
	}

	/**

	 * Альтернативный конструктор кнопки для быстрого создания кнопки с текстом и без.

	 * 

	 * @param	aAnimName	 Имя анимации для кнопки в хранилище анимаций.

	 * @param	aText	 Текст на кнопке.

	 * @param	aLabel	 Текстовая метка для кнопки.

	 * @param	aIsScrolled	 Определяет привязана кнопка в игровому миру или к камере.

	 * @return		Возвращает указатель на новую кнопку.

	 */
	static public function makeButton(aAnimName : String, aText : String = null, aLabel : AntLabel = null, aIsScrolled : Bool = false) : AntButton {
		if(aLabel != null && aText != null)  {
			aLabel.text = aText;
		}
		var btn : AntButton = new AntButton();
		btn.addAnimationFromCache(aAnimName);
		if(aLabel != null)  {
			btn.label = aLabel;
			btn.add(aLabel);
			aLabel.x = btn.width * 0.5 - aLabel.width * 0.5 + btn.origin.x;
			aLabel.y = btn.height * 0.5 - aLabel.height * 0.5 + btn.origin.y;
		}
		if(!aIsScrolled)  {
			btn.isScrolled = false;
			aLabel.isScrolled = false;
		}
		return btn;
	}

	/**

	 * @inheritDoc

	 */
	override public function destroy() : Void {
		eventDown.destroy();
		eventOver.destroy();
		eventOut.destroy();
		eventUp.destroy();
		eventClick.destroy();
		eventDown = null;
		eventOver = null;
		eventOut = null;
		eventUp = null;
		eventClick = null;
		_animations.clear();
		_animations = null;
		_curAnim = null;
		_curAnimName = null;
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
		updateButton();
		super.update();
	}

	/**

	 * @inheritDoc

	 */
	override public function draw(aCamera : AntCamera) : Void {
		updateBounds();
		drawButton(aCamera);
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
			_curAnim = cast _animations.get(aName);//try cast(_animations.get(aName), AntAnimation) catch(e:Dynamic) null;
			_curAnimName = aName;
			_prevFrame = -1;
			resetHelpers();
			updateVisualStatus();
		}

		else  {
			throw new flash.errors.Error("Missing button animation \"" + aName + "\".");
		}

	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * Обновляет положение текстовой метки.

	 */
	function updateLabel() : Void {
		if(label != null)  {
			label.x = width * 0.5 - label.width * 0.5 + origin.x;
			label.y = height * 0.5 - label.height * 0.5 + origin.y;
			if(_down)  {
				label.x += labelOffset.x;
				label.y += labelOffset.y;
			}
		}
	}

	/**

	 * Обработка логики кнопки.

	 */
	function updateButton() : Void {
		if(cameras == null)  {
			cameras = AntG.cameras;
		}
		var i : Int = 0;
		var n : Int = cameras.length;
		var cam : AntCamera;
		while(i < n) {
			cam = try cast(cameras[i], AntCamera) catch(e:Dynamic) null;
			if(cam != null)  {
				((isScrolled)) ? AntG.mouse.getWorldPosition(cam, _point) : AntG.mouse.getScreenPosition(cam, _point);
				if (hitTestPoint(_point)){
					onMouseOver();
					if(AntG.mouse.isPressed())  {
						onMouseDown();
					}

					else if(AntG.mouse.isReleased())  {
						onMouseUp();
					}
				}

				else  {
					if(_over)  {
						onMouseOut();
					}
					if(_down && AntG.mouse.isReleased())  {
						onMouseUp();
					}
				}

			}
			i++;
		}

		updateVisualStatus();
	}

	/**

	 * Обработчик наведения мышки на кнопку.

	 */
	function onMouseOver() : Void {
		var o : Bool = _over;
		_over = true;
		if(o != _over)  {
			eventOver.dispatch(this);
		}
		if(!_down && overCursorAnim != null)  {
			AntG.mouse.changeCursor(overCursorAnim);
		}
	}

	/**

	 * Обработчик выхода мышки за пределы кнопки.

	 */
	function onMouseOut() : Void {
		var o : Bool = _over;
		_over = false;
		if(o != _over)  {
			eventOut.dispatch(this);
			if(!_down)  {
				AntG.mouse.changeCursor();
			}
		}
	}

	/**

	 * Обработчик нажатия кнопки мыши.

	 */
	function onMouseDown() : Void {
		var o : Bool = _down;
		_down = true;
		if(o != _down)  {
			eventDown.dispatch(this);
			AntG.mouse.changeCursor(downCursorAnim);
		}
	}

	/**

	 * Обработчик отпускания кнопки мыши.

	 */
	function onMouseUp() : Void {
		eventUp.dispatch(this);
		if(_toggle && _over)  {
			_selected = !_selected;
		}
		var o : Bool = _down;
		_down = false;
		if(_over && o)  {
			AntG.mouse.changeCursor(overCursorAnim);
			eventClick.dispatch(this);
		}

		else  {
			AntG.mouse.changeCursor();
		}

	}

	/**

	 * Обновляет визуальное представление кнопки в зависимости от текущего состояния.

	 */
	function updateVisualStatus() : Void {
		if((_over && _down) || (!_over && _down) || _selected)  {
			status = DOWN;
		}

		else if(_over && !_down)  {
			status = OVER;
		}

		else  {
			status = NORMAL;
		}

		goto(status);
		updateLabel();
	}

	/**

	 * Отрисовка кнопки в буффер указанной камеры.

	 * 

	 * @param	aCamera	 Камера в буффер которой необходимо отрисовать актера.

	 */
	function drawButton(aCamera : AntCamera) : Void {
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
		// Если не применено никаких трансформаций то выполняем простой рендер через copyPixels().
		if(globalAngle == 0 && scaleX == 1 && scaleY == 1 && blend == null)  {
			aCamera.buffer.copyPixels(((_buffer != null)) ? _buffer : _pixels, _flashRect, _flashPoint, null, null, true);
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
			aCamera.buffer.draw(((_buffer != null)) ? _buffer : _pixels, _matrix, null, cast blend, null, smoothing);
		}

	}

	/**

	 * Сброс локальных помошников.

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

	 * Переводит состояние кнопки на указанный кадр.

	 * 

	 * @param	aFrame	 Кадр на который необходимо перевести состояние кнопки.

	 */
	function goto(aFrame : Int) : Void {
		if(_curAnim == null)  {
			return;
		}
		if(_curAnim.totalFrames == 2 && aFrame == 2)  {
			aFrame = 1;
		}
		aFrame = ((aFrame <= 1)) ? 1 : ((aFrame >= _curAnim.totalFrames)) ? _curAnim.totalFrames : aFrame;
		if(_prevFrame != aFrame)  {
			calcFrame(aFrame - 1);
			_prevFrame = aFrame;
		}
	}

	//---------------------------------------
	// GETTER / SETTERS
	//---------------------------------------
	/**

	 * Определяет текст для текстовой метки у кнопки.

	 */
	function get_text() : String {
		return ((label != null)) ? label.text : "";
	}

	function set_text(value : String) : String {
		if(label != null)  {
			label.text = value;
			updateLabel();
		}
		return value;
	}

	/**

	 * Определяет состояние выбранности кнопки. Работает только если для кнопки установлен режим чекбокса <code>toggle = true;</code>

	 */
	function get_selected() : Bool {
		return _selected;
	}

	function set_selected(value : Bool) : Bool {
		if(!_toggle)  {
			value = false;
		}
		_selected = value;
		updateVisualStatus();
		return value;
	}

	/**

	 * Определяет режим чекбокса для кнопки.

	 */
	function get_toggle() : Bool {
		return _toggle;
	}

	function set_toggle(value : Bool) : Bool {
		_toggle = value;
		return value;
	}

	/**

	 * Возвращает имя текущей анимации кнопки.

	 */
	function get_currentAnimation() : String {
		return _curAnimName;
	}

	/**

	 * Определяет текущую прозрачность.

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

			calcFrame(status - 1);
		}
		return value;
	}

	/**

	 * Определяет текущий цвет.

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

			calcFrame(status - 1);
		}
		return value;
	}

}

