/**
 * Звуковой менеджер используется для взаимодействия со звуковыми сущностями.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  05.09.2012
 */
package ru.antkarlov.anthill;

import flash.media.Sound;
import flash.net.URLRequest;
using Lambda;

class AntSoundManager {

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**
	 * Массив с указателями на слушателей звуков. Если нет ни одного слушателя,
	 * то для звуков с источниками рассчитывается стерео-эффект исходя из наличия и положения камер.
	 */
	public var listeners : Array<Dynamic>;
	/**
	 * Радиус в пределах которого слушатели могут слышать звуки. Используется для рассчета стерео-эффекта.
	 * @default	500
	 */
	public var radius : Float;
	/**
	 * Флаг определяющий возможно ли воспроизведение звуков.
	 * @default	false
	 */
	public var mute : Bool;
	/**
	 * Общая громкость для всех звуков.
	 * @default	1
	 */
	public var volume : Float;
	/**
	 * Базовый путь для потоковых звуков если они все находятся в одном месте.
	 * @default	""
	 */
	public var baseURL : String;
	/**
	 * Массив со всеми звуками которыми управляет данный менеджер.
	 */
	public var sounds : Array<Dynamic>;
	/**
	 * Количество звуков в менеджере. Может отличаться от реального количества звуков.
	 */
	public var numSounds : Int;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**
	 * Хранилище классов на заэмбендженные звуки.
	 */
	var _classes : AntStorage;
	/**
	 * Хранилище названий/путей до потоковых звуков.
	 */
	var _streams : AntStorage;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new() {
		//super()
		listeners = [];
		radius = 500;
		mute = false;
		volume = 1;
		baseURL = "";
		sounds = [];
		numSounds = 0;
		_classes = new AntStorage();
		_streams = new AntStorage();
	}

	/**
	 * @private
	 */
	public function destroy() : Void {
		clear();
		_classes.clear();
		_streams.clear();
		_classes = null;
		_streams = null;
	}

	/**
	 * Добавляет слушателя звуков в менеджер. Слушателем звуков является персонаж или некий объект
	 * исходя из положения которого рассчитывается стерео-эффект для звуков.
	 * <p>Примечание: Если менеджер звуков не имеет ни одного слушателя, то стерео-эффект для звуков рассчитывается
	 * на основе камер. То есть в таком случае слушателями будут центры камер.</p>
	 * <p>Внимание: Стерео-эффект рассчитывается для звуков только в том случае, если для них указан объект источник.</p>
	 * 
	 * @param	aListener	 Слушатель которого необходимо добавить.
	 * @return		Возвращает указатель на добавленного слушателя.
	 */
	public function addListener(aListener : AntEntity) : AntEntity {
		var n : Int = listeners.length;
		var i : Int = 0;
		while(i < n) {
			if(listeners[i] == null)  {
				listeners[i] = aListener;
				return aListener;
			}
			i++;
		}
		listeners[listeners.length] = aListener;
		return aListener;
	}

	/**
	 * Удаляет слушателя звуков из менеджера.
	 * 
	 * @param	aListener	 Слушатель которого необходимо удалить.
	 * @param	aSplice	 Если true, то ячейка занимаемая слушателем звуков в массиве так же будет удалена.
	 * @return		Возвращает указатель на удаленного слушателя.
	 */
	public function removeListener(aListener : AntEntity, aSplice : Bool = false) : AntEntity {
		var index : Int = listeners.indexOf(aListener);
		if(index < 0 || index >= listeners.length)  {
			return aListener;
		}
		listeners[index] = null;
		if(aSplice)  {
			listeners.splice(index, 1);
		}
		return aListener;
	}

	/**
	 * Проверяет наличие слушателя в менеджере.
	 * 
	 * @param	aListener	 Слушател наличие которого необходимо проверить.
	 * @return		Возвращает true если слушатель уже добавлен в менеджер.
	 */
	public function containsListener(aListener : AntEntity) : Bool {
		return ((listeners.indexOf(aListener) > -1)) ? true : false;
	}

