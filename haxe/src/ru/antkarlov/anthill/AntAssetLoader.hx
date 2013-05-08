/**

 * Данный класс создан для того чтобы упростить и объеденить загрузку графических ресурсов из разных источников.

 * 

 * <p>Используя методы данного класса вы можете сформировать список ресурсов которые необходимо загрузить и обработать,

 * например, это могут быть векторные клипы которые необходимо растеризировать, создание анимаций из растровых изображений

 * вкомпилированных в программу, либо загрузка графических атласов и создание анимаций из них.</p>

 * 

 * <p>Пример использования:</p>

 * 

 * <listing>

 * var loader:AntAssetLoader = new AntAssetLoader();

 * 

 * // Растеризация векторных клипов.

 * loader.addClips([ SomeClip1_mc, SomeClip2_mc ]);

 * 

 * // Загрузка растрового изображения - это может быть лента кадров. В данном вызове размер кадра указан 32x32

 * loader.addGraphic(MyBmpClass, "MyAnimationName", 32, 32);

 * 

 * // Загрузка растрового изображения с информацией о расположении графики на нем.

 * loader.addAtlasA(MyBmpAtlasClass, MyXmlAtlasClass, "AtlasWithInterfaces");

 * loader.addGraphicFromAtlas("AtlasWithInterfaces", "BtnPlay", "btn_play");

 * 

 * loader.start();

 * </listing>

 * 

 * @see	AntAtlas

 * @see	AntAnimation

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  07.02.2013

 */
package ru.antkarlov.anthill;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.ByteArray;

import haxe.Timer;
import msignal.Signal;


class AntAssetLoader {

	//---------------------------------------
	// CLASS CONSTANTS
	//---------------------------------------
	static var DATA_SPRITE : UInt = 1;
	static var DATA_CLIP : UInt = 2;
	static var DATA_GRAPHIC : UInt = 3;
	static var DATA_ATLAS : UInt = 4;
	static var DATA_ATLAS_GRAPHIC : UInt = 5;
	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**

	 * Событие срабатывающее при запуске процесса загрузки активов.

	 */
	public var eventStart : Signal1<Dynamic>;
	/**

	 * Событие срабатывающее каждый шаг процесса загрузки активов.

	 * В качестве аргумента передается текущий процент загрузки в диапазоне от 0 до 1.

	 */
	public var eventProcess : Signal2<Dynamic,Dynamic>;
	/**

	 * Событие срабатывающее при завершении процесса загрузки активов.

	 */
	public var eventComplete : Signal1<Dynamic>;
	/**

	 * Количество обрабатываемых активов за один шаг.

	 * Чем больше количество, тем быстрее будет завершена загрузка активов.

	 * Но при большом количестве возрастает и задержка, что в случае 

	 * обработки больших данных может вызвать подвисание приложения.

	 * @default	10

	 */
	public var countPerStep : Int;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	var _contentStorage : AntStorage;
	var _atlasStorage : AntStorage;
	var _queue : Vector<String>;
	var _index : Int;
	var _isStarted : Bool;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new() {
		//super()
		_contentStorage = new AntStorage();
		_atlasStorage = new AntStorage();
		_queue = new Vector<String>();
		_index = 0;
		_isStarted = false;
		eventStart = new Signal1(AntAssetLoader);
		eventProcess = new Signal2(AntAssetLoader, Float);
		eventComplete = new Signal1(AntAssetLoader);
		countPerStep = 10;
	}

