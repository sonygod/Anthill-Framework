/**
 * Сущность звука.
 * 
 * <p>Примечание: Напрямую работать со звуками не рекомендуется. 
 * Работайте со звуками используя менеджер звуков <code>AntSoundManager</code>. 
 * Стандартный менеджер звуков инициализируется автоматически и доступен через <code>AntG.sounds</code>.</p>
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  04.09.2012
 */
package ru.antkarlov.anthill;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import msignal.Signal;
import ru.antkarlov.anthill.utils.AntRating;

class AntSound extends AntBasic {
	@:isVar public var source(get, never) : AntEntity;
	@:isVar public var volume(get, set) : Float;

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**
	 * Имя звука.
	 */
	public var name : String;
	/**
	 * Указатель на менеджер звуков который управляет данным звуком.
	 */
	public var parent : AntSoundManager;
	/**
	 * Указатель на массив слушателей в менеджере звуков.
	 */
	public var listeners : Array<Dynamic>;
	/**
	 * @private
	 */
	public var eventComplete : Signal1<Dynamic>;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**
	 * Звук.
	 */
	var _sound : Sound;
	/**
	 * Звуковая трансформация.
	 */
	var _soundTransform : SoundTransform;
	/**
	 * Звуковой канал.
	 */
	var _soundChannel : SoundChannel;
	/**
	 * Указатель на источник звука для рассчета стерео эффекта. Если источник 
	 * не указан, то стерео эффект не рассчитывается.
	 * @default	null
	 */
	var _source : AntEntity;
	/**
	 * Количество повторов воспроизведения звука.
	 */
	var _repeats : Int;
	/**
	 * Флаг определяющий установлено ли воспроизведение звука на паузу.
	 */
	var _paused : Bool;
	/**
	 * Позиция на которой звук был поставлен на паузу, используется для возобновления проигрывания 
	 * с места где воспроизведение было остановлено.
	 */
	var _pausePosition : Float;
	/**
	 * Текущая громкость звука исходя из положения источника звука.
	 */
	var _volumeAdjust : Float;
	/**
	 * Текущее параномирование звука исходя из положения источника звука.
	 */
	var _panAdjust : Float;
	/**
	 * Помошник для определения среднего уровня громкости при нескольких слушателях или камер.
	 */
	var _ratingVolume : AntRating;
	/**
	 * Помошник для определения среднего параномирования при нескольких слушателях или камер.
	 */
	var _ratingPan : AntRating;
	/**
	 * Флаг определяющий следует ли поставить воспроизведение звука на паузу после того
	 * как будет завершено уменьшение громкости.
	 */
	var _pauseOnFadeOut : Bool;
	/**
	 * Помошник для реализации плавного уменьшения громкости звука звука.
	 */
	var _fadeOutTimer : Float;
	/**
	 * Помошник для реализации плавного уменьшения громкости звука звука.
	 */
	var _fadeOutTotal : Float;
	/**
	 * Помошник для реализации плавного увеличения громкости звука звука.
	 */
	var _fadeInTimer : Float;
	/**
	 * Помошник для реализации плавного увеличения громкости звука звука.
	 */
	var _fadeInTotal : Float;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new(aName : String, aSound : Sound) {
		super();
		name = aName;
		parent = null;
		listeners = null;
		eventComplete = new Signal1(AntSound);
		_sound = aSound;
		_paused = false;
		_soundTransform = new SoundTransform();
		_source = null;
		_repeats = 1;
		_paused = false;
		_pausePosition = 0;
		_volumeAdjust = 1;
		_panAdjust = 0;
		_ratingVolume = new AntRating(1);
		_ratingPan = new AntRating(1);
		_pauseOnFadeOut = false;
		_fadeOutTimer = 0;
		_fadeOutTotal = 0;
		_fadeInTimer = 0;
		_fadeInTotal = 0;
	}

