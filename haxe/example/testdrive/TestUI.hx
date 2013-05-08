/**
 * Демонстрация работы кнопок и текстовых меток, а так же анимированных курсоров.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Anton Karlov
 * @since  26.08.2012
 */
package testdrive;

import ru.antkarlov.anthill.*;
import ru.antkarlov.anthill.utils.AntColor;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;

class TestUI extends AntState {

	var _labelForScale : AntLabel;
	var _scaleSpeed : Float;
	var _outputLabel : AntLabel;
	var _isStarted : Bool;
	var _test : Int;
	/**
	 * @constructor
	 */
	public function new() {
		_scaleSpeed = 1;
		_isStarted = false;
		_test = 100;
		super();
	}

	/**
	 * @private
	 */
	override public function create() : Void {
		/*AntG.debugger.console.hide();
		AntG.debugger.monitor.hide();
		AntG.debugger.perfomance.hide();
		
		AntG.debugger.monitor.clear();*/
		// Добавляем классы клипов которые необходимо растеризировать.
		var loader : AntAssetLoader = new AntAssetLoader();
		loader.countPerStep = 1;
		var arr : Vector<Class<Dynamic>> = new Vector<Class<Dynamic>>();
		arr = Vector.ofArray([
		Type.resolveClass("ButtonBasic_mc"),
		Type.resolveClass("ButtonGray_mc"), 
		Type.resolveClass("ButtonBlue_mc"),
		Type.resolveClass("ButtonVector_mc"),
		Type.resolveClass("CursorBasic_mc"), 
		Type.resolveClass("CursorBasicAnim_mc"),
		Type.resolveClass("CursorStop_mc"), 
		Type.resolveClass("CursorBusy_mc")]);
		loader.addClips(arr);
		// Добавляем обработчик для завершения процесса растеризации.
		loader.eventComplete.add(onCacheComplete);
		// Запускаем процесс растеризации клипов.
		loader.start();
		//	AntG.debugger.hide();
		super.create();
	}

