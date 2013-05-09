/**
 * Пример использования расширения Living Lights для Anthill.
 * 
 * @author Anton Karlov (ant.karlov@gmail.com)
 * @since  21.04.2013
 */
import flash.display.BlendMode;
import flash.display.MovieClip;
import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.utils.AntColor;
import ru.antkarlov.anthill.extensions.livinglights.*;
import ru.antkarlov.anthill.plugins.*;
using Reflect;
class StateLights extends AntState {

	//---------------------------------------
	// PRIVATE VARIABLES
	//---------------------------------------
	var _lightEnvironment : AntLightEnvironment;
	var _userLight : AntLight;
	var _velocity : AntPoint;
	var _camera : AntCamera;
	var _night : AntActor;
	var _nightTween : AntTween;
	var _nightMode : Bool;
	var _blurMode : Bool;
	var _blendMode : Bool;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new() {
		super();
		_velocity = new AntPoint();
		_nightMode = true;
		_blurMode = true;
		_blendMode = true;
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**
	 * @private
	 */
	override public function create() : Void {
		// Добавляем классы клипов которые необходимо растеризировать.
		var loader : AntAssetLoader = new AntAssetLoader();
		var arr : Vector<Class<Dynamic>> = new Vector<Class<Dynamic>>();
		
		
		arr = Vector.ofArray([
		Type.resolveClass('ButtonBasic_mc'),
		Type.resolveClass('BackgroundGrass_mc'),
		Type.resolveClass('Night_mc'), 
		//
		Type.resolveClass('Tree_mc'),
		Type.resolveClass('TreeTrunk_mc'),
		Type.resolveClass('Herb_mc'),
		Type.resolveClass('Stone_mc'),
		Type.resolveClass('Box_mc'), 
		Type.resolveClass('MagicFly_mc'),
		Type.resolveClass('ParticlePurple_mc'),
		Type.resolveClass('ParticleYellow_mc'),
		Type.resolveClass('TinyFire_mc'),
		Type.resolveClass('Torch_mc')]);
		loader.addClips(arr);
		// Добавляем обработчик для завершения процесса растеризации.
		loader.eventComplete.add(onCacheComplete);
		// Запускаем процесс растеризации клипов.
		loader.start();
		// Показываем отладчик.
		//AntG.debugger.show();
		//AntG.debugger.console.hide();
		//AntG.debugger.monitor.hide();
		//AntG.debugger.perfomance.hide();
		super.create();
	}

	/**
	 * @private
	 */
	function onCacheComplete(aLoader : AntAssetLoader) : Void {
		aLoader.destroy();
		// 1. Создание окружение для света.
		//-----------------------------------------------------------------
		_lightEnvironment = new AntLightEnvironment();
		// 2. Загрузка уровня.
		//-----------------------------------------------------------------
		//makeBackground();
		loadLevel(new TestLevel_mc());
		// 3. Добавление светового окружения в структуру.
		//-----------------------------------------------------------------
		add(_lightEnvironment);
		// 4. Другое...
		//-----------------------------------------------------------------
		// Произвольный источник света.
		var someLight : AntLight = new AntLight();
		someLight.reset(353, 240);
		someLight.colorIn = 0xFFFFCD;
		someLight.alpha = 0.5;
		someLight.live = false;
		someLight.rayStep = 1;
		someLight.angleStep = 1;
		_lightEnvironment.addLight(someLight);
		// Пользовательский источник света.
		_userLight = new AntLight();
		_userLight.reset(320, 240);
		_userLight.radius = 150;
		_userLight.colorIn = 0xFFFFCD;
		_userLight.ratio = 0;
		_userLight.angleStep = 10;
		_userLight.rayStep = 13;
		_userLight.updateInterval = 0.05;
		_lightEnvironment.addLight(_userLight);
		// Ночная пелена.
		_night = new AntActor();
		_night.addAnimationFromCache("Night_mc");
		_night.alpha = 0.8;
		_night.blend = BlendMode.OVERLAY;
		add(_night);
		_night.isScrolled = false;
		_nightTween = new AntTween(_night, 1);
		// 5. Создание пользовательского интерфейса.
		//-----------------------------------------------------------------
		makeGUI();
	}

	/**
	 * @inheritDoc
	 */
	override public function update() : Void {
		updateUserLight();
		updateCameraMotion();
		super.update();
		//defGroup.sort("y");
	}

	/**
	 * @inheritDoc
	 */
	override public function postUpdate() : Void {
		if(_lightEnvironment != null)  {
			/*	AntG.beginWatch();
			AntG.watchValue("lightsOnScreen", _lightEnvironment.numOnScreen);
			AntG.watchValue("lightsVisible", _lightEnvironment.numVisible);
			AntG.watchValue("lightsLive", _lightEnvironment.numLive);
			AntG.endWatch();*/
		}
	}

	//---------------------------------------
	// PRIVATE METHODS
	//---------------------------------------
	/**
	 * Обновление пользовательского света.
	 */
	function updateUserLight() : Void {
		var p : AntPoint=new AntPoint();
		if(_userLight != null)  {
			 p  = AntG.mouse.getWorldPosition(null, p);
			_userLight.reset(p.x, p.y);
		}
	}

	/**
	 * Обработка скролла камеры.
	 */
	function updateCameraMotion() : Void {
		if(_camera == null) _camera = AntG.camera;
		if(AntG.keys.A || AntG.keys.LEFT) _velocity.x = 400;
		if(AntG.keys.D || AntG.keys.RIGHT) _velocity.x = -400;
		if(AntG.keys.W || AntG.keys.UP) _velocity.y = 400;
		if(AntG.keys.S || AntG.keys.DOWN) _velocity.y = -400;
		_camera.scroll.x += Std.int(_velocity.x * AntG.elapsed);
		_camera.scroll.y += Std.int(_velocity.y * AntG.elapsed);
		// Применяем простое замедление движения камеры.
		_velocity.multiply(0.9);
		// Корректно зануляем скорость когда камера полностью остановилась.
		_velocity.x = (AntMath.equal(AntMath.abs(_velocity.x), 0, 1)) ? 0 : _velocity.x;
		_velocity.y = (AntMath.equal(AntMath.abs(_velocity.y), 0, 1)) ? 0 : _velocity.y;
	}

	/**
	 * Загружает уровень из указанного клипа.
	 */
	function loadLevel(aLevelClip : MovieClip) : Void {
		// 1. Ассоциация методов создания объектов с именами клипов в клипе уровня.
		//-----------------------------------------------------------------
		var funcs : Dynamic = {
			tree : makeTree,
			stone : makeStone,
			herb : makeHerb,
			box : makeBox,
			redlight : makeRedLight,
			torch : makeTorch,
			purpleFly : makePurpleFly,
			yellowFly : makeYellowFly,

		};
		// 2. Считываем информацию о всех объектах в клипе уровня.
		//-----------------------------------------------------------------
		var objects : Array<Dynamic> = [];
		var mc : MovieClip;
		var i : Int = 0;
		var n : Int = aLevelClip.numChildren;
		while(i < n) {
			mc = try cast(aLevelClip.getChildAt(i++), MovieClip) catch(e:Dynamic) null;
			// Если с именем клипа есть ассоциациия в массиве методов.
			if(mc != null && funcs.field(mc.name) != null)  {
				// Добавляем информацию об объекте в список.
				objects.push({
					func : cast funcs.field(mc.name),
					posX : mc.x,
					posY : mc.y,

				});
			}
		}

		// 3. Сортируем порядок расположения объектов по высоте.
		//-----------------------------------------------------------------
		//objects.sortOn("posY", Array.NUMERIC);
		objects.sort(function (a:Dynamic, b:Dynamic):Int {
			
			if (a.field("poseY") > b.field("poseY") ){
				return 1;
			}
			if (a.field("poseY") < b.field("poseY")) {
				return -1;
			}
			return 0;
			
		});
		// 4. Создаем объекты по списку.
		//-----------------------------------------------------------------
		i = 0;
		n = objects.length;
		var obj : Dynamic;
		while(i < n) {
			obj = objects[i++];
			obj.func.apply(this, [obj.posX, obj.posY]);
		}

	}

	/**
	 * Создает фон.
	 */
	function makeBackground() : Void {
		var bgEntity : AntEntity = new AntEntity();
		add(bgEntity);
		var dx : Int = 0;
		var dy : Int = 0;
		var bgTile : AntActor;
		var i : Int = 0;
		while(i < 6) {
			bgTile = new AntActor();
			bgTile.addAnimationFromCache("BackgroundGrass_mc");
			bgTile.x = dx;
			bgTile.y = dy;
			bgEntity.add(bgTile);
			dx += Std.int(bgTile.width) - 4;
			if(i == 2)  {
				dy += Std.int(bgTile.height) - 4;
				dx = 0;
			}
			i++;
		}
	}

	/**
	 * Создает дерево.
	 */
	function makeTree(aX : Int, aY : Int) : Void {
		// Создаем ствол.
		var trunk : AntActor = new AntActor();
		trunk.addAnimationFromCache("TreeTrunk_mc");
		trunk.x = aX;
		trunk.y = aY;
		add(trunk);
		/*
		Ствол дерева создается отдельно и не добавляется в
		световое окружение чтобы на стволы падал свет.
		*/
		// Создаем листву.
		var leafs : AntActor = new AntActor();
		leafs.addAnimationFromCache("Tree_mc");
		leafs.x = aX;
		leafs.y = aY;
		leafs.playRandomFrame();
		add(leafs);
		_lightEnvironment.add(leafs);
	}

	/**
	 * Создает камень.
	 */
	function makeStone(aX : Int, aY : Int) : Void {
		var stone : AntActor = new AntActor();
		stone.addAnimationFromCache("Stone_mc");
		stone.reset(aX, aY);
		add(stone);
		_lightEnvironment.add(stone);
	}

	/**
	 * Создает куст.
	 */
	function makeHerb(aX : Int, aY : Int) : Void {
		var herb : AntActor = new AntActor();
		herb.addAnimationFromCache("Herb_mc");
		herb.reset(aX, aY);
		herb.playRandomFrame();
		add(herb);
	}

	/**
	 * Создает ящик.
	 */
	function makeBox(aX : Int, aY : Int) : Void {
		var box : AntActor = new AntActor();
		box.addAnimationFromCache("Box_mc");
		box.reset(aX, aY);
		add(box);
		_lightEnvironment.add(box);
	}

	/**
	 * Создает красный источник света.
	 */
	function makeRedLight(aX : Int, aY : Int) : Void {
		var torchLight : AntLight = new AntLight();
		torchLight.reset(aX, aY);
		torchLight.radius = 200;
		torchLight.colorIn = 0xFF89FF;
		torchLight.colorOut = 0xFF89FF;
		torchLight.angleStep = 1;
		torchLight.rayStep = 10;
		torchLight.live = false;
		_lightEnvironment.addLight(torchLight);
	}

	/**
	 * Создает факел.
	 */
	function makeTorch(aX : Int, aY : Int) : Void {
		// Создание источника света для факела.
		var flame : AntLight = new AntLight();
		flame.reset(aX, aY);
		flame.radius = 50;
		flame.alpha = 0.5;
		flame.colorIn = 0xFFFFCD;
		flame.angleStep = 10;
		flame.rayStep = 15;
		flame.live = false;
		flame.ratio = 0;
		_lightEnvironment.addLight(flame);
		// Создание факела.
		var torch : Torch = new Torch();
		torch.light = flame;
		torch.x = aX;
		torch.y = aY;
		add(torch);
	}

	/**
	 * Создает розового летуна.
	 */
	function makePurpleFly(aX : Int, aY : Int) : Void {
		// Создание источника света.
		var magicLight : AntLight = new AntLight();
		magicLight.reset(aX, aY);
		magicLight.radius = 150;
		magicLight.colorIn = 0xFF89FF;
		magicLight.colorOut = 0xFF89FF;
		magicLight.ratio = 0;
		magicLight.angleStep = 10;
		magicLight.rayStep = 13;
		magicLight.updateInterval = 0.05;
		_lightEnvironment.addLight(magicLight);
		// Создание летуна.
		var mf : MagicFly = new MagicFly();
		mf.variety = 1;
		// Розовый
		mf.reset(aX, aY);
		mf.light = magicLight;
		mf.targetX = aX;
		mf.targetY = aY;
		add(mf);
	}

	/**
	 * Создает желтого летуна.
	 */
	function makeYellowFly(aX : Int, aY : Int) : Void {
		// Создание источника света.
		var magicLight : AntLight = new AntLight();
		magicLight.radius = 150;
		magicLight.alpha = 0.5;
		magicLight.ratio = 0;
		magicLight.angleStep = 10;
		magicLight.reset(aX, aY);
		magicLight.rayStep = 13;
		magicLight.updateInterval = 0.05;
		_lightEnvironment.addLight(magicLight);
		// Создание летуна.
		var mf : MagicFly = new MagicFly();
		mf.variety = 2;
		// Желтый
		mf.reset(aX, aY);
		mf.light = magicLight;
		mf.targetX = aX;
		mf.targetY = aY;
		add(mf);
	}

	/**
	 * @private
	 */
	function makeGUI() : Void {
		var labelInfo : AntLabel = new AntLabel("system");
		labelInfo.reset(15, 15);
		labelInfo.beginChange();
		labelInfo.text = "Demonstration of \"Living Lights\" for Anthill.";
		labelInfo.highlightText("\"Living Lights\"", AntColor.RED);
		labelInfo.highlightText("Anthill", AntColor.LIME);
		labelInfo.setStroke();
		labelInfo.endChange();
		add(labelInfo);
		labelInfo.isScrolled = false;
		// Кнопка вкл./выкл. ночь
		var btnNight : AntButton = AntButton.makeButton("ButtonBasic_mc", "night: on", new AntLabel("system", 8, 0x000000));
		btnNight.x = 211;
		btnNight.y = 444;
		btnNight.eventDown.add(onNightClick);
		add(btnNight);
		btnNight.isScrolled = false;
		// Кнопка вкл./выкл. сглаживание.
		var btnBlur : AntButton = AntButton.makeButton("ButtonBasic_mc", "blur: on", new AntLabel("system", 8, 0x000000));
		btnBlur.x = 320;
		btnBlur.y = 444;
		btnBlur.eventDown.add(onBlurClick);
		add(btnBlur);
		btnBlur.isScrolled = false;
		// Кнопка вкл./выкл. смешивание цветов.
		var btnBlend : AntButton = AntButton.makeButton("ButtonBasic_mc", "blend: on", new AntLabel("system", 8, 0x000000));
		btnBlend.x = 429;
		btnBlend.y = 444;
		btnBlend.eventDown.add(onBlendClick);
		add(btnBlend);
		btnBlend.isScrolled = false;
	}

	/**
	 * @private
	 */
	function onNightClick(aButton : AntButton) : Void {
		_nightMode = !_nightMode;
		_nightTween.reset(_night, 1);
		if(_nightMode)  {
			_night.visible = true;
			_nightTween.fadeTo(0.8);
		}

		else  {
			_nightTween.animate("alpha", 0);
			_nightTween.eventComplete.add(onNightEnd);
		}

		aButton.label.text = ((_nightMode)) ? "night: on" : "night: off";
		_nightTween.start();
	}

	/**
	 * @private
	 */
	function onNightEnd(?dfdf) : Void {
		if(!_nightMode) _night.visible = false;
		_nightTween.eventComplete.clear();
	}

	/**
	 * @private
	 */
	function onBlurClick(aButton : AntButton) : Void {
		_blurMode = !_blurMode;
		aButton.label.text = ((_blurMode)) ? "blur: on" : "blur: off";
		var light : AntLight;
		var i : Int = 0;
		while(i < _lightEnvironment.numLights) {
			light = try cast(_lightEnvironment.lights[i++], AntLight) catch(e:Dynamic) null;
			if(light != null && light.exists)  {
				light.blur = ((_blurMode)) ? new AntPoint(10, 10) : new AntPoint();
			}
		}

	}

	/**
	 * @private
	 */
	function onBlendClick(aButton : AntButton) : Void {
		_blendMode = !_blendMode;
		aButton.label.text = ((_blendMode)) ? "blend: on" : "blend: off";
		var light : AntLight;
		var i : Int = 0;
		while(i < _lightEnvironment.numLights) {
			light = try cast(_lightEnvironment.lights[i++], AntLight) catch(e:Dynamic) null;
			if(light != null && light.exists)  {
				light.blend = ((_blendMode)) ? BlendMode.OVERLAY : null;
			}
		}

	}

}