	/**
	 * Добавляет оригинальный класс звука.
	 * 
	 * @param	aSoundClass	 Оригинальный класс звука который включен в *.fla или *.swc.
	 * @param	aName	 Имя звука по которому можно вызвать его воспроизведение. Если имя не указано, то звук будет доступен по имени оригинального класса.
	 */
	public function addEmbedded(aSoundClass : Class<Dynamic>, aName : String = null) : Void {
		if(aName == null)  {
			aName = Type.getClassName(aSoundClass);
		}
		_classes.set(aName, aSoundClass);
	}

	/**
	 * Добавляет имя файла до потокового звука размещенного где-либо.
	 * <p>Внимание: В качестве потоковых звуков могут быть файлы только в формате *.mp3.</p>
	 * 
	 * @param	aURL	 Путь и/или имя файла.
	 * @param	aName	 Имя звука по которому можно вызвать его воспроизведение. Если имя не указано, то звук будет доступен по указанному пути и/или имени файла.
	 */
	public function addStream(aURL : String, aName : String = null) : Void {
		if(aName == null)  {
			aName = aURL;
		}
		_streams.set(aName, aURL);
	}

	/**
	 * Добавляет экземпляр звука в менеджер.
	 * 
	 * @return		Возвращает указатель на добавленный экземпляр звука.
	 */
	public function add(aSound : AntSound) : AntSound {
		var i : Int = 0;
		while(i < numSounds) {
			if(sounds[i] == null)  {
				sounds[i] = aSound;
				return aSound;
			}
			i++;
		}

		if(aSound.parent != null && aSound.parent != this)  {
			aSound.parent.remove(aSound);
		}
		aSound.parent = this;
		sounds[numSounds] = aSound;
		numSounds++;
		return aSound;
	}

	/**
	 * Удаляет экземпляр звука из менеджера.
	 * 
	 * @param	aSound	 Звук который необходимо удалить.
	 * @param	aSplice	 Флаг определяющий необходимо ли удалить так же ячейку которую занимал удаляемый звук.
	 * @return		Возвращает указатель на удаленный звук.
	 */
	public function remove(aSound : AntSound, aSplice : Bool = false) : AntSound {
		var i : Int = sounds.indexOf(aSound);
		if(i < 0 || i >= sounds.length)  {
			return null;
		}
		sounds[i] = null;
		aSound.parent = null;
		if(aSplice)  {
			sounds.splice(i, 1);
			numSounds--;
		}
		return aSound;
	}

	/**
	 * Запускает воспроизведение звука с указанным именем.
	 * 
	 * @param	aName	 Имя звука который необходимо воспроизвести.
	 * @param	aSource	 Объект-источник звука.
	 * @param	aSingle	 Флаг определяющий могут ли быть запущены иные копии данного звука.
	 * @param	aRepeats	 Количество повторов воспроизведения звука.
	 * @return		Возвращает указатель на экземпляр звука.
	 */
	public function play(aName : String, aSource : AntEntity = null, aSingle : Bool = false, aRepeats : Int = 1) : AntSound {
		if(mute || volume <= 0)  {
			return null;
		}
		if(aSingle && isPlaying(aName))  {
			return null;
		}
		var sound : AntSound = recycle(aName);
		sound.revive();
		sound.play(aSource, 0, aRepeats);
		return sound;
	}

