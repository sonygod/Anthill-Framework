package ru.antkarlov.anthill.extensions.livinglights
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import ru.antkarlov.anthill.*;
	
	/**
	 * Данный класс служит окружением для источников света. В качестве окружения выступают
	 * какие-либо графические объекты для которых рассчитываются падающие тени.
	 * 
	 * <p>Чтобы создать полноценное окружение, в него следует добавить объекты которые будут
	 * отбрасывать тени и сами источники света. Добавленные в окружение объекты не обрабатываются
	 * и не рендерятся самим окружением, добавленные объекты используются только для создания 
	 * карты теней.</p>
	 * 
	 * <p>Подробно о том как использовать данный класс, читайте здесь:
	 * http://anthill.ant-karlov.ru/wiki/extensions:living_lights</p>
	 * 
	 * @author Anton Karlov (ant.karlov@gmail.com)
	 * @since  21.04.2013
	 * @version 0.1
	 */
	public class AntLightEnvironment extends AntEntity
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Определяет цвет фона который считается прозрачным для карты
		 * окружения.
		 * @default    0xffff00ff (розовый)
		 */
		public var transparentColor:uint;
		
		/**
		 * Список источников света добавленных в окружение.
		 * @default    null
		 */
		public var lights:Array;
		
		/**
		 * Количество источников света добавленных в окружение.
		 * @default    0
		 */
		public var numLights:int;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		protected var _backendBuffer:BitmapData;
		protected var _flashRect:Rectangle;
		protected var _flashPointZero:Point;
		protected var _flashPointTarget:Point;
		
		internal static var NUM_ON_SCREEN:int = 0;
		internal static var NUM_VISIBLE:int = 0;
		internal static var NUM_LIVE:int = 0;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntLightEnvironment()
		{
			super();
						
			transparentColor = 0xffff00ff;

			lights = null;
			numLights = 0;
			
			_flashRect = new Rectangle(0, 0, 0, 0);
			_flashPointZero = new Point();
			_flashPointTarget = new Point();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			if (lights.length > 0)
			{
				var light:AntLight;
				var i:int = 0;
				while (i < numLights)
				{
					light = lights[i++];
					if (light != null)
					{
						light.destroy();
					}
				}
			}
			
			lights = null;
			
			if (_backendBuffer != null) _backendBuffer.dispose();
			_backendBuffer = null;
			
			super.destroy();
		}
		
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет источник света.
		 * 
		 * @param	aLight	 Источник света который необходимо добавить.
		 * @return		Указатель на добавленный источник света.
		 */
		public function addLight(aLight:AntLight):AntLight
		{
			if (lights == null)
			{
				lights = [];
			}
			
			// Если источник света уже добавлен.
			if (lights.indexOf(aLight) > -1)
			{
				return aLight;
			}
			
			// Если источник света уже добавлен в другое окружение.
			if (aLight.environment != null)
			{
				aLight.environment.removeLight(aLight);
			}
			
			aLight.environment = this;
			
			// Ищем пустую ячейку.
			var i:int = 0;
			const n:int = lights.length;
			while (i < n)
			{
				if (lights[i] == null)
				{
					lights[i] = aLight;
					return aLight;
				}
				i++;
			}

			// Добавляем в конец списка.
			lights[n] = aLight;
			numLights++;
			return aLight;
		}
		
		/**
		 * Удаляет источник света из окружения.
		 * 
		 * @param	aLight	 Источник света который необходимо удалить.
		 * @param	aSplice	 Если true то ячейка в списке занимаемая источником света, так же будет удалена.
		 * @return		Указатель на удаленный источник света.
		 */
		public function removeLight(aLight:AntLight, aSplice:Boolean = false):AntLight
		{
			if (lights == null)
			{
				return aLight;
			}

			var i:int = lights.indexOf(aLight);
			if (i < 0 || i >= lights.length)
			{
				return aLight;
			}

			lights[i] = null;
			aLight.environment = null;

			if (aSplice)
			{
				lights.splice(i, 1);
				numLights--;
			}

			return aLight;
		}
		
		/**
		 * Добавляет объект в окружение который должен отбрасывать тень.
		 * 
		 * <p>Внимание: Данный метод идентичен оригинальному методу добавления объекта в сущность,
		 * но с той лишь разницой что объект не становится дочерним объектом окружения,
		 * и не обрабатывается им. Добавленный в окружение объект используется только для
		 * получения его маски и рассчета теней. Чтобы объект обрабатывался и отрисовывался
		 * его необходимо добавить в любую обычную сущность включенную в структуру обработки.</p>
		 * 
		 * @param	aEntity	 Любая графическая сущность которая должна отбрасывать тень.
		 */
		override public function add(aEntity:AntEntity):AntEntity
		{	
			// Если сущность не имела детей.
			if (children == null)
			{
				children = [];
			}

			// Если сущность уже добавлена.
			if (children.indexOf(aEntity) > -1)
			{
				return aEntity;
			}

			// Ищем пустую ячейку.
			var i:int = 0;
			const n:int = children.length;
			while (i < n)
			{
				if (children[i] == null)
				{
					children[i] = aEntity;
					return aEntity;
				}
				i++;
			}

			// Добавляем в конец массива детей.
			children[n] = aEntity;
			numChildren++;
			return aEntity;
		}
		
		/**
		 * Проверяет является ли пиксель непрозрачным.
		 * 
		 * @param	aX	 Координаты пикселя по X.
		 * @param	aY	 Координаты пикселя по Y.
		 * @return		Возвращает true если пиксель в указанных координатах непрозрачен.
		 */
		public function isOpaque(aX:int, aY:int):Boolean
		{
			if (_backendBuffer == null)
			{
				return true;
			}
			
			if (aX < 0 || aX > _backendBuffer.width ||
				aY < 0 || aY > _backendBuffer.height)
			{
				return false;
			}
			
			return (getColor(_backendBuffer.getPixel(aX, aY)) != getColor(transparentColor));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			/*
				В окружении вложенные объекты не обновляются, 
				так как они используются только для создания 
				карты объектов.
			*/
			
			updateLights();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw(aCamera:AntCamera):void
		{
			// Обновляем буфер если необходимо.
			if (_backendBuffer == null)
			{
				_backendBuffer = new BitmapData(aCamera.buffer.width, aCamera.buffer.height, true, transparentColor);
			}
			else if (_backendBuffer.width != aCamera.buffer.width || _backendBuffer.height != aCamera.buffer.height)
			{
				_backendBuffer.dispose();
				_backendBuffer = new BitmapData(aCamera.buffer.width, aCamera.buffer.height, true, transparentColor);
			}
			
			// Отрисовываем окружение для рассчета источников света.
			_flashRect.width = _backendBuffer.width;
			_flashRect.height = _backendBuffer.height;
			_backendBuffer.lock();
			_backendBuffer.fillRect(_flashRect, transparentColor);
			var camBuff:BitmapData = aCamera.buffer;
			aCamera.buffer = _backendBuffer;
			drawChildren(aCamera);
			
			// Расскомментируйте эту строку чтобы увидеть карту объектов для рассчета теней.
			//camBuff.copyPixels(_backendBuffer, _flashRect, _flashPointTarget, null, null, true);
			
			aCamera.buffer = camBuff;
			_backendBuffer.unlock();

			drawLights(aCamera);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function debugDraw(aCamera:AntCamera):void
		{
			super.debugDraw(aCamera);
			
			// Отрисовка света.
			if (lights != null)
			{
				var i:int = 0;
				var light:AntLight;
				while (i < numLights)
				{
					light = lights[i++] as AntLight;
					if (light != null && light.exists && 
						light.visible && light.allowDebugDraw)
					{
						light.debugDraw(aCamera);
					}
				}
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Обновляет источники света.
		 */
		protected function updateLights():void
		{
			if (_backendBuffer == null)
			{
				return;
			}
			
			NUM_LIVE = 0;
			var light:AntLight;
			var i:int = 0;
			while (i < numLights)
			{
				light = lights[i++] as AntLight;
				if (light != null && light.exists)
				{
					light.update();
					light.bake();
				}
			}
		}
		
		/**
		 * Рисует источники света в указанную камеру.
		 * 
		 * @param	aCamera	 Указатель на камеру в которую будут отрисованы источники света.
		 */
		protected function drawLights(aCamera:AntCamera):void
		{
			NUM_VISIBLE = 0;
			NUM_ON_SCREEN = 0;
			var light:AntLight;
			var i:int = 0;
			while (i < numLights)
			{
				light = lights[i++] as AntLight;
				if (light != null && light.exists && light.visible)
				{
					NUM_VISIBLE++;
					light.draw(aCamera);
				}
			}
		}
		
		/**
		 * Извлекает сумму RGB без учета альфы из указанного цвета.
		 */
		protected function getColor(aColor:uint):int
		{
			return ((aColor >> 16) & 0xFF) + ((aColor >> 8) & 0xFF) + (aColor & 0xFF);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает количество видимых источников света.
		 */
		public function get numVisible():int
		{
			return NUM_VISIBLE;
		}
		
		/**
		 * Возвращает количество источнико света которые видны на экране.
		 */
		public function get numOnScreen():int
		{
			return NUM_ON_SCREEN;
		}
		
		/**
		 * @private
		 */
		public function get numLive():int
		{
			return NUM_LIVE;
		}
		
	}

}