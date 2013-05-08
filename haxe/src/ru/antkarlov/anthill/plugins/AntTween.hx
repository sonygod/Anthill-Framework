/**
 * Класс реализации плавных трансформации каких-либо значений объектов. Класс использует различные
 * методы для реализации разнообразных анимационных стилей.
 * 
 * <p>В первую очередь этот класс реализует стандартные анимации такие как движение, затухание,
 * поврот и т.п. Но нет никаких ограничений на то, что вы хотите трансформировать. Вы можете трансформировать
 * любое цифровое свойство объекта (<code>int, uint, Number</code>). Чтобы посмотреть список 
 * возможных типов анимаций для трансформаций, посмотрите класс <code>AntTransition</code>.</p>
 * 
 * <p>Пример использования использующий движение объекта, вращение и затухание:</p>
 * 
 * <listing>
 * var tween:AntTween = new AntTween(object, 2.0, AntTransition.EASE_IN_OUT);
 * tween.animate("x", object.x + 50);
 * tween.animate("angle", 45);
 * tween.fadeTo(0); // Тоже самое что и animate("alpha", 0);
 * tween.start();
 * </listing>
 * 
 * <p>Идея и реализация подсмотрена у <a href="http://gamua.com/starling/">Starling Framework</a>.</p>
 * 
 * @see	AntTransition
 * 
 * @author Антон Карлов
 * @since  26.01.2013
 */
package ru.antkarlov.anthill.plugins;

import msignal.Signal;
import ru.antkarlov.anthill.*;
using Lambda;

