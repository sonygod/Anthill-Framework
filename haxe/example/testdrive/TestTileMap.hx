package testdrive;

import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.utils.AntColor;

class TestTileMap extends AntState {

	var _camera : AntCamera;
	var _tileMapSky : AntTileMap;
	var _tileMapBG : AntTileMap;
	var _tileMapFG : AntTileMap;
	var _isStarted : Bool;
	var _percentLabel : AntLabel;
	var _currentPercent : Int;
	var _tileHighlight : AntActor;
	var _velocity : AntPoint;
	var _btnSwitchMap : AntButton;
	var _currentMap : String;
	/**
	 * @constructor
	 */
	public function new() {
		_isStarted = false;
		_currentPercent = 0;
		_velocity = new AntPoint();
		super();
	}

	/**
	 * @private
	 */
	override public function create() : Void {
		super.create();
		_camera = new AntCamera(0, 0, 640, 480);
		_camera.fillBackground = true;
		_camera.backgroundColor = 0xFF68A3B0;
		AntG.addCamera(_camera);
		//AntG.track(_camera, "TestTileMap camera");
		// Добавляем классы клипов которые необходимо растеризировать.
		var loader : AntAssetLoader = new AntAssetLoader();
		//var arr : Vector<Class<Dynamic>> = new Vector<Class<Dynamic>>();
		
		
		var arr : Vector<Class<Dynamic>>=Vector.ofArray([Type.resolveClass('ButtonGray_mc'), Type.resolveClass('MushroomerTileSet_mc'), Type.resolveClass('TileHighlight_mc')]);
		loader.addClips(arr);
		// Добавляем обработчик для завершения процесса растеризации.
		loader.eventComplete.add(onCacheComplete);
		// Запускаем процесс растеризации клипов.
		loader.start();
		// Очищаем монитор.
		//	AntG.Dger.monitor.clear();
	}

	/**
	 * Обработчик события завершения растеризации.
	 */
	function onCacheComplete(aLoader : AntAssetLoader) : Void {
		aLoader.destroy();
		// Актер подсвечивающий текущую клетку.
		_tileHighlight = new AntActor();
		_tileHighlight.addAnimationFromCache("TileHighlight_mc");
		_tileHighlight.tag = 5;
		add(_tileHighlight);
		// Текстовая метка демонстрирующая процесс кэширования уровня.
		_percentLabel = new AntLabel("system", 24, 0xFFFFFF);
		_percentLabel.tag = 11;
		_percentLabel.x = AntG.widthHalf;
		_percentLabel.y = AntG.heightHalf;
		_percentLabel.text = "100%";
		_percentLabel.origin.set(_percentLabel.width * 0.5, _percentLabel.height * 0.5);
		//AntG.track(_percentLabel, "percent label");
		_btnSwitchMap = AntButton.makeButton("ButtonGray_mc", "cached map", new AntLabel("system", 8, 0x000000));
		_btnSwitchMap.tag = 10;
		_btnSwitchMap.x = 100;
		_btnSwitchMap.y = 100;
		_btnSwitchMap.eventDown.add(onSwitchMap);
		add(_btnSwitchMap);
		var labelInfo : AntLabel = new AntLabel("system");
		labelInfo.x = 15;
		labelInfo.y = 15;
		labelInfo.beginChange();
		labelInfo.text = "Demonstration of AntTileMap.
Previous / next demo: LEFT / RIGHT.

" + "Control the camera: WASD keys.";
		labelInfo.highlightText("AntTileMap", AntColor.RED);
		labelInfo.highlightText("LEFT", AntColor.LIME);
		labelInfo.highlightText("RIGHT", AntColor.LIME);
		labelInfo.setStroke();
		labelInfo.isScrolled = false;
		labelInfo.endChange();
		labelInfo.tag = 999;
		add(labelInfo);
		makeCachedTileMap();
	}

