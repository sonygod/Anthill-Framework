//import ru.antkarlov.anthill.debug.AntDrawer;
package testdrive;

import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.plugins.*;
import ru.antkarlov.anthill.utils.AntColor;

class TestTween extends AntState {

	//protected var _camera:AntCamera;
	var _actor : AntActor;
	//private var _start:AntPoint;
	//private var _end:AntPoint;
	//private var _t:int;
	//private var _d:int;
	var _started : Bool;
	//private var _move:Boolean = false;
	var _tween : AntTween;
	var _transList : Vector<String>;
	var _labelCurTrans : AntLabel;
	/**
	 * @constructor
	 */
	public function new() {
		_started = false;
		super();
		/* Список типов анимаций для твиннера. 
		Данный список нужен чтобы из него каждый раз выбирать случайную анимацию.*/
		var arr : Vector<String> = new Vector<String>();
		
		arr = Vector.ofArray([AntTransition.LINEAR,
		AntTransition.EASE_IN,
		AntTransition.EASE_OUT,
		AntTransition.EASE_IN_OUT,
		AntTransition.EASE_OUT_IN,
		AntTransition.EASE_IN_BACK,
		AntTransition.EASE_OUT_BACK, 
		AntTransition.EASE_IN_OUT_BACK,
 AntTransition.EASE_OUT_IN_BACK, AntTransition.EASE_IN_ELASTIC, AntTransition.EASE_OUT_ELASTIC, AntTransition.EASE_IN_OUT_ELASTIC, AntTransition.EASE_OUT_IN_ELASTIC, AntTransition.EASE_IN_BOUNCE, AntTransition.EASE_OUT_BOUNCE, AntTransition.EASE_IN_OUT_BOUNCE, AntTransition.EASE_OUT_IN_BOUNCE]);
		_transList = arr;
	}

	/**
	 * @private
	 */
	override public function create() : Void {
		/*_camera = new AntCamera(0, 0, 640, 480);
		_camera.fillBackground = true;
		_camera.backgroundColor = 0xff000000;
		AntG.addCamera(_camera);
		AntG.track(_camera, "TestAntActor camera");*/
		// Очищаем монитор.
		//AntG.debugger.monitor.clear();
		var loader : AntAssetLoader = new AntAssetLoader();
		// Добавляем классы клипов которые необходимо растеризировать.
		var arr : Vector<Class<Dynamic>> = new Vector<Class<Dynamic>>();
		
		arr = Vector.ofArray([Type.resolveClass("SoundSource_mc"), Type.resolveClass("Fade_mc")]);
	
		loader.addClips(arr);
		// Добавляем обработчик для завершения процесса растеризации.
		loader.eventComplete.add(onCacheComplete);
		// Запускаем процесс растеризации клипов.
		loader.start();
		// Показываем отладчик.
		/*AntG.debugger.show();
		AntG.debugger.console.hide();
		AntG.debugger.monitor.hide();
		AntG.debugger.perfomance.hide();*/
		var labelInfo : AntLabel = new AntLabel("system");
		labelInfo.z = 999;
		labelInfo.reset(15, 15);
		labelInfo.beginChange();
		labelInfo.text = "Demonstration of AntTween.
Previous / next demo: LEFT / RIGHT.";
		labelInfo.highlightText("AntTween", AntColor.RED);
		labelInfo.highlightText("LEFT", AntColor.LIME);
		labelInfo.highlightText("RIGHT", AntColor.LIME);
		labelInfo.setStroke();
		labelInfo.endChange();
		add(labelInfo);
		_labelCurTrans = new AntLabel("system");
		_labelCurTrans.text = "just click anywhere...";
		_labelCurTrans.reset(AntG.widthHalf - _labelCurTrans.width / 2, AntG.height - 60);
		add(_labelCurTrans);
		
		
		
		
		for (i in 0...10) {
			
			
	    var _labelCurTrans2 = new AntLabel("system");
		_labelCurTrans2.color = cast Math.random() * 0xFFFFFF;
		_labelCurTrans2.text = "label....dfdf"+i;
		_labelCurTrans2.reset(i*100,i*50);
		add(_labelCurTrans2);
		}
		
		
		
		super.create();
	}

	/**
	 * @private
	 */
	function onCacheComplete(aLoader : AntAssetLoader) : Void {
		aLoader.destroy();
		var fade : AntActor = new AntActor();
		fade.addAnimationFromCache("Fade_mc");
		add(fade);
		_actor = new AntActor();
		_actor.addAnimationFromCache("SoundSource_mc");
		_actor.reset(AntG.widthHalf, AntG.heightHalf);
		add(_actor);
		_tween = new AntTween(_actor, 1);
		
		_started = true;
	}
	
	
	function onTweenComplete(e) {
		
		
		AntG.camera.setBounds(0, 0, 1000, 600);
		//AntG.camera.zoom = 1;
		AntG.camera.target = null;
	}
	
	function onTweenStart(e) {
		
		AntG.camera.setBounds(0, 0, 1000, 600);
	//	AntG.camera.zoom = 2;
		AntG.camera.target = _actor;
	}

	/**
	 * Этот метод вызывается каждый кадр перед тем как все будет отрисовано.
	 * Здесь следует выполнять процессинг игры.
	 */
	override public function update() : Void {
		if(_started)  {
			if(AntG.mouse.isPressed())  {
				_actor.scaleX = _actor.scaleY = 1;
				var p : AntPoint=new AntPoint();
				 
							p= AntG.mouse.getWorldPosition(null, p);
				_actor.angle = AntMath.angleDeg(_actor.x, _actor.y, p.x, p.y);
				// Выбираем случайный переход (анимацию).
				var transName : String = _transList[AntMath.randomRangeInt(0, _transList.length - 1)];
				_labelCurTrans.beginChange();
				_labelCurTrans.text = "Current transition name: " + transName;
				_labelCurTrans.highlightText(transName, AntColor.AQUA);
				_labelCurTrans.endChange();
				_labelCurTrans.reset(AntG.widthHalf - _labelCurTrans.width / 2, AntG.height - 60);
				// Сбрасываем параметры твинера.
				_tween.reset(_actor, 1, transName);
				_tween.moveTo(p.x, p.y);
				_tween.eventComplete.add(onTweenComplete);
				_tween.eventStart.add(onTweenStart);
				_tween.start();
			}
		}
		super.update();
	}

	/**
	 * @private
	 */
	override public function destroy() : Void {
		/*_camera.destroy();
		_camera = null;*/
		super.destroy();
	}

}

