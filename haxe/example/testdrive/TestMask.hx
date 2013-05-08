package testdrive;

import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.utils.AntColor;

class TestMask extends AntState {

	@:meta(Embed(source="../assets/pic1.png"))
	var _pic1 : Class<Dynamic>;
	@:meta(Embed(source="../assets/pic2.png"))
	var _pic2 : Class<Dynamic>;
	var _camera : AntCamera;
	var _maskedGroup : AntEntity;
	var _maskSpeed : AntPoint;
	var _isStarted : Bool;
	var _explosionInterval : Float;
	var _velocity : AntPoint;
	/**
	 * @constructor
	 */
	public function new() {
		super();
		_isStarted = false;
		_maskSpeed = new AntPoint(100, 100);
		_velocity = new AntPoint();
	}

	/**
	 * @private
	 */
	override public function create() : Void {
		// Создаем загрузчик графических ресурсов.
		var loader : AntAssetLoader = new AntAssetLoader();
		// Добавляем загрузку вкомпилированных изображений.
		loader.addGraphic(_pic1, "TestPic1");
		loader.addGraphic(_pic2, "TestPic2");
		var arr : Vector<Class<Dynamic>> = new Vector<Class<Dynamic>>();
		var arr2: Array<Class<Dynamic>>=[Type.resolveClass('MaskClip_mc'), Type.resolveClass('Explosion_mc')];
		// Добавляем список клипов для растеризации.
		arr = Vector.ofArray(arr2);
		loader.addClips(arr);
		// Добавляем обработчик для завершения процесса растеризации.
		loader.eventComplete.add(onCacheComplete);
		// Запускаем процесс растеризации клипов.
		loader.start();
		var labelInfo : AntLabel = new AntLabel("system");
		labelInfo.reset(15, 15);
		labelInfo.beginChange();
		labelInfo.text = "Demonstration of AntMask.
Previous / next demo: LEFT / RIGHT.";
		labelInfo.highlightText("AntMask", AntColor.RED);
		labelInfo.highlightText("LEFT", AntColor.LIME);
		labelInfo.highlightText("RIGHT", AntColor.LIME);
		labelInfo.setStroke();
		labelInfo.endChange();
		labelInfo.tag = 999;
		add(labelInfo);
		super.create();
	}

	/**
	 * Обработчик завершения загрузки графических ресурсов.
	 */
	function onCacheComplete(aLoader : AntAssetLoader) : Void {
		aLoader.destroy();
		// Создаем группу содержимое которой будет под маской.
		_maskedGroup = new AntEntity();
		// Создаем фон
		var bg : AntActor = new AntActor();
		bg.addAnimationFromCache("TestPic2");
		add(bg);
		// Создаем какой-нибудь объект который будет под маской.
		var fg : AntActor = new AntActor();
		fg.addAnimationFromCache("TestPic1");
		// Добавляем объект в группу к которой будет применена маска.
		_maskedGroup.add(fg);
		// Добавляем группу с маской в основную группу.
		add(_maskedGroup);
		// Создаем маску для группы.
		_maskedGroup.mask = new AntMask();
		// Добавляем анимацию маски.
		_maskedGroup.mask.addAnimationFromCache("MaskClip_mc");
		// Включаем воспроизведение анимации.
		_maskedGroup.mask.play();
		// Включаем заливку буффера для маски если это необходимо.
		//_maskedGroup.mask.fillBackground = true;
		//_maskedGroup.mask.backgroundColor = 0x00ff00;
		_isStarted = true;
		_explosionInterval = 1;
	}

	/**
	 * Создание взрыва.
	 */
	function onMakeExplosion() : Void {
		// Подробное описания кода в этом методе можно найти в классе TestAntActor.
		var explosion : AntActor = try cast(_maskedGroup.recycle(AntActor), AntActor) catch(e:Dynamic) null;
		if(!explosion.exists)  {
			explosion.revive();
		}

		else  {
			explosion.animationSpeed = 0.5;
			explosion.addAnimationFromCache("Explosion_mc");
			explosion.eventComplete.add(onKill);
			explosion.play();
		}

		explosion.reset(AntMath.randomRangeInt(0, AntG.width), AntMath.randomRangeInt(0, AntG.height));
	}

	/**
	 * Убийство взрыва после завершения его проигрывания.
	 */
	function onKill(aActor : AntActor) : Void {
		aActor.kill();
	}

	/**
	 * @private
	 */
	override public function update() : Void {
		if(_camera == null)  {
			_camera = AntG.getCamera();
		}
		_maskedGroup.mask.x += _maskSpeed.x * AntG.elapsed;
		_maskedGroup.mask.y += _maskSpeed.y * AntG.elapsed;
		if(_maskedGroup.mask.x > 640 || _maskedGroup.mask.x < 0)  {
			_maskedGroup.mask.x = ((_maskedGroup.mask.x > 640)) ? 640 : 0;
			_maskSpeed.x *= -1;
		}
		if(_maskedGroup.mask.y > 480 || _maskedGroup.mask.y < 0)  {
			_maskedGroup.mask.y = ((_maskedGroup.mask.y > 480)) ? 480 : 0;
			_maskSpeed.y *= -1;
		}
		if(_isStarted)  {
			_explosionInterval -= 10 * AntG.elapsed;
			if(_explosionInterval <= 0)  {
				onMakeExplosion();
				_explosionInterval = 1;
			}
		}
		updateCamera();
		super.update();
	}

	/**
	 * @private
	 */
	override public function postUpdate() : Void {
		/*AntG.beginWatch();
		AntG.watchValue("onScreen", AntG.numOnScreen);
		AntG.endWatch();*/
		super.postUpdate();
	}

	/**
	 * Реализация управления камерой.
	 */
	function updateCamera() : Void {
		// Обработка нажатия клавиш и установка соотвествующих скоростей для скролла.
		if(AntG.keys.A) _velocity.x = 400;
		if(AntG.keys.D) _velocity.x = -400;
		if(AntG.keys.W) _velocity.y = 400;
		if(AntG.keys.S) _velocity.y = -400;
		_camera.scroll.x += Std.int(_velocity.x * AntG.elapsed);
		_camera.scroll.y += Std.int(_velocity.y * AntG.elapsed);
		// Применяем простое замедление движения камеры.
		_velocity.multiply(0.9);
		// Корректно зануляем скорость когда камера полностью остановилась.
		_velocity.x = (AntMath.equal(AntMath.abs(_velocity.x), 0, 1)) ? 0 : _velocity.x;
		_velocity.y = (AntMath.equal(AntMath.abs(_velocity.y), 0, 1)) ? 0 : _velocity.y;
	}

}