	/**
	 * @inheritDoc
	 */
	override public function destroy() : Void {
		kill();
		eventComplete.destroy();
		eventComplete = null;
		if(parent != null)  {
			parent.remove(this);
		}
		_sound = null;
		_soundTransform = null;
		super.destroy();
	}

	/**
	 * @inheritDoc
	 */
	override public function kill() : Void {
		if(_soundChannel != null)  {
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			_soundChannel.stop();
			_soundChannel = null;
		}
		_source = null;
		listeners = null;
		super.kill();
	}

	/**
	 * @inheritDoc
	 */
	override public function update() : Void {
		updateSound();
	}

	/**
	 * Запускает проигрывание звука.
	 * 
	 * @param	aSource	 Источник звука, необходимо указывать для рассчета стерео эффекта.
	 * @param	aPosition	 Позиция с какого места начинать проигрывание звука.
	 * @param	aRepeats	 Количество повторов проигрывания.
	 */
	public function play(aSource : AntEntity = null, aPosition : Float = 0, aRepeats : Int = 1) : Void {
		if(parent == null)  {
			return;
		}
		_repeats = aRepeats;
		_source = aSource;
		if(_source == null)  {
			_soundTransform.volume = parent.volume;
			if(_sound != null)  {
				_soundChannel = _sound.play(0, _repeats, _soundTransform);
				if(_soundChannel != null)  {
					_soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				}
			}
		}

		else  {
			updateSound();
			if(_sound != null)  {
				_soundChannel = _sound.play(0, _repeats, _soundTransform);
				if(_soundChannel != null)  {
					_soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				}
			}
		}

	}

	/**
	 * Останавливает проигрывание звука.
	 */
	public function stop() : Void {
		if(_soundChannel != null)  {
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			_soundChannel.stop();
			_soundChannel = null;
		}
	}

	/**
	 * Ставит проигрывание звука на паузу.
	 */
	public function pause() : Void {
		if(!_paused && _soundChannel != null)  {
			_paused = true;
			_pausePosition = _soundChannel.position;
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			_soundChannel.stop();
			_soundChannel = null;
		}
	}

	/**
	 * Продолжает проигрывание звука если он на паузе.
	 */
	public function resume() : Void {
		if(_paused)  {
			_paused = false;
			play(_source, _pausePosition, _repeats);
		}
	}

	/**
	 * Запускает плавное уменьшение громкости звука.
	 * 
	 * @param	aSeconds	 Время в секундах в течении которого будет выполнятся уменьшение громкости.
	 * @param	aOnPause	 Флаг определяющий необходимо ли поставить воспроизводимый звук на паузу после завершения процесса затухания.
	 */
	public function fadeOut(aSeconds : Float, aOnPause : Bool = false) : Void {
		_pauseOnFadeOut = aOnPause;
		_fadeInTimer = 0;
		_fadeOutTimer = _fadeOutTotal = aSeconds;
	}