	/**
	 * Останавливает воспроизведение всех звуков с указанным именем. Если источник звука не указан, то будут остановлены 
	 * все звуки с указанным именем, иначе только звуки с указанным именем для указанного источника звука.
	 * 
	 * @param	aName	 Имя звуков которые необходимо остановить.
	 * @param	aSource	 Сущность для которой необходимо остановить воспроизведение звуков с указанным именем.
	 */
	public function stop(aName : String, aSource : AntEntity = null) : Void {
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && sound.exists && sound.name == aName)  {
				if(aSource != null && sound.source == aSource)  {
					sound.kill();
				}

				else if(aSource == null)  {
					sound.kill();
				}
			}
			i++;
		}

	}

	/**
	 * Останавливает воспроизведение всех звуков. Если указан источник звука, то будет остановлено воспроизведение всех звуков только
	 * для указанного источника. Если источник звука не указан, то будут остановлены абсолютно все звуки.
	 * 
	 * @param	aSource	 Сущность для которой необходимо остановить воспроизведение всех звуков.
	 */
	public function stopAll(aSource : AntEntity = null) : Void {
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && sound.exists)  {
				if(aSource != null && sound.source == aSource)  {
					sound.kill();
				}

				else if(aSource == null)  {
					sound.kill();
				}
			}
			i++;
		}

	}

	/**
	 * Очищает все звуки и слушателей.
	 */
	public function clear() : Void {
		var i : Int = 0;
		var n : Int = listeners.length;
		while(i < n) {
			listeners[i] = null;
			i++;
		}

		listeners = [];
		var sound : AntSound;
		i = 0;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null)  {
				sound.parent = null;
				sound.destroy();
			}
			sounds[i] = null;
			i++;
		}

		sounds = [];
		numSounds = 0;
	}

	/**
	 * Проверяет проигрывается ли звук с указанным именем. Если источник звука не указан, то проверяются все звуки с указанным 
	 * именем, иначе проигрывание звуков с указанным имемен для указанного источника.
	 * 
	 * @param	aSource	 Сущность для которой необходимо проверить наличие проигрываемого звука.
	 * @return		Возвращает true если звук с указанным именем проигрывается
	 */
	public function isPlaying(aName : String, aSource : AntEntity = null) : Bool {
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && sound.exists && sound.name == aName)  {
				if(aSource != null && sound.source == aSource)  {
					return true;
				}

				else if(aSource == null)  {
					return true;
				}
			}
			i++;
		}

		return false;
	}

	/**
	 * Возвращает доступный звук с указанным именем.
	 * 
	 * @param	aName	 Имя звука который необходимо получить.
	 * @return		Возвращает указатель на доступный звук или null если доступных звуков с указанным именем нет.
	 */
	public function getAvailable(aName : String) : AntSound {
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && !sound.exists && sound.name == aName)  {
				return sound;
			}
			i++;
		}

		return null;
	}

	/**
	 * Возвращает ранее использованный или новый звук для нового использования.
	 * 
	 * @param	aName	 Имя звука который необходимо получить.
	 * @return		Возвращает указатель на экземпляр звука для использования.
	 */
	public function recycle(aName : String) : AntSound {
		var sound : AntSound = getAvailable(aName);
		if(sound != null)  {
			return sound;
		}
		sound = new AntSound(aName, extractSound(aName));
		return ((Std.is(sound, AntSound))) ? add(sound) : null;
	}

	/**
	 * Ставит воспроизведение всех звуков на паузу.
	 */
	public function pause() : Void {
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && sound.exists)  {
				sound.pause();
			}
			i++;
		}

	}

	/**
	 * Возобновляет воспроизведение всех звуков.
	 */
	public function resume() : Void {
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && sound.exists)  {
				sound.resume();
			}
			i++;
		}

	}

	/**
	 * Обработчик всех звуков.
	 */
	public function update() : Void {
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && sound.exists)  {
				sound.update();
			}
			i++;
		}

	}

	/**
	 * Возвращает количество "мертвых" звуков.
	 * 
	 * @return		Возвращает количество не используемых звуков.
	 */
	public function numDead() : Int {
		var num : Int = 0;
		var i : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && !sound.alive)  {
				num++;
			}
			i++;
		}

		return num;
	}

	/**
	 * Возвращает количество воспроизводимых звуков.
	 * 
	 * @return		Возвращает количество звуков которые воспроизводятся в данный момент времени.
	 */
	public function numLiving() : Int {
		var i : Int = 0;
		var num : Int = 0;
		var sound : AntSound;
		while(i < numSounds) {
			sound = try cast(sounds[i], AntSound) catch(e:Dynamic) null;
			if(sound != null && sound.alive)  {
				num++;
			}
			i++;
		}

		return num;
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**
	 * Извлекает звук с указанным именем из хранилища заэмбедженных звуков или из потоков.
	 * 
	 * @param	aName	 Имя звука который необходимо получить.
	 * @return		Возвращает указатель на экземпляр звука.
	 */
	function extractSound(aName : String) : Sound {
		if(_classes.containsKey(aName))  {
			var C : Class<Dynamic> = _classes.get(aName);
			return try cast(Type.createInstance(C, []), Sound) catch(e:Dynamic) null;
		}

		else if(_streams.containsKey(aName))  {
			return new Sound(new URLRequest(baseURL + _streams.get(aName)));
		}
		AntG.log("WARNING: Missing sound \"" + aName + "\".", "error");
		return null;
	}

}