	/**
	 * Обработчик события завершения растеризации.
	 */
	function onCacheComplete(aLoader : AntAssetLoader) : Void {
		aLoader.destroy();
		AntG.getCamera().backgroundColor = 0xFFFFFFFF;
		// Создание графического курсора
		AntG.mouse.makeCursor("CursorBasicAnim_mc");
		AntG.mouse.makeCursor("CursorStop_mc");
		AntG.mouse.makeCursor("CursorBusy_mc");
		AntG.mouse.cursor.play();
		AntG.useSystemCursor = false;
		// Первая кнопка
		var btn : AntButton = AntButton.makeButton("ButtonBasic_mc", "rotate me!", new AntLabel("system", 8, 0x000000));
		btn.reset(100, 200);
		btn.label.applyFilters([new DropShadowFilter(1, 90, 0xFFFFFF, 1, 1, 1, 5)]);
		btn.eventClick.add(onClickMe);
		btn.overCursorAnim = "CursorBusy_mc";
		btn.downCursorAnim = "CursorStop_mc";
		add(btn);
		// Вторая кнопка
		btn = new AntButton();
		btn.addAnimationFromCache("ButtonBlue_mc");
		btn.reset(250, 200);
		btn.smoothing = false;
		btn.eventClick.add(onClickScale);
		btn.overCursorAnim = "CursorBusy_mc";
		add(btn);
		// Третья кнопка
		btn = AntButton.makeButton("ButtonGray_mc", "Not selected", new AntLabel("Verdana", 10, 0x000000, false));
		btn.reset(400, 200);
		btn.toggle = true;
		btn.eventUp.add(onUp);
		btn.eventDown.add(onDown);
		btn.eventOver.add(onOver);
		btn.eventOut.add(onOut);
		btn.eventClick.add(onClick);
		add(btn);
		// Четвертая кнопка
		btn = new AntButton();
		btn.addAnimationFromCache("ButtonVector_mc");
		btn.reset(500, 200);
		add(btn);
		var label : AntLabel = new AntLabel("system", 8, 0x000000);
		label.text = "Текст тоже может вращатся.";
		label.reset(100, 250);
		label.origin.set(label.width * 0.5, label.height * 0.5);
		label.angularAcceleration = 5;
		label.moves = true;
		add(label);
		label = new AntLabel("system", 8, 0x000000);
		label.text = "и изменять размер";
		label.reset(250, 250);
		label.origin.set(label.width * 0.5, label.height * 0.5);
		_labelForScale = label;
		add(label);
		label = new AntLabel("system", 16, 0xFF0000);
		label.text = "?";
		label.reset(350, 230);
		_outputLabel = label;
		add(label);
		label = new AntLabel("Arial", 12, 0x000000, false);
		label.beginChange();
		label.autoSize = false;
		label.text = "Текст может содержать большие и не очень абзацы.

А так же иметь переносы строк и вообще можно делать с текстом все то что можно делать с TextField.

Еще можно просто и быстро подсвечивать слова и словосочетания.";
		label.align = AntLabel.CENTER;
		label.highlightText("TextField", 0xFF0000);
		label.highlightText("слова", 0x00FF00);
		label.highlightText("словосочетания", 0x0000FF);
		label.highlightText("можно", 0xFF00FF);
		label.wordWrap = true;
		label.setSize(300, 200);
		label.endChange();
		label.reset(300, 300);
		add(label);
		var labelInfo : AntLabel = new AntLabel("system");
		labelInfo.reset(15, 15);
		labelInfo.beginChange();
		labelInfo.text = "Demonstration of AntLabel and AntButton.
Previous / next demo: LEFT / RIGHT.";
		labelInfo.highlightText("AntButton", AntColor.RED);
		labelInfo.highlightText("AntLabel", AntColor.RED);
		labelInfo.highlightText("LEFT", AntColor.LIME);
		labelInfo.highlightText("RIGHT", AntColor.LIME);
		labelInfo.setStroke();
		labelInfo.endChange();
		add(labelInfo);
		_isStarted = true;
	}

	/**
	 * @private
	 */
	function onClickMe(aButton : AntButton) : Void {
		aButton.angularAcceleration = 5;
		aButton.moves = !aButton.moves;
	}

	/**
	 * @private
	 */
	function onClickScale(aButton : AntButton) : Void {
		aButton.scaleX = aButton.scaleY = ((aButton.scaleX > 1)) ? 1 : 2;
	}

	/**
	 * @private
	 */
	function onDown(aButton : AntButton) : Void {
		_outputLabel.text = "onDown";
	}

	/**
	 * @private
	 */
	function onUp(aButton : AntButton) : Void {
		_outputLabel.text = "onUp";
	}

	/**
	 * @private
	 */
	function onOver(aButton : AntButton) : Void {
		_outputLabel.text = "onOver";
	}

	/**
	 * @private
	 */
	function onOut(aButton : AntButton) : Void {
		_outputLabel.text = "onOut";
	}

	/**
	 * @private
	 */
	function onClick(aButton : AntButton) : Void {
		aButton.text = ((aButton.selected)) ? "Selected" : "Not selected";
	}

	/**
	 * @private
	 */
	override public function update() : Void {
		if(_isStarted)  {
			_labelForScale.scaleX += _scaleSpeed * AntG.elapsed;
			_labelForScale.scaleY = _labelForScale.scaleX;
			if(_labelForScale.scaleX > 1.5)  {
				_labelForScale.scaleX = 1.5;
				_scaleSpeed *= -1;
			}

			else if(_labelForScale.scaleX < 0.5)  {
				_labelForScale.scaleX = 0.5;
				_scaleSpeed *= -1;
			}
		}
		super.update();
	}

	/**
	 * @private
	 */
	override public function destroy() : Void {
		super.destroy();
	}

}