class AntTween implements IPlugin {
	@:isVar public var isComplete(get, never) : Bool;
	@:isVar public var target(get, never) : Dynamic;
	@:isVar public var transition(get, set) : String;
	@:isVar public var transitionFunc(get, set) : Dynamic;
	@:isVar public var totalTime(get, never) : Float;
	@:isVar public var currentTime(get, never) : Float;
	@:isVar public var delay(get, set) : Float;

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**
	 * Определяет следует ли округлять трансформируемое значение.
	 * @default	false
	 */
	public var roundToInt : Bool;
	/**
	 * Указатель на следующий твин.
	 * Не используется твинером.
	 * @default	null
	 */
	public var nextTween : AntTween;
	/**
	 * Определяет автоматический переход к следующему твину, если он указан.
	 * @default	true
	 */
	public var autoStartOfNextTween : Bool;
	/**
	 * Определяет количество циклов выполнения.
	 * @default	1
	 */
	public var repeatCount : Int;
	/**
	 * Определяет задержку перед тем как будет выполнен переход к следующему циклу.
	 * @default	0
	 */
	public var repeatDelay : Float;
	/**
	 * Определяет необходимо ли выполнить реверс трансформации. Если <code>true</code>
	 * то при каждом повторе трансформация будет реверсирована (выполнятся в обратную сторону).
	 * @default	false
	 */
	public var reverse : Bool;
	/**
	 * Событие срабатывающее при запуске твина.
	 */
	public var eventStart : Signal1<Dynamic>;
	/**
	 * Событие срабатывающее каждый тик твина.
	 */
	public var eventUpdate : Signal1<Dynamic>;
	/**
	 * Событие срабатывающее каждый повтор твина.
	 */
	public var eventRepeat : Signal1<Dynamic>;
	/**
	 * Событие срабатывающее при завершении выполнения твина.
	 */
	public var eventComplete : Signal1<Dynamic>;
	/**
	 * Пользовательские аргументы которые могут быть переданы в событие при запуске твина.
	 * @default	null
	 */
	public var startArgs : Array<Dynamic>;
	/**
	 * Пользовательские аргументы которые могут быть переданы в событие при каждом тике твина.
	 * @default	null
	 */
	public var updateArgs : Array<Dynamic>;
	/**
	 * Пользовательские аргументы которые могут быть переданы в событие при каждом повторе твина.
	 * @default	null
	 */
	public var repeatArgs : Array<Dynamic>;
	/**
	 * Пользовательские аргументы которые могут быть переданы в событие при завершении твина.
	 * @default	null
	 */
	public var completeArgs : Array<Dynamic>;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**
	 * Объект к которому применяются трансформации.
	 * @default	null
	 */
	var _target : Dynamic;
	/**
	 * Указатель на метод который используется для рассчетов.
	 * @default	null
	 */
	var _transitionFunc : Dynamic;
	/**
	 * Имя метода который используется для рассчетов.
	 * @default	"linear"
	 */
	var _transitionName : String;
	/**
	 * Список свойств объекта которые трансформируются.
	 */
	var _properties : Vector<String>;
	/**
	 * Начальные значения свойств объекта которые трансформируются.
	 */
	var _startValues : Vector<Float>;
	/**
	 * Конечные значения свойств объекта которые трансформируются.
	 */
	var _endValues : Vector<Float>;
	/**
	 * Общее время отведенное на трансформации.
	 */
	var _totalTime : Float;
	/**
	 * Текущее время.
	 */
	var _currentTime : Float;
	/**
	 * Задержка.
	 */
	var _delay : Float;
	/**
	 * Текущий цикл выполнения.
	 */
	var _currentCycle : Int;
	/**
	 * Определяет запущена работа твина или нет.
	 */
	var _isStarted : Bool;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new(aTarget : Dynamic, aTime : Float, aTransition : Dynamic = "linear") {
		//super()
		_isStarted = false;
		autoStartOfNextTween = true;
		reset(aTarget, aTime, aTransition);
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**
	 * Сбрасывает параметры твина на значения по умолчанию.
	 * 
	 * @param	aTarget	 Указатель на объект к которому применяется твинер.
	 * @param	aTime	 Продолжительность работы твинера.
	 * @param	aTransition	 Тип анимации твина.
	 * @return		Возвращает указатель на себя.
	 */
	public function reset(aTarget : Dynamic, aTime : Float, aTransition : Dynamic = "linear") : AntTween {
		stop();
		_target = aTarget;
		_totalTime = aTime;
		_currentTime = 0;
		_totalTime = Math.max(0.0001, aTime);
		_delay = repeatDelay = 0.0;
		startArgs = updateArgs = repeatArgs = completeArgs = null;
		roundToInt = reverse = false;
		repeatCount = 1;
		_currentCycle = -1;
		if(Std.is(aTransition, String))  {
			transition = try cast(aTransition, String) catch(e:Dynamic) null;
		}

		else (if(Std.is(aTransition, Function))  {
			transitionFunc = try cast(aTransition, Function) catch(e:Dynamic) null;
		}

		else  {
			throw new ArgumentError("Transition must be either a string or a function");
		}
(eventStart == null)) ? eventStart = new Signal1() : eventStart.clear();
		((eventUpdate == null)) ? eventUpdate = new Signal1() : eventUpdate.clear();
		((eventRepeat == null)) ? eventRepeat = new Signal1() : eventRepeat.clear();
		((eventComplete == null)) ? eventComplete = new Signal1() : eventComplete.clear();
		// Отключение типизации для сигналов
		/*eventStart.strict = false;
		eventUpdate.strict = false;
		eventRepeat.strict = false;
		eventComplete.strict = false;*/
		((_properties == null)) ? _properties = new Vector<String>() : _properties.length = 0;
		((_startValues == null)) ? _startValues = new Vector<Float>() : _startValues.length = 0;
		((_endValues == null)) ? _endValues = new Vector<Float>() : _endValues.length = 0;
		return this;
	}

	/**
	 * Задает атрибут объекта к которому будут применятся действия твинера.
	 * Количество одновременно изменяемых атрибутов не ограничено. Данный
	 * метод может быть вызван для одного твина много раз.
	 * 
	 * @param	aProperty	 Имя атрибута на которое будет воздействовать твинер.
	 * @param	aEndValue	 Конечное значение которого необходимо достигнуть.
	 */
	public function animate(aProperty : String, aEndValue : Float) : Void {
		if(_target != null)  {
			var i : Int = _properties.indexOf(aProperty);
			if(i == -1)  {
				_properties.push(aProperty);
				_startValues.push(Number.NaN);
				_endValues.push(aEndValue);
			}

			else  {
				_startValues[i] = Number.NaN;
				_endValues[i] = aEndValue;
			}

		}
	}

	/**
	 * Трансформирует свойства объекта <code>scaleX</code> и <code>scaleY</code>.
	 * 
	 * @param	aValue	 Значение свойства <code>scaleX</code> и <code>scaleY</code> которого необходимо достигнуть.
	 */
	public function scaleTo(aValue : Float) : Void {
		animate("scaleX", aValue);
		animate("scaleY", aValue);
	}

	/**
	 * Трансформирует свойства объекта <code>x</code> и <code>y</code>.
	 * 
	 * @param	aX	 Значение свойства <code>x</code> которого необходимо достигнуть.
	 * @param	aY	 Значение свойства <code>y</code> которого необходимо достигнуть.
	 */
	public function moveTo(aX : Float, aY : Float) : Void {
		animate("x", aX);
		animate("y", aY);
	}

	/**
	 * Трансформирует свойства объекта <code>alpha</code>.
	 * 
	 * @param	aAlpha	 Значения свойства <code>alpha</code>.
	 */
	public function fadeTo(aAlpha : Float) : Void {
		animate("alpha", aAlpha);
	}

	/**
	 * Запускает работу твина.
	 */
	public function start() : Void {
		if(!_isStarted)  {
			AntG.addPlugin(this);
			_isStarted = true;
		}
	}

	/**
	 * Останавливает работу твина.
	 */
	public function stop() : Void {
		if(_isStarted)  {
			AntG.removePlugin(this);
			_isStarted = false;
		}
	}

	/**
	 * Извлекает финальное значение для указанного свойства.
	 * 
	 * @param	aProperty	 Имя свойства для которого необходимо получить финальное значение.
	 * @return		Возвращает значение для указанного свойства.
	 */
	public function getEndValue(aProperty : String) : Float {
		var i : Int = _properties.indexOf(aProperty);
		if(i == -1)  {
			throw new ArgumentError("The property '" + aProperty + "' is not animated.");
		}
		return try cast(_properties[i], Number) catch(e:Dynamic) null;
	}

	//---------------------------------------
	// IPlugin Implementation
	//---------------------------------------
	//import ru.antkarlov.anthill.plugins.IPlugin;
	/**
	 * @inheritDoc
	 */
	public function update() : Void {
		updateTween(AntG.elapsed);
	}

	/**
	 * @inheritDoc
	 */
	public function draw(aCamera : AntCamera) : Void {
		//
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**
	 * Процессинг твина.
	 */
	function updateTween(aTime : Float) : Void {
		if(aTime == 0 || (repeatCount == 1 && _currentTime == _totalTime))  {
			return;
		}
		var i : Int = 0;
		var previousTime : Float = _currentTime;
		var restTime : Float = _totalTime - _currentTime;
		var carryOverTime : Float = aTime > (restTime) ? aTime - restTime : 0.0;
		_currentTime = Math.min(_totalTime, _currentTime + aTime);
		if(_currentTime <= 0)  {
			// Задержка еще не закончилась.
			return;
		}
		if(_currentCycle < 0 && previousTime <= 0 && _currentTime > 0)  {
			_currentCycle++;
			try {
				eventStart.dispatch.apply(null, startArgs);
			}
			catch(e : Dynamic){ };
		}
		var ratio : Float = _currentTime / _totalTime;
		var reversed : Bool = reverse && (_currentCycle % 2 == 1);
		var numProperties : Int = _startValues.length;
		i = 0;
		while(i < numProperties) {
			if(Math.isNaN(_startValues[i]))  {
				_startValues[i] = try cast(_target[_properties[i]], Number) catch(e:Dynamic) null;
			}
			var startValue : Float = _startValues[i];
			var endValue : Float = _endValues[i];
			var delta : Float = endValue - startValue;
			var transitionValue : Float = (reversed) ? _transitionFunc(1.0 - ratio) : _transitionFunc(ratio);
			var currentValue : Float = startValue + transitionValue * delta;
			if(roundToInt)  {
				currentValue = Math.round(currentValue);
			}
			_target[_properties[i]] = currentValue;
			++i;
		}
		try {
			eventUpdate.dispatch.apply(this, updateArgs);
		}
		catch(e : Dynamic){ };
		if(previousTime < _totalTime && _currentTime >= _totalTime)  {
			if(repeatCount == 0 || repeatCount > 1)  {
				_currentTime = -repeatDelay;
				_currentCycle++;
				if(repeatCount > 1)  {
					repeatCount--;
				}
				try {
					eventRepeat.dispatch.apply(this, repeatArgs);
				}
				catch(e : Dynamic){ };
			}

			else  {
				stop();
				try {
					eventComplete.dispatch.apply(this, completeArgs);
				}
				catch(e : Dynamic){ };
				if(autoStartOfNextTween && nextTween != null)  {
					nextTween.start();
				}
			}

		}
		if(carryOverTime)  {
			updateTween(carryOverTime);
		}
	}

	//---------------------------------------
	// GETTER / SETTERS
	//---------------------------------------
	/**
	 * Определяет завершено выполнения твина или нет.
	 */
	function get_isComplete() : Bool {
		return _currentTime >= _totalTime && repeatCount == 1;
	}

	/**
	 * Возвращает указатель на объект для которого выполняются трансформации.
	 */
	function get_target() : Dynamic {
		return _target;
	}

	/**
	 * Определяет стиль перехода.
	 */
	function get_transition() : String {
		return _transitionName;
	}

	function set_transition(value : String) : String {
		_transitionName = value;
		_transitionFunc = AntTransition.getTransition(value);
		if(_transitionFunc == null)  {
			throw new ArgumentError("Invalid transition: " + value);
		}
		return value;
	}

	/**
	 * Определяет метод использующийся для рассчетов перехода.
	 */
	function get_transitionFunc() : Dynamic {
		return _transitionFunc;
	}

	function set_transitionFunc(value : Dynamic) : Dynamic {
		_transitionName = "custom";
		_transitionFunc = value;
		return value;
	}

	/**
	 * Возвращает общее время необходимое для выполнения твина.
	 */
	function get_totalTime() : Float {
		return _totalTime;
	}

	/**
	 * Возвращает текущее время выполнения твина.
	 */
	function get_currentTime() : Float {
		return _currentTime;
	}

	/**
	 * Определяет задержку перед стартом твина.
	 */
	function get_delay() : Float {
		return _delay;
	}

	function set_delay(value : Float) : Float {
		_currentTime = _currentTime + _delay - value;
		_delay = value;
		return value;
	}

}