	/**
	 * Создает кэшированную тайловую карту из клипов.
	 */
	function makeCachedTileMap() : Void {
		_isStarted = false;
		_currentPercent = 0;
		// Создаем тайловые карты.
		_tileMapSky = new AntTileMap();
		_tileMapSky.tag = 1;
		if(_tileMapBG != null)  {
			_tileMapBG.destroy();
		}
		if(_tileMapFG != null)  {
			_tileMapFG.destroy();
		}
		_tileMapBG = new AntTileMap();
		_tileMapFG = new AntTileMap();
		_tileMapBG.tag = 2;
		_tileMapFG.tag = 3;
		/* Для тайловой карты можно выбрать вариант быстрой отрисовки, таким образом
		методы draw() вызываются только для тех тайлов (актеров), которые попадают в камеры,
		но данный способ игнорирует порядок сортировки тайлов. По умолчанию тайлы отрисовываются
		классическим способом: полным перебором всех сущностей. */
		_tileMapSky.drawQuickly = true;
		_tileMapBG.drawQuickly = true;
		_tileMapFG.drawQuickly = true;
		/*	AntG.track(_tileMapSky, "Sky");
		AntG.track(_tileMapBG, "Bg");
		AntG.track(_tileMapFG, "Fg");
		*/
		// Устанавливаем сколько тайлов кэшировать за один шаг.
		_tileMapSky.numPerStep = 16;
		_tileMapBG.numPerStep = 16;
		_tileMapFG.numPerStep = 16;
		/*
		Внимание: Чем больше тайлов кэшируется за один шаг, тем быстрее будет завершено 
		кэширование. Но чем больше размер тайлов тем меньше тайлов следует кэшировать за один 
		шаг чтобы не вызвать подвисание игры и своевременно демонстрировать ход процесса 
		кэширования. 
		*/
		// Устанавливаем количество тайлов (ячеек) по ширине и высоте.
		_tileMapSky.setMapSize(10, 5);
		_tileMapBG.setMapSize(15, 5);
		_tileMapFG.setMapSize(15, 5);
		// Устанавливаем размер тайла в пикселях.
		_tileMapSky.setTileSize(128, 128);
		_tileMapBG.setTileSize(128, 128);
		_tileMapFG.setTileSize(128, 128);
		// Добавляем в карты клипы которые будем кэшировать.
		_tileMapSky.addClip(Type.resolveClass('MTBackground_mc'));
		_tileMapBG.addClip(Type.resolveClass('MTLevelBackground_mc'));
		_tileMapFG.addClip(Type.resolveClass('MTLevelForeground_mc'));
		// Добавляем обработчики для завершения процесса кэширования.
		_tileMapSky.eventComplete.add(onCompleteSky);
		_tileMapBG.eventComplete.add(onCompleteBG);
		_tileMapFG.eventComplete.add(onCompleteFG);
		// Добавляем обработчик для отслеживания процесса кэширования.
		_tileMapSky.eventProcess.add(onProcess);
		_tileMapBG.eventProcess.add(onProcess);
		_tileMapFG.eventProcess.add(onProcess);
		/* Запускаем процесс кэширования. В первую очередь кэшируется задник, кэширование других
		тайловых карт запустится в обработчиках завершения кэширования текущей карты. */
		_tileMapSky.cacheClips();
		// Добавляем все тайловые карты.
		add(_tileMapSky);
		add(_tileMapBG);
		add(_tileMapFG);
		add(_percentLabel);
		defGroup.sort("tag", -1);
		// Флаг определяющий какая в данный момент карта.
		_currentMap = "cached";
		_percentLabel.revive();
	}

	/**
	 * @private
	 */
	function onProcess(aMap : AntTileMap, aPercent : Float) : Void {
		_percentLabel.text = AntMath.floor(AntMath.toPercent(_currentPercent + aPercent, 3)) + "%";
		if(aPercent == 1)  {
			_currentPercent += Std.int(aPercent);
		}
	}

	/**
	 * Обработчик завершения кэширования задника.
	 */
	function onCompleteSky(aMap : AntTileMap) : Void {
		// Запускаем кэширование заднего плана.
		_tileMapBG.cacheClips();
	}

	/**
	 * Обработчик завершения кэширования заднего плана.
	 */
	function onCompleteBG(aMap : AntTileMap) : Void {
		// Запускаем кэширование переднего плана.
		_tileMapFG.cacheClips();
	}