	/**
	 * Запускает плавное увеличение громкости звука.
	 * 
	 * @param	aSeconds	 Время в секундах в течении которого будет выполнятся увеличение громкости.
	 */
	public function fadeIn(aSeconds : Float) : Void {
		_fadeOutTimer = 0;
		_fadeInTimer = _fadeInTotal = aSeconds;
		play(_source, _pausePosition, _repeats);
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**
	 * Обработка стерео эффекта для звука.
	 */
	public function updateSound() : Void {
		if(_source == null)  {
			return;
		}
		if(listeners == null)  {
			listeners = parent.listeners;
		}
		listeners.length > (0) ? soundForListeners() : soundForCenter();
	}

	/**
	 * Рассчет стерео эффекта для звука со слушателями.
	 */
	function soundForListeners() : Void {
		var radial : Float;
		var pan : Float;
		var n : Int = listeners.length;
		var listener : AntEntity;
		if(_ratingVolume.length() != n)  {
			_ratingVolume = new AntRating(n);
			_ratingPan = new AntRating(n);
		}
		var i : Int = 0;
		while(i < n) {
			listener = try cast(listeners[i], AntEntity) catch(e:Dynamic) null;
			if(listener != null && listener.exists)  {
				radial = AntMath.distance(_source.globalX, _source.globalY, listener.globalX, listener.globalY) / parent.radius;
				radial = AntMath.trimToRange(radial, 0, 1);
				_ratingVolume.add(1 - radial);
				pan = (_source.globalX - listener.globalX) / parent.radius;
				pan = AntMath.trimToRange(pan, -1, 1);
				_ratingPan.add(pan);
			}
			i++;
		}

		// Реальная текущая громкость.
		_volumeAdjust = _ratingVolume.average() * updateFade();
		_panAdjust = _ratingPan.average();
		updateTransform();
	}

	/**
	 * Рассчет стерео-эффекта для звука без слушателей.
	 */
	function soundForCenter() : Void {
		if(cameras == null)  {
			cameras = AntG.cameras;
		}
		var radial : Float;
		var pan : Float;
		var position : AntPoint = new AntPoint();
		var camera : AntCamera;
		var n : Int = cameras.length;
		if(_ratingVolume.length() != n)  {
			_ratingVolume = new AntRating(n);
			_ratingPan = new AntRating(n);
		}
		var i : Int = 0;
		while(i < n) {
			camera = try cast(cameras[i], AntCamera) catch(e:Dynamic) null;
			if(camera != null)  {
				_source.getScreenPosition(camera, position);
				radial = AntMath.distance(position.x, position.y, camera.width * 0.5, camera.height * 0.5) / parent.radius;
				radial = AntMath.trimToRange(radial, 0, 1);
				_ratingVolume.add(1 - radial);
				pan = (position.x - camera.width * 0.5) / parent.radius;
				pan = AntMath.trimToRange(pan, -1, 1);
				_ratingPan.add(pan);
			}
			i++;
		}

		_volumeAdjust = _ratingVolume.average() * updateFade();
		_panAdjust = _ratingPan.average();
		updateTransform();
	}

	/**
	 * Обработка затухания или увеличения громкости звука.
	 */
	function updateFade() : Float {
		var fade : Float = 1;
		if(_fadeOutTimer > 0)  {
			_fadeOutTimer -= AntG.elapsed;
			if(_fadeOutTimer <= 0)  {
				((_pauseOnFadeOut)) ? pause() : stop();
			}
			fade = _fadeOutTimer / _fadeOutTotal;
			fade = ((fade < 0)) ? 0 : fade;
		}

		else if(_fadeInTimer > 0)  {
			_fadeInTimer -= AntG.elapsed;
			fade = _fadeInTimer / _fadeInTotal;
			fade = ((fade < 0)) ? 0 : 1 - fade;
		}
		return fade;
	}

	/**
	 * Обновление трансформации звука.
	 */
	function updateTransform() : Void {
		_soundTransform.volume = ((parent.mute) ? 0 : 1) * parent.volume * _volumeAdjust;
		_soundTransform.pan = _panAdjust;
		if(_soundChannel != null)  {
			_soundChannel.soundTransform = _soundTransform;
		}
	}

	/**
	 * Обработка события завершения воспроизведения звука.
	 */
	function soundCompleteHandler(event : Event) : Void {
		kill();
		eventComplete.dispatch(this);
	}

	//---------------------------------------
	// GETTER / SETTERS
	//---------------------------------------
	/**
	 * Возвращает указатель на источник звука.
	 */
	function get_source() : AntEntity {
		return _source;
	}

	/**
	 * Определяет громкость звука.
	 */
	function set_volume(value : Float) : Float {
		if(_source == null && _soundChannel != null)  {
			_soundTransform.volume = value * parent.volume;
			_soundChannel.soundTransform = _soundTransform;
		}
		return value;
	}

	/**
	 * @private
	 */
	function get_volume() : Float {
		return _soundTransform.volume;
	}

}