	/**

	 * @private

	 */
	public function destroy() : Void {
		_contentStorage.clear();
		_atlasStorage.clear();
		_contentStorage = null;
		_atlasStorage = null;
		_queue = null;
		eventStart.destroy();
		eventProcess.destroy();
		eventComplete.destroy();
		eventStart = null;
		eventProcess = null;
		eventComplete = null;
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * @private

	 */
	public function addSprite(aSpriteClass : Class<Dynamic>, aKey : String = null) : Void {
		if(aKey == null)  {
			aKey = Type.getClassName(aSpriteClass);
		}
		var data : Dynamic = {
			kind : DATA_SPRITE,
			graphicClass : aSpriteClass

		};
		_contentStorage.set(aKey, data);
		_queue.push(aKey);
	}

	/**

	 * Добавляет обычный клип в очередь на кэширование.

	 * 

	 * @param	aClipClass	 Имя класса клипа который необходимо растеризировать.

	 * @param	aKey	 Имя анимации под которым будет доступна растровая копия клипа после растеризации.

	 */
	public function addClip(aClipClass : Class<Dynamic>, aKey : String = null) : Void {
		if(aKey == null)  {
			aKey = Type.getClassName(aClipClass);
		}
		var data : Dynamic = {
			kind : DATA_CLIP,
			graphicClass : aClipClass

		};
		_contentStorage.set(aKey, data);
		_queue.push(aKey);
	}

	/**

	 * Добавляет список клипов в очередь на кэширование.

	 * 

	 * @param	aClipClasses	 Список клипов.

	 */
	public function addClips(aClipClasses : Vector<Class<Dynamic>>) : Void {
		var i : Int = 0;
		var n : Int = aClipClasses.length;
		while(i < n) {
			addClip(aClipClasses[i++]);
		}

	}

	/**

	 * Добавляет растровую картинку в очередь на кэширование.

	 * 

	 * <p>Если задана ширина или высота кадра, то изображение автоматически будет разрезано на кадры

	 * равные заданным параметрам. Если значения высоты и ширины кадра не заданы, то будет создана 

	 * однокадровая анимация содержащая в себе изображение целиком.</p>

	 * 

	 * @param	aGraphicClass	 Класс растрового изображения.

	 * @param	aKey	 Имя анимации под которым будет доступна растровая копия изображения после обработки.

	 * @param	aFrameWidth	 Размер кадра анимации по ширине.

	 * @param	aFrameHeight	 Размер кадра анимации по высоте.

	 * @param	aOriginX	 Смещение кадров анимации по X относительно нулевой координаты.

	 * @param	aOriginY	 Смещение кадров анимации по Y относительно нулевой координаты.

	 */
	public function addGraphic(aGraphicClass : Class<Dynamic>, aKey : String = null, aFrameWidth : Int = 0, aFrameHeight : Int = 0, aOriginX : Int = 0, aOriginY : Int = 0) : Void {
		if(aKey == null)  {
			aKey = Type.getClassName(aGraphicClass);
		}
		var data : Dynamic = {
			kind : DATA_GRAPHIC,
			graphicClass : aGraphicClass,
			frameWidth : aFrameWidth,
			frameHeight : aFrameHeight,
			originX : aOriginX,
			originY : aOriginY,

		};
		_contentStorage.set(aKey, data);
		_queue.push(aKey);
	}

	/**

	 * Добавляет растровую картинку атласа и информацию о расположении графики на нем для последующего кэширования.

	 * 

	 * @param	aAtlasGraphicClass	 Класс растрового изображения для атласа.

	 * @param	aXmlData	 Данные для извлечения графики из атласа.

	 * @param	aKey	 Имя атласа рекомендуется указывать для получения доступа к атласу по имени, приемуществено для извлечения графики из атласа.

	 */
	public function addAtlas(aAtlasGraphicClass : Class<Dynamic>, aXmlData : XML, aKey : String) : Void {
		/*if(aKey == null)  {
			aKey = Type.getClassName(aAtlasGraphicClass);
		}
		var data : Dynamic = {
			kind : DATA_ATLAS,
			graphicClass : aAtlasGraphicClass,
			xmlData : aXmlData,

		};
		_contentStorage.set(aKey, data);
		_queue.push(aKey);*/
	}

	/**

	 * Альтернативный метод добавления атласа и информации о расположении графики на нем для последущего кэширования

	 * в случае если xml данные вкомпилированны в приложение.

	 * 

	 * @param	aAtlasGraphicClass	 Класс растрового изображения для атласа.

	 * @param	aXmlDataClass	 Класс xml данных вкомпилированных в приложение.

	 * @param	aKey	 Имя атласа рекомендуется указывать для получения доступа к атласу по имени, приемуществено для извлечения графики из атласа.

	 */
	public function addAtlasA(aAtlasGraphicClass : Class<Dynamic>, aXmlDataClass : Class<Dynamic>, aKey : String) : Void {
		var data : ByteArray = try cast(Type.createInstance(aAtlasGraphicClass, []), ByteArray) catch(e:Dynamic) null;
		var strXML : String = data.readUTFBytes(data.length);
		//addAtlas(aAtlasGraphicClass, new XML(strXML), aKey);
	}

	/**

	 * Добавляет в очередь создание растровой картинки из атласа.

	 * 

	 * @param	aAtlasKey	 Имя ранее добавленного атласа.

	 * @param	aKey	 Имя создаваемой анимации.

	 * @param	aFramePrefix	 Префикс встречающийся в имени кадров которые будут включены в анимацию. Если префикс не указан, то будет создана анимация со всеми кадрами атласа.

	 * @param	aOriginX	 Смещение кадров анимации по X относительно нулевой координаты.

	 * @param	aOriginY	 Смещение кадров анимации по Y относительно нулевой координаты.

	 */
	public function addGraphicFromAtlas(aAtlasKey : String, aKey : String, aFramePrefix : String = "", aOriginX : Int = 0, aOriginY : Int = 0) : Void {
		var data : Dynamic = {
			kind : DATA_ATLAS_GRAPHIC,
			atlasKey : aAtlasKey,
			framePrefix : aFramePrefix,
			originX : aOriginX,
			originY : aOriginY,

		};
		_contentStorage.set(aKey, data);
		_queue.push(aKey);
	}

	/**

	 * Запускает процесс подготовки активов.

	 */
	public function start() : Void {
		if(!_isStarted && _queue.length > 0)  {
			if(countPerStep <= 0)  {
				throw new flash.errors.Error("AntAssetLoader: Number of processed clips in one step must be greater than 0.");
			}
			_isStarted = true;
			_index = 0;
			eventStart.dispatch(this);
			step();
		}

		else  {
			eventComplete.dispatch(this);
		}

	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**

	 * Шаг обработки активов.

	 */
	function step() : Void {
		var endValue : Int = ((_index + countPerStep >= _queue.length)) ? _queue.length : _index + countPerStep;
		var key : String;
		while(_index < endValue) {
			key = _queue[_index++];
			process(key);
		}

		if(endValue == _queue.length)  {
			_queue.length = 0;
			_isStarted = false;
			eventComplete.dispatch(this);
		}

		else  {
			//setTimeout(step, 1);
			Timer.delay(step, 1);
			eventProcess.dispatch(this, _index / _queue.length);
		}

	}

	/**

	 * Обработка актива с указанным именем.

	 * 

	 * @param	aKey	 Имя актива который необходимо обработать.

	 */
	function process(aKey : String) : Void {
		var atlas : AntAtlas;
		var anim : AntAnimation;
		var data : Dynamic = _contentStorage.get(aKey);
		if(data != null)  {
			var _sw0_ = (data.kind);
			switch(_sw0_) {
			case DATA_SPRITE:
				var sprite : Sprite = Type.createInstance(data.graphicClass,[]);//new Type.getClass(data.graphicClass)();
				anim = new AntAnimation(aKey);
				anim.makeFromSprite(sprite);
				AntAnimation.toCache(anim);
			case DATA_CLIP:
				var clip : MovieClip = Type.createInstance(data.graphicClass,[]);
				anim = new AntAnimation(aKey);
				anim.makeFromMovieClip(clip);
				AntAnimation.toCache(anim);
			case DATA_GRAPHIC:
				anim = new AntAnimation(aKey);
				anim.makeFromGraphic(data.graphicClass, data.frameWidth, data.frameHeight, data.originX, data.originY);
				AntAnimation.toCache(anim);
			case DATA_ATLAS:
				if(!_atlasStorage.containsKey(aKey))  {
					_atlasStorage.set(aKey, new AntAtlas(data.graphicClass, data.xmlData));
				}
			case DATA_ATLAS_GRAPHIC:
				atlas = try cast(_atlasStorage.get(data.atlasKey), AntAtlas) catch(e:Dynamic) null;
				if(atlas != null)  {
					anim = atlas.makeAnimation(data.framePrefix, aKey, data.originX, data.originY);
					AntAnimation.toCache(anim);
				}

				else  {
					throw new flash.errors.Error("Atlas with key \"" + data.atlasKey + "\" not found. Add atlas" + "into list before to making animations.");
				}

			}
		}
	}

}