	/**
	 * Обработчик завершения кэширования переднего плана.
	 */
	function onCompleteFG(aMap : AntTileMap) : Void {
		// Задник небо скроллится вдвое медленнее.
		_tileMapSky.setScrollFactor(0.5, 0.5);
		// Поднимаем небо чуть выше - так уж нарисовано :)
		_tileMapSky.y = -100;
		// Опускаем задний и передний план ниже - тоже потому что так нарисовано.
		_tileMapBG.y = _tileMapFG.y = 100;
		/* Задний план будет двигаться на 10% медленее от обычного смещения - 
		это будет тоже такой эффект паралакса, хотя здесь он и не нужен по задумке. 
		Но выглядит здорово :) */
		_tileMapBG.setScrollFactor(0.9, 0.9);
		// Прибиваем метку с процессом.
		_percentLabel.kill();
		_tileHighlight.gotoAndStop(1);
		if (_camera != null)
		_camera.setBounds(0, 0, _tileMapFG.mapWidth, _tileMapFG.mapHeight);
		_isStarted = true;
	}

	/**
	 * @private
	 */
	function makeClassicTileMap() : Void {
		_isStarted = false;
		var tile : AntActor;
		var o : Dynamic;
		// Инициализируем задний план.
		//-----------------------------------------------------------------
		_tileMapBG.destroy();
		_tileMapBG = new AntTileMap();
		_tileMapBG.setMapSize(11, 8);
		_tileMapBG.setTileSize(64, 64);
		_tileMapBG.setTileSetFromCache("MushroomerTileSet_mc");
		_tileMapBG.tileAxisOffset.set(32, 32);
		// Массив определяющий задний план талового уровня.
		var bgMap : Array<Dynamic> = [];
		// Метод для быстрого добавления данных в массив.
		function addToBG(aX : Int, aY : Int, aFrame : Int) : Void {
			bgMap.push({
				x : aX,
				y : aY,
				frame : aFrame,

			});
		}
;
		// Примитивный формат уровня где: тайл по X, тайл по Y, разновидность тайла.
		addToBG(2, 2, 7);
		addToBG(8, 2, 7);
		addToBG(2, 3, 5);
		addToBG(3, 3, 10);
		addToBG(7, 3, 10);
		addToBG(8, 3, 5);
		addToBG(1, 4, 7);
		addToBG(2, 4, 8);
		addToBG(1, 5, 14);
		addToBG(2, 5, 11);
		addToBG(6, 5, 13);
		addToBG(8, 5, 11);
		addToBG(9, 5, 14);
		addToBG(1, 6, 11);
		addToBG(2, 6, 14);
		addToBG(3, 6, 11);
		addToBG(6, 6, 14);
		addToBG(7, 6, 13);
		addToBG(8, 6, 14);
		addToBG(9, 6, 11);
		addToBG(2, 7, 15);
		addToBG(3, 7, 12);
		addToBG(5, 7, 16);
		addToBG(6, 7, 11);
		addToBG(7, 7, 15);
		addToBG(8, 7, 11);
		addToBG(9, 7, 14);
		/* Примечание: В данном примере данные об уровне включены прямо в метод создания уровня, чтобы
		пример был более цельным и понятным. */
		// На основе данных об уровне строим тайловую карту заднего плана.
		var j : Int = 0;
		while(j < bgMap.length) {
			// Извлекаем информацию об ячейке.
			o = bgMap[j];
			/* Получаем тайл согласно координатам ячейки. Флаг true определяет, что в случае отсуствия
			тайла в заданной ячейке, будет создан новый. */
			tile = _tileMapBG.getTile(_tileMapBG.getIndex(o.x, o.y), true);
			// Переключаем полученный тайл на заданный кадр.
			tile.gotoAndStop(o.frame);
			// Записываем магическое значение тайла для сортировки.
			tile.tag = Std.int(tile.x - tile.y);
			j++;
		}
		// Инициализируем передний план.
		//-----------------------------------------------------------------
		_tileMapFG.destroy();
		_tileMapFG = new AntTileMap();
		_tileMapFG.setMapSize(11, 8);
		_tileMapFG.setTileSize(64, 64);
		_tileMapFG.setTileSetFromCache("MushroomerTileSet_mc");
		_tileMapFG.tileAxisOffset.set(32, 32);
		// Массив определяющий передний план талового уровня.
		var fgMap : Array<Dynamic> = [];
		function addToFG(aX : Int, aY : Int, aFrame : Int) : Void {
			fgMap.push({
				x : aX,
				y : aY,
				frame : aFrame,

			});
		}
;
		// Примитивный формат уровня где: тайл по X, тайл по Y, разновидность тайла.
		addToFG(10, 1, 18);
		addToFG(9, 2, 18);
		addToFG(10, 2, 1);
		addToFG(3, 3, 18);
		addToFG(4, 3, 18);
		addToFG(5, 3, 18);
		addToFG(7, 3, 18);
		addToFG(8, 3, 19);
		addToFG(9, 3, 3);
		addToFG(10, 3, 1);
		addToFG(0, 4, 18);
		addToFG(1, 4, 18);
		addToFG(2, 4, 18);
		addToFG(3, 4, 1);
		addToFG(4, 4, 3);
		addToFG(5, 4, 2);
		addToFG(7, 4, 2);
		addToFG(8, 4, 3);
		addToFG(9, 4, 1);
		addToFG(10, 4, 3);
		addToFG(0, 5, 1);
		addToFG(1, 5, 4);
		addToFG(2, 5, 2);
		addToFG(3, 5, 3);
		addToFG(4, 5, 2);
		addToFG(6, 5, 17);
		addToFG(8, 5, 2);
		addToFG(9, 5, 4);
		addToFG(10, 5, 1);
		addToFG(0, 6, 3);
		addToFG(3, 6, 2);
		addToFG(6, 6, 17);
		addToFG(10, 6, 3);
		addToFG(0, 7, 1);
		addToFG(1, 7, 3);
		addToFG(9, 6, 18);
		addToFG(9, 7, 4);
		addToFG(10, 7, 1);
		addToFG(6, 3, 17);
		addToFG(6, 4, 17);
		addToFG(6, 7, 17);
		/*
		Примечание: В данном примере данные об уровне включены прямо в метод создания уровня, чтобы
		пример был более цельным и понятным.
		*/
		// На основе данных об уровне строим тайловую карту заднего плана.
		var i : Int = 0;
		while(i < fgMap.length) {
			// Извлекаем информацию об ячейке.
			o = fgMap[i];
			/* Получаем тайл согласно координатам ячейки. Флаг true определяет, что в случае отсуствия
			тайла в заданной ячейке, будет создан новый. */
			tile = _tileMapFG.getTile(_tileMapFG.getIndex(o.x, o.y), true);
			// Переключаем полученный тайл на заданный кадр.
			tile.gotoAndStop(o.frame);
			// Записываем магическое значение тайла для сортировки.
			tile.tag =Std.int( tile.x - tile.y);
			i++;
		}
		// Сортируем тайловые карты для нужной нам последовательности отрисовки. Можете попробовать за комментировать данные строки.
		_tileMapBG.sort("tag", -1);
		_tileMapFG.sort("tag", -1);
		/* Если необходимо подсвечивать тайлы для карты с заниженным коэффицентом прокрутки,
		то для актера подсветки тоже занижаем коэффицент прокрутки */
		//_tileMapBG.setScrollFactor(0.5, 0.5);
		//_tileMapFG.setScrollFactor(0.5, 0.5);
		//_tileHighlight.scrollFactor.set(0.5, 0.5);
		// Добавляем карты в структуру.
		add(_tileMapBG);
		add(_tileMapFG);
		// Переключаем индекатор текущего тайла.
		_tileHighlight.gotoAndStop(2);
		// Снимаем ограничения для движения камеры.
		_camera.bounds = null;
		_isStarted = true;
	}

