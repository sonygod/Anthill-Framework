//import ru.antkarlov.anthill.debug.AntDrawer;
/**
 * Демострация работы с анимациями и актерами.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  25.08.2012
 */
package testdrive;

import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.utils.AntColor;

class TestAntActor extends AntState {

	//private var _camera:AntCamera;
	var _isStarted : Bool;
	var _randomScale : Bool;
	var _randomColor : Bool;
	/**
	 * @constructor
	 */
	public function new() {
		_isStarted = false;
		_randomScale = false;
		_randomColor = false;
		super();
	}

	/**
	 * @private
	 */
	override public function create() : Void {
		/*
		Примечание: С версии 0.3.1 если камера не создана в методе create(),
		то камера будет создана автоматически.
		*/
		/*_camera = new AntCamera(0, 0, 640, 480);
		_camera.fillBackground = true;
		_camera.backgroundColor = 0xff000000;
		AntG.addCamera(_camera);
		AntG.track(_camera, "TestAntActor camera");*/
		// Очищаем монитор.
		//	AntG.debugger.monitor.clear();
		// Добавляем классы клипов которые необходимо растеризировать.
		var loader : AntAssetLoader = new AntAssetLoader();
		var arr : Vector<Class<Dynamic>> = new Vector<Class<Dynamic>>();
		var cc:Array<Class<Dynamic>> = [Type.resolveClass('Explosion_mc'), Type.resolveClass('ButtonBasic_mc')];
		arr=Vector.ofArray(cc);
		loader.addClips(arr);
		// Добавляем обработчик для завершения процесса растеризации.
		loader.eventComplete.add(onCacheComplete);
		// Запускаем процесс растеризации клипов.
		loader.start();
		// Показываем отладчик.
		/*AntG.debugger.show();
		AntG.debugger.console.hide(); // Скрываем консоль.
		AntG.debugger.monitor.show(); // Показываем монитор.
		AntG.debugger.perfomance.show(); // Показываем окно производительности.*/
		super.create();
	}

	/**
	 * @private
	 */
	function onCacheComplete(aLoader : AntAssetLoader) : Void {
		aLoader.destroy();
		// Кнопка вкл./выкл. случайного размера спрайтов.
		var btnScale : AntButton = AntButton.makeButton("ButtonBasic_mc", "scale: off", new AntLabel("system", 8, 0x000000));
		// Устаналиваем кнопку где-то внизу в центре экрана
		btnScale.x = AntG.widthHalf - btnScale.width * 0.5 - 5;
		btnScale.y = AntG.height - 30;
		// Добавляем обработчик клика (указатель на метод)
		btnScale.eventDown.add(onScaleClick);
		// Кнопка вкл./выкл. случайного цвета спрайтов.
		var btnColor : AntButton = AntButton.makeButton("ButtonBasic_mc", "color: off", new AntLabel("system", 8, 0x000000));
		// Устаналиваем кнопку где-то внизу в центре экрана
		btnColor.x = AntG.widthHalf + btnColor.width * 0.5 + 5;
		btnColor.y = AntG.height - 30;
		// Добавляем обработчик клика
		btnColor.eventDown.add(onColorClick);
		// В переменную 'z' записываем любое большое, далее используем эту переменную для сортировки актеров.
		btnScale.z = btnColor.z = 999;
		// Добавляем кнопки в структуру
		add(btnScale);
		add(btnColor);
		// Все готово к работе и можно создавать взрывы!
		_isStarted = true;
		// Информационная текстовая метка.
		var labelInfo : AntLabel = new AntLabel("system");
		labelInfo.reset(15, 15);
		labelInfo.beginChange();
		labelInfo.text = "Demonstration of AntActor.
Previous / next demo: LEFT / RIGHT.";
		labelInfo.highlightText("AntActor", AntColor.RED);
		labelInfo.highlightText("LEFT", AntColor.LIME);
		labelInfo.highlightText("RIGHT", AntColor.LIME);
		labelInfo.setStroke();
		labelInfo.endChange();
		labelInfo.z = 999;
		add(labelInfo);
		/*	AntG.track(btnScale, "scale button");
		AntG.track(btnColor, "scale color");
		AntG.track(labelInfo, "label info");
		
		AntG.registerCommandWithArgs("test", testCommand, [ String ]);*/
	}

	function testCommand(aValue : String) : Void {
		AntG.log("test: " + aValue);
	}

	/**
	 * Обработчик клика по кнопке scale.
	 */
	function onScaleClick(aButton : AntButton) : Void {
		// Включаем/выключаем режим случайного размера и меняем текстовую метку кнопки.
		_randomScale = !_randomScale;
		aButton.text = ((_randomScale)) ? "scale: on" : "scale: off";
	}

