//import ru.antkarlov.anthill.debug.AntDrawer;
/**
 * Демонстрация работы менеджера задач.
 * 
 * ВНИМАНИЕ: Данный пример лишь демонстрирует как работает мендежр задач, и реализация
 * управления юнитами не является идеально. При разработки игр, героев и юнитов
 * следует выносить в отдельные классы и там описывать их логику, так как это является
 * более гибким и удобным решением.
 * 
 * Например, в данном примере было бы интересно сделать много героев воюющих с крестьянинами,
 * но в рамках одного класса это достаточно сложно реализовать.
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
import ru.antkarlov.anthill.plugins.AntTaskManager;
using Reflect;
class TestTaskManager extends AntState {

	var _isStarted : Bool;
	var _hero : AntActor;
	// Указатель на супер героя.
	var _heroTargetPoint : AntPoint;
	// Точка куда бежит супер герой когда нет врагов.
	var _tm : AntTaskManager;
	// Менеджер управляющий поведением супер героя.
	var _tmSpawner : AntTaskManager;
	// Менеджер управляющий спавном врагов.
	var _tmPrint : AntTaskManager;
	// Менеджер печатающий текст.
	var _backgroundLayer : AntEntity;
	// Группа с тайлами заднего фона.
	var _currentEnemy : AntActor;
	// Указатель на врага которого хочет атаковать наш супер герой.
	var _labelInfo : AntLabel;
	var _printText : String;
	// Текст который будет печататься.
	var _printIndex : Int;
	// Индекс текущего пичатаемого символа.
	/**
	 * @constructor
	 */
	public function new() {
		_isStarted = false;
		super();
	}

	/**
	 * @inheritDoc
	 */
	override public function create() : Void {
		// Добавляем классы клипов которые необходимо растеризировать.
		var loader : AntAssetLoader = new AntAssetLoader();
		var arr : Vector<Class<Dynamic>> = new Vector<Class<Dynamic>>();
		arr=Vector.ofArray([Type.resolveClass('BackgroundGrass_mc'), Type.resolveClass('InfantryAttack_mc'), Type.resolveClass('InfantryWalk_mc'), Type.resolveClass('PeasantAttack_mc'), Type.resolveClass('PeasantWalk_mc')]);
		loader.addClips(arr);
		// Добавляем обработчик для завершения процесса растеризации.
		loader.eventComplete.add(onCacheComplete);
		// Запускаем процесс растеризации клипов.
		loader.start();
		// Очищаем монитор.
		/*	AntG.debugger.monitor.clear();
		
		// Показываем отладчик.
		AntG.debugger.show();
		
		// Показываем монитор.
		AntG.debugger.monitor.show();
		
		// Все остальное скрываем.
		AntG.debugger.console.hide();
		AntG.debugger.perfomance.hide();*/
		//AntG.setDebugDraw(new AntDrawer());
		super.create();
	}

	/**
	 * Обработчик события завершения растеризации.
	 */
	function onCacheComplete(aLoader : AntAssetLoader) : Void {
		aLoader.destroy();
		_backgroundLayer = new AntEntity();
		add(_backgroundLayer);
		//AntG.track(_backgroundLayer, "backgound entity");
		var dx : Int = 0;
		var dy : Int = 0;
		var bgTile : AntActor;
		var i : Int = 0;
		while(i < 6) {
			bgTile = new AntActor();
			bgTile.addAnimationFromCache("BackgroundGrass_mc");
			bgTile.x = dx;
			bgTile.y = dy;
			_backgroundLayer.add(bgTile);
			dx += Std.int(bgTile.width - 4);
			if(i == 2)  {
				dy += Std.int(bgTile.height - 4);
				dx = 0;
			}
			i++;
		}
		// Создаем класс героя.
		_hero = new AntActor();
		// Добавляем в героя анимации атаки и хотьбы.
		_hero.addAnimationFromCache("InfantryAttack_mc", "attack", false);
		_hero.addAnimationFromCache("InfantryWalk_mc", "walk");
		// Устанавливаем героя в центр экрана.
		_hero.x = AntG.widthHalf;
		_hero.y = AntG.heightHalf;
		// Скорость анимации героя.
		_hero.animationSpeed = 0.5;
		// Добавляем героя в структуру.
		add(_hero);
		/* Создаем менеджер задач который будет управлять героем.
		Флаг true в конструкторе менеджера означает что задачи выполняются по кругу. */
		_tm = new AntTaskManager(true);
		// Добавляем задачу которая выполняется один раз за цикл.
		_tm.addInstantTask(onSelectNextPoint);
		/* Добавляем обычную задачу которая будет выполнятся до тех пор пока указанный 
		метод не вернет true. */
		_tm.addTask(onHeroMove);
		/* Добавляем паузу в конец списка задач, эта пауза создает задержку прежде чем 
		менеджер перейдет вновь к первой задачи. Таким образом мы получим эффект того,
		что персонаж будет останавливатся прежде чем побежит к новой точке (если конечно 
		он слоняется без дела). */
		_tm.addPause(0.5);
		// Создаем менеджер задач который будет создавать новых врагов с заданным интервалом.
		_tmSpawner = new AntTaskManager(true);
		// Добавляем задачу которая выполняется один раз за цикл.
		_tmSpawner.addInstantTask(onPeasantSpawn);
		// Добавляем паузу прежде чем перейдем к новому циклу.
		_tmSpawner.addPause(3);
		/* Далее демонстрация того как менджер задач можно использовать в других целях,
		например напечатаем текст как печатной машинкой. */
		_printText = "Demonstration of AntTaskManager.
Previous / next demo: LEFT / RIGHT.";
		_printIndex = 0;
		// Инициализация текстовой метки.
		_labelInfo = new AntLabel("system");
		_labelInfo.x = 15;
		_labelInfo.y = 15;
		_labelInfo.setStroke();
		// Добавляем метку в структуру.
		add(_labelInfo);
		// Менеджер задач который будет печатать текст.
		_tmPrint = new AntTaskManager();
		// Добавляем задачу - указатель на метод который будет добавлять в метку по одной букве.
		_tmPrint.addTask(onPrintText);
		/* Примечание: Задача будет выполняться каждый кадр пока метод не вернет true. */
		// Ставим флаг что можно приступать к игровой обработке.
		_isStarted = true;
	}

	/**
	 * Метод который печатает по одной букве в текстовую метку.
	 */
	function onPrintText() : Bool {
		// Добавляем текущую букву в текст.
		_labelInfo.text += _printText.charAt(_printIndex);
		// Увеличиваем индекс текущей буквы.
		_printIndex++;
		// Если индекс равен общему количеству символов, то...
		if(_printIndex == _printText.length)  {
			// Расскрашиваем отдельные слова в нужный нам цвет.
			_labelInfo.highlightText("AntTaskManager", AntColor.RED);
			_labelInfo.highlightText("RIGHT", AntColor.LIME);
			_labelInfo.highlightText("LEFT", AntColor.LIME);
			// Завершаем работу задачи.
			return true;
		}
		return false;
	}

	/**
	 * Метод который выбирает следущую точку для нашего героя.
	 * Следущей точкой может быть ближайший враг либо просто случайное положение, 
	 * если нет врагов.
	 */
	function onSelectNextPoint() : Void {
		// Инициализация точки случайного положения.
		if(_heroTargetPoint == null)  {
			_heroTargetPoint = new AntPoint();
		}
		var dist : Array<Dynamic> = [];
		// Указатель на врага необходим при переборе всех врагов.
		var enemy : AntActor;
		// Перебераем все игровые объекты.
		var i : Int = 0;
		while(i < defGroup.numChildren) {
			enemy = try cast(defGroup.children[i], AntActor) catch(e:Dynamic) null;
			// Извлекаем текущего врага.
			// Если не пустая ячейка и враг существует, и вообще это именно враг то...
			if(enemy != null && enemy.exists && enemy.tag == 666)  {
				// Записываем указатель на врага и дистанцию до героя в список врагов.
				dist[dist.length] = {
					unit : enemy,
					dist : AntMath.distance(_hero.x, _hero.y, enemy.x, enemy.y),

				};
			}
			i++;
		}
		// Если в списке врагов есть записи...
		if(dist.length > 0)  {
			// То сортируем список по дистанции, с наименьшей дистанцией вперед.
			//dist.sortOn("dist", Array.DESCENDING);
			dist.callMethod(dist.field("sorton"), [untyped __global__['Array'].DESCENDING]);
			// Берем врага с самой маленькой дистанцией до героя как текущую цель.
			_currentEnemy = dist[0].unit;
			// Рассчитываем угол на врага.
			_hero.angle = AntMath.angleDeg(_hero.x, _hero.y, _currentEnemy.x, _currentEnemy.y);
			// Рассчитываем векторную скорость на врага.
			_hero.velocity.set(100 * Math.cos(AntMath.toRadians(_hero.angle)), 100 * Math.sin(AntMath.toRadians(_hero.angle)));
		}

		else  {
			// Иначе врагов не оказалось и берем случайную точку в пределах экрана.
			_heroTargetPoint.set(AntMath.randomRangeInt(100, AntG.width - 100), AntMath.randomRangeInt(100, AntG.height - 100));
			// Рассчитываем угол на точку.
			_hero.angle = AntMath.angleDeg(_hero.x, _hero.y, _heroTargetPoint.x, _heroTargetPoint.y);
			// Рассчитываем векторную скорость на точку.
			_hero.velocity.set(100 * Math.cos(AntMath.toRadians(_hero.angle)), 100 * Math.sin(AntMath.toRadians(_hero.angle)));
		}

		// Активируем возможности движения.
		_hero.moves = true;
		// Переключаем анимацию на анимацию хотьбы.
		_hero.switchAnimation("walk");
		// Запускаем проигрывание анимации.
		_hero.play();
	}

	/**
	 * Метод который выполняется все время пока герой двигается,
	 * данный метод не выполняет движения героя, так как для этого используются
	 * стандартные возможности AntActor. Метод лишь проверят не достиг ли наш
	 * герой своей цели.
	 */
	function onHeroMove() : Bool {
		// Список всех врагов чтобы отсортировать их по дистанции.
		var dist : Array<Dynamic> = [];
		// Указатель на врага необходим при переборе всех врагов.
		var enemy : AntActor;
		// Перебераем все игровые объекты.
		var i : Int = 0;
		while(i < defGroup.numChildren) {
			enemy = try cast(defGroup.children[i], AntActor) catch(e:Dynamic) null;
			// Извлекаем текущего врага.
			// Если не пустая ячейка и враг существует, и вообще это именно враг то...
			if(enemy != null && enemy.exists && enemy.tag == 666)  {
				// Записываем указатель на врага и дистанцию до героя в список врагов.
				dist[dist.length] = {
					unit : enemy,
					dist : AntMath.distance(_hero.x, _hero.y, enemy.x, enemy.y),

				};
			}
			i++;
		}
		// Если в списке врагов есть записи...
		if(dist.length > 0 && _currentEnemy != null)  {
			// То сортируем список по дистанции, с наименьшей дистанцией вперед.
			//dist.sortOn("dist", Array.DESCENDING);
			dist.callMethod(dist.field("sorton"), [untyped __global__['Array'].DESCENDING]);
			// Если враг с самой маленькой дистанцией до героя имеет меньшую дистанцию чем текущий враг...
			if(AntMath.distance(_hero.x, _hero.y, dist[0].unit.x, dist[0].unit.y) < AntMath.distance(_hero.x, _hero.y, _currentEnemy.x, _currentEnemy.y))  {
				// То ставим текущей целью нового врага с наименьшей дистанцией до героя.
				_currentEnemy = dist[0].unit;
			}
		}
		if(_currentEnemy != null)  {
			// Нацеливаем героя на врага.
			_hero.angle = AntMath.angleDeg(_hero.x, _hero.y, _currentEnemy.x, _currentEnemy.y);
			// И устанавливаем векторную скорость чтобы двигаться к врагу.
			_hero.velocity.set(100 * Math.cos(AntMath.toRadians(_hero.angle)), 100 * Math.sin(AntMath.toRadians(_hero.angle)));
			// Проверяем оставшуюся дистанцию до врага, если она меньше заданного, то...
			if(AntMath.distance(_currentEnemy.x, _currentEnemy.y, _hero.x, _hero.y) < 15)  {
				// Добавляем в начало списка срочную задачу атаки.
				_tm.addUrgentTask(onHeroAttack, null, true);
				/*
				Примечание: Последний флаг true означает что данная задача будет игнорировать цикличность менеджера задач,
				и будет удалена из менеджера после успешного своего завершения. 
				*/
			}
		}

		else  {
			// Иначе просто двигаемся к указанной точке и проверяем достижение этой точки...
			if(AntMath.equal(_hero.x, _heroTargetPoint.x, 1) && AntMath.equal(_hero.y, _heroTargetPoint.y, 1))  {
				// Если точка достигнута, то останавливаем движение и анимация.
				_hero.moves = false;
				_hero.stop();
				// Задача успешно выполнена, и менеджер задач перейдет к следующей задачи.
				return true;
				/* В нашем случае менеджер задач прейдет к паузе, а потом начнет новый цикл и перейде к первой 
				добавленной в него задачи, то есть через заданную паузу герой получит новую точку и пойдет к ней. */
			}
		}

		return false;
	}

	/**
	 * Метод выполняющий атаку героем.
	 * Выполняется до тех пока не закончится проигрывание текущей анимации.
	 */
	function onHeroAttack() : Bool {
		/* Если текущая анимация героя не равна анимации атаки, и есть цель для атаки, а
		так же дистанция до врага позволяет нанести удар, то... */
		if(_hero.currentAnimation != "attack" && _currentEnemy != null && AntMath.distance(_hero.x, _hero.y, _currentEnemy.x, _currentEnemy.y) < 15)  {
			// Разворачиваем героя лицом к врагу.
			_hero.angle = AntMath.angleDeg(_hero.x, _hero.y, _currentEnemy.x, _currentEnemy.y) - 90;
			// Останавливаем движение героя.
			_hero.moves = false;
			// Включаем анимацию атаки.
			_hero.switchAnimation("attack");
		}
		if(_hero.currentFrame == _hero.totalFrames)  {
			/*
			Примечание: По идеи анимация заканчивается когда герой уже отвел свое копье в обычное положение,
			поэтому обычно следует проверять удар на конкретный кадр где-то в середине анимации, чтобы нанесение
			урона соотвествовало максимальному выпаду компья героя. 
			*/
			// Наносим случайный урон текущему врагу в виде случайного значения :)
			_currentEnemy.hurt(AntMath.randomRangeNumber(0.25, 0.8));
			// Если цель мертва, то...
			if(!_currentEnemy.alive)  {
				// Зануляем указатель на цель и переходим вызываем метод поиска следующей цели.
				_currentEnemy = null;
				onSelectNextPoint();
				// Задача атаки считается завершенным.
				return true;
			}
		}
		return false;
	}

	/**
	 * Метод который вызывается независимым менеджером задач и создает новых врагов.
	 */
	function onPeasantSpawn() : Void {
		/* Используем метод переработки который позволяет получить ранее убитых врагов 
		или создаст нового если убитых нет. */
		var peasant : AntActor = try cast(defGroup.recycle(AntActor), AntActor) catch(e:Dynamic) null;
		// Если крестьянин был ранее убит, то...
		if(!peasant.exists)  {
			// Воскрешаем его.
			peasant.revive();
			peasant.health = 1;
		}

		else  {
			// Иначе крестьянин является новым объектом, настраиваем его как нового.
			// Добавляем анимации атаки и хотьбы.
			peasant.addAnimationFromCache("PeasantAttack_mc", "attack", false);
			peasant.addAnimationFromCache("PeasantWalk_mc", "walk");
			// Магическое число обозначающее для нашего героя что этот юнит вражеский.
			peasant.tag = 666;
			// Устанавливаем скорость анимации и запускаем проигрывание.
			peasant.animationSpeed = 0.5;
			peasant.play();
			// Разворачиваем нового врага в сторону героя.
			peasant.angle = AntMath.angleDeg(peasant.x, peasant.y, _hero.x, _hero.y);
			// Устанавливаем векторную скорость крестьянина чтобы он бежал к герою.
			peasant.velocity.set(80 * Math.cos(AntMath.toRadians(peasant.angle)), 80 * Math.sin(AntMath.toRadians(peasant.angle)));
			peasant.moves = true;
			// Добавляем крестьянину менеджер задач который будет управлять им.
			peasant.userData = new AntTaskManager(true);
			//AntG.track(peasant.userData);
		}

		// Устанавливаем новое положение врага где-то случайно на экране.
		peasant.reset(AntMath.randomRangeInt(0, AntG.width), AntMath.randomRangeInt(0, AntG.height));
		// Извлекаем указатель на менеджер задач для крестьянина.
		var tm : AntTaskManager = try cast(peasant.userData, AntTaskManager) catch(e:Dynamic) null;
		if(tm != null)  {
			// И добавляем в менеджер задачи кторые будут управлять крестьянином.
			tm.addTask(onPeasantMove, [peasant]);
			tm.addTask(onPeasantAttack, [peasant]);
			tm.addInstantTask(onPeasantDie, [peasant]);
			/* Информация: в методы-задачи могут быть переданы любые аргументы которые указываются массивом.
			Аргументы будут передаваться в методы каждый раз при выполнении. */
		}
	}

	/**
	 * Метод задача который выполняется каждый кадр пока крестьянин двигается.
	 * Метод не выполняет движение крестьянина, так как для этого используются стандартные
	 * средства класса AntActor. Метод лишь проверяет не достиг ли враг своей цели.
	 */
	function onPeasantMove(aPeasant : AntActor) : Bool {
		// Нацеливаемся на героя.
		aPeasant.angle = AntMath.angleDeg(aPeasant.x, aPeasant.y, _hero.x, _hero.y);
		// Рассчитываем векторную скорость исходя из текущего разворота.
		aPeasant.velocity.set(80 * Math.cos(AntMath.toRadians(aPeasant.angle)), 80 * Math.sin(AntMath.toRadians(aPeasant.angle)));
		// Если дистанция до героя меньше заданной, то...
		if(AntMath.distance(aPeasant.x, aPeasant.y, _hero.x, _hero.y) < 15)  {
			// Задаца успешно выполнена и можно переходить к следующей задачи, к атаке!
			return true;
		}
		return false;
	}

	/**
	 * Метод атаки крестьянина.
	 * Выполняется до тех пор пока не будет закончено проигрывание текущей анимации.
	 */
	function onPeasantAttack(aPeasant : AntActor) : Bool {
		// Если текущаяя анимация не является атакой и дистанция до героя позволяет нанести удар, то...
		if(aPeasant.currentAnimation != "attack" && AntMath.distance(aPeasant.x, aPeasant.y, _hero.x, _hero.y) < 15)  {
			// Останавливаемся и включаем анимацию атаки.
			aPeasant.moves = false;
			aPeasant.switchAnimation("attack");
		}
		if(aPeasant.currentFrame == aPeasant.totalFrames)  {
			/*
			Примечание: По идеи анимация заканчивается когда враг уже отвел свои вилы в обычное положение,
			поэтому обычно следует проверять удар на конкретный кадр где-то в середине анимации, чтобы нанесение
			урона соотвествовало максимальному выпаду вил врага. 
			*/
			// Если дистанция больше той которая позволяет нанести урон, то промахнулись - герой убежал.
			if(AntMath.distance(aPeasant.x, aPeasant.y, _hero.x, _hero.y) > 15)  {
				// Нацеливаемся на героя.
				aPeasant.angle = AntMath.angleDeg(aPeasant.x, aPeasant.y, _hero.x, _hero.y);
				// И рассчитываем векторную скорость чтобы догнать его.
				aPeasant.velocity.set(80 * Math.cos(AntMath.toRadians(aPeasant.angle)), 80 * Math.sin(AntMath.toRadians(aPeasant.angle)));
				// Включаем движение и переключаемся на анимацию хотьбы.
				aPeasant.moves = true;
				aPeasant.switchAnimation("walk");
				return true;
			}

			else  {
				// Иначе герой в пределах удара, и мы можем нанести ему урон.
				// Но в данном примере герой бессмертный! :)
				//_hero.hurt(0.02);
			}

		}
		return false;
	}

	/**
	 * Этот метод просто проверяет не погиб ли владелец этого менеджера задач чтобы не работать в холостую.
	 */
	function onPeasantDie(aPeasant : AntActor) : Void {
		// Если враг погиб, то...
		if(!aPeasant.alive)  {
			// Удаляем все задачи из менеджера задач.
			var tm : AntTaskManager = try cast(aPeasant.userData, AntTaskManager) catch(e:Dynamic) null;
			if(tm != null)  {
				tm.clear();
			}
		}
	}

	/**
	 * @private
	 */
	override public function postUpdate() : Void {
		if(_isStarted)  {
			/*AntG.beginWatch();
			AntG.watchValue("numDead", defGroup.numDead());
			AntG.watchValue("numLiving", defGroup.numLiving());
			AntG.watchValue("tasks", _tm.numTasks);
			AntG.watchValue("hero x", _hero.globalX);
			AntG.watchValue("hero depth", _hero.depth);
			AntG.endWatch();*/
		}
	}

	/**
	 * @private
	 */
	override public function destroy() : Void {
		_isStarted = false;
		_tm.clear();
		_tm = null;
		var actor : AntActor;
		var i : Int = 0;
		while(i < defGroup.numChildren) {
			actor = try cast(defGroup.children[i], AntActor) catch(e:Dynamic) null;
			if(actor != null && Std.is(actor.userData, AntTaskManager))  {
				(try cast(actor.userData, AntTaskManager) catch(e:Dynamic) null).clear();
				actor.userData = null;
			}
			i++;
		}
		_tmSpawner.clear();
		_tmSpawner = null;
		_tmPrint.clear();
		_tmPrint = null;
		super.destroy();
	}

}