	/**
	 * @private
	 */
	function onSwitchMap(aButton : AntButton) : Void {
		if(!_isStarted)  {
			return;
		}
		if(_currentMap == "cached")  {
			_currentMap = "classic";
			makeClassicTileMap();
		}

		else  {
			_currentMap = "cached";
			makeCachedTileMap();
		}

		_btnSwitchMap.text = _currentMap + " map";
	}

	/**
	 * @inheritDoc
	 */
	override public function update() : Void {
		if(_isStarted)  {
			// Обработка нажатия клавиш и установка соотвествующих скоростей для скролла.
			if(AntG.keys.A) _velocity.x = 400;
			if(AntG.keys.D) _velocity.x = -400;
			if(AntG.keys.W) _velocity.y = 400;
			if(AntG.keys.S) _velocity.y = -400;
			_camera.scroll.x += Std.int(_velocity.x * AntG.elapsed);
			_camera.scroll.y += Std.int(_velocity.y * AntG.elapsed);
			//defGroup.x += Std.int(_velocity.x * AntG.elapsed);
			//defGroup.y += Std.int(_velocity.y * AntG.elapsed);
			// Применяем простое замедление движения камеры.
			_velocity.multiply(0.9);
			// Корректно зануляем скорость когда камера полностью остановилась.
			_velocity.x = (AntMath.equal(AntMath.abs(_velocity.x), 0, 1)) ? 0 : _velocity.x;
			_velocity.y = (AntMath.equal(AntMath.abs(_velocity.y), 0, 1)) ? 0 : _velocity.y;
			// Ограничение выезда камеры за пределы карты.
			/*
			Внимание: Начиная с версии Anthill 0.3.0 добавлена возможность устанавливать 
			границы для скролла камеры используя метод setBounds();
			*/
			/*if (_currentMap == "cached")
			{
			_camera.scroll.x = AntMath.trimToRange(_camera.scroll.x, -_tileMapBG.width + _camera.width, 0);
			_camera.scroll.y = AntMath.trimToRange(_camera.scroll.y, -_tileMapBG.height + _camera.height, 0);
			}*/
			// Получаем координаты мыши в игровом мире.
			var mousePos : AntPoint = AntG.mouse.getWorldPosition();
			/* Если тайловая карта имеет заниженный коэффицент прокрутки, то необходимо скорректировать
			координаты мыши чтобы они соотвествовали положению карты согласно её коээфицента прокрутки. */
			// mousePos.x += AntG.getCamera().scroll.x * _tileMapBG.scrollFactor.x;
			// mousePos.y += AntG.getCamera().scroll.y * _tileMapBG.scrollFactor.y;
			// Получаем индекс тайла над которым находится мышка.
			var index : Int = _tileMapFG.getIndexByPosition(mousePos.x, mousePos.y);
			// Если кликнули мышкой.
			if(AntG.mouse.isPressed() && _currentMap == "classic")  {
				// Получаем указатель на тайл по индексу.
				var tile : AntActor = _tileMapFG.getTile(index);
				if(tile != null)  {
					// Переключаем кадр тайла как для обычного актера.
					if(tile.currentFrame == tile.totalFrames)  {
						tile.gotoAndStop(1);
					}

					else  {
						tile.gotoAndStop(tile.currentFrame + 1);
					}

				}
			}
			_tileMapFG.getCoordinates(index, mousePos);
			/*	AntG.beginWatch();
			AntG.watchValue("index", index);
			AntG.watchValue("cell x", mousePos.x);
			AntG.watchValue("cell y", mousePos.y);
			AntG.endWatch();*/
			// Извлекаем координаты текущего тайла по индекусу, результат записывается в mousePos.
			_tileMapFG.getPosition(index, mousePos);
			// Подсвечиваем текущий тайл :)
			_tileHighlight.x = mousePos.x;
			_tileHighlight.y = mousePos.y;
		}
		super.update();
	}

	override public function postUpdate() : Void {
		//	AntG.watchValue("numOnScreen", AntG.numOnScreen);
		super.postUpdate();
	}

	override public function destroy() : Void {
		_camera.destroy();
		_camera = null;
		super.destroy();
	}

}