	/**
	 * Обработчик клика по кнопку color.
	 */
	function onColorClick(aButton : AntButton) : Void {
		// Включаем/выключаем режим случайного цвета и меняем текстовую метку кнопки.
		_randomColor = !_randomColor;
		aButton.text = ((_randomColor)) ? "color: on" : "color: off";
	}

	/**
	 * Создание взрыва.
	 */
	function onMakeExplosion() : Void {
		// Используем метод recycle чтобы переработать старый не используемый объект,
		// если не используемых объектов нет, то будет создан новый экземпляр объека
		// из указанного класса.
		var explosion : AntActor = try cast(defGroup.recycle(AntActor), AntActor) catch(e:Dynamic) null;
		// Если объект был переработан (то есть когда-то ранее существовал)
		if(!explosion.exists)  {
			// Воскрешаем его.
			explosion.revive();
		}

		else  {
			// Иначе объект новый.
			// Задаем скорость анимации.
			//explosion.animationSpeed = 1;
			/*
			Подсказка: если задать более медленную скорость анимации, то будет создаваться больше 
			актеров и получится настоящий стресс-тест ;)
			*/
			// Добавляем новую анимацию.
			explosion.addAnimationFromCache("Explosion_mc");
			// Вешаем обработчик события на завершение анимации чтобы убить актера.
			explosion.eventComplete.add(onKill);
			// Запускаем воспроизведение анимации.
			explosion.play();
			/*
			Примечание: если используется метод recycle() для создания новых экземпляров,
			то нет необходимости вручную добалять новые объекты в структуру, так как метод recycle(),
			добавляет объект автоматически в ту группу для которой он был вызван.
			*/
			// Сортируем все объекты по переменной 'z' - это нужно чтобы кнопки были всегда поверх взрывов.
			explosion.z = defGroup.numChildren;
			defGroup.sort("z");
		}

		// Задаем случайное местоположение.
		explosion.reset(AntMath.randomRangeInt(0, AntG.width), AntMath.randomRangeInt(0, AntG.height));
		// Если включен режим случайного размера, то даем случайный размер либо 1 к 1.
		explosion.scaleX = explosion.scaleY = ((_randomScale)) ? AntMath.randomRangeNumber(0.5, 1.5) : 1;
		/*
		Примечание: при задании актеру каких-либо трансформаций типа вращения, скэйла или blend,
		для визаулизации такого актера используется метод draw(), который требует больше времени для отрисовки. 
		*/
		// Если включен режим случайного цвета, то задаем случайный цвет...
		if(_randomColor)  {
			explosion.color = AntColor.combineRGB(AntMath.randomRangeInt(0, 255), AntMath.randomRangeInt(0, 255), AntMath.randomRangeInt(0, 255));
		}

		else  {
			// Иначе заливаем прозрачным белым - что означает игнорирование цветового смешивания.
			explosion.color = 0x00FFFFFF;
		}

		/*
		Примечание: при задании актеру цветовой трансформации и/или прозрачности, то для рендера такого актера  
		используется дополнительный буфер чтобы не испортить оригинальную анимацию. Таким образом на каждого 
		актера с цветовой трансформацией выделяется дополнительная оперативная память. Если сбросить 
		прозрачность на 1.0 и цвет на 0x00FFFFFF, то дополнительный буфер будет освобожден. Эту разницу хорошо видно
		в профайлере производительности на этом юнит-тесте если включать и выключать случайный цвет.
		*/
	}

	/**
	 * Обработчик события завершения проигрывания анимации для актера.
	 */
	function onKill(aActor : AntActor) : Void {
		// Убиваем актера.
		aActor.kill();
	}

	/**
	 * Этот метод вызывается каждый кадр перед тем как все будет отрисовано.
	 * Здесь следует выполнять процессинг игры.
	 */
	override public function update() : Void {
		// Каждый кадр создаем новые взрывы.
		if(_isStarted)  {
			onMakeExplosion();
		}
		super.update();
	}

	/**
	 * Этот метод вызывается каждый кадр сразу после метода update().
	 */
	override public function postUpdate() : Void {
		// Выводим интересующую нас информацию в дебаг мониторчик.
		/*AntG.beginWatch();
		AntG.watchValue("active", AntG.numOfActive);
		AntG.watchValue("visible", AntG.numOfActive);
		AntG.watchValue("onScreen", AntG.numOnScreen);
		AntG.endWatch();*/
	}

	/**
	 * Данный метод вызывается при переключении между состояниями в тот момент
	 * когда текущее состояние удаляется из структуры Anthill.
	 */
	override public function destroy() : Void {
		// Если камера была создана вручную, то здесь её следует освободить.
		/*_camera.destroy();
		_camera = null;*/
		super.destroy();
	}

}

