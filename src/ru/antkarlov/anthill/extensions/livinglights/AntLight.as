package ru.antkarlov.anthill.extensions.livinglights
{
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import ru.antkarlov.anthill.*;
/**
	 * Данный класс реализует простой источник света. Чтобы созданный источник света
	 * корректно обрабатывался и рендерился, его следует добавлять только в световое окружение
	 * AntLightEnvironment.
	 * 
	 * <p>Внимание: Источник света поддерживает вложение объектов, но данная возможность не тестировалась.</p>
	 * 
	 * <p>Подробно о том как использовать данный класс, читайте здесь:
	 * http://anthill.ant-karlov.ru/wiki/extensions:living_lights</p>
	 * 
	 * @author Anton Karlov (ant.karlov@gmail.com)
	 * @since  21.04.2013
	 * @version 0.1
	 */
	public class AntLight extends AntEntity
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		protected static const INDENT_FOR_FILTER:int = 64;
		protected static const INDENT_FOR_FILTER_DOUBLED:int = INDENT_FOR_FILTER * 2;
		protected static const DEST_POINT:Point = new Point();
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Определяет режим смешивания цветов для отрисовки источника цвета.
		 * 
		 * <p>Режим смешивания существенно снижает скорость отрисовки. Чтобы отключить
		 * режим смешивания, установите <code>null</code>.</p>
		 * 
		 * @default    "overlay"
		 */
		public var blend:String;
		
		/**
		 * Определяет является ли источник света динамическим (рассчитывается постоянно).
		 * 
		 * <p>Динамические источники света отнимают большой процент производительности.
		 * Для недвижимых источников света рекомендуется устанавливать <code>live = false</code>,
		 * но в этом случае перемещающиеся возле них объекты, не будут отбрасывать тени.</p>
		 * 
		 * @default    true
		 */
		public var live:Boolean;
		
		/**
		 * Угловой шаг для рассчета источника света.
		 * 
		 * <p>Чем больше шаг, тем ниже качество рассчета тени и выше производительность.
		 * Для статических источников света можно использовать шаг в 1 для получения наиболее
		 * точных теней.</p>
		 * 
		 * @default    10
		 */
		public var angleStep:Number;
		
		/**
		 * Лучевой шаг для рассчета источника света.
		 * 
		 * <p>Чем больше шаг, тем ниже качество рассчета тени и выше производительность.
		 * Для статических источников света можно использовать шаг в 1 для получения наиболее
		 * точных теней.</p>
		 * 
		 * @default    5
		 */
		public var rayStep:Number;
		
		/**
		 * Временная задержка между итерациями рассчета источника цвета.
		 * 
		 * <p>Для динамических источников света рекомендуется задержка от 0.05 до 0.1. 
		 * Чем выше задержка, тем больше производительность, но ниже качество источника света.</p>
		 * 
		 * @default    0
		 */
		public var updateInterval:Number;
		
		/**
		 * Прозрачность источника света.
		 * @default    1
		 */
		public var alpha:Number;
		
		/**
		 * Указатель на окружение в которое добавлен источник света.
		 * @default    null
		 */
		public var environment:AntLightEnvironment;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		protected var _radius:Number;
		protected var _lowerAngle:Number;
		protected var _upperAngle:Number;
		protected var _ratio:Array;
		protected var _blur:AntPoint;
		protected var _p:AntPoint;
		
		protected var _flashSprite:Sprite;
		protected var _flashPoint:Point;
		protected var _flashRect:Rectangle;
		protected var _clearRect:Rectangle;
		protected var _flashMatrix:Matrix;
		protected var _pixels:BitmapData;
		protected var _scratchBitmapData:BitmapData;
		
		protected var _colors:Array;
		protected var _alphas:Array;
		
		protected var _isBacked:Boolean;
		protected var _delay:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntLight()
		{
			super()
			
			blend = "overlay";
			live = true;
			angleStep = 10;
			rayStep = 5;
			alpha = 1;
			updateInterval = 0;
			
			_radius = 300;
			_lowerAngle = 0;
			_upperAngle = 360;
			_ratio = [ 100, 255 ];
			_blur = new AntPoint(10, 10);
			_p = new AntPoint(0, 0);
			
			_flashSprite = new Sprite();
			_flashSprite.filters = [ new BlurFilter(_blur.x, _blur.y, 2) ];
			_flashPoint = new Point();
			_flashRect = new Rectangle();
			_clearRect = new Rectangle();
			_flashMatrix = new Matrix();
			
			_colors = [ 0xFFFF83, 0xFFFFFF ];
			_alphas = [ alpha, 0 ];
			
			_isBacked = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			if (environment != null)
			{
				environment.removeLight(this);
			}
			
			_flashSprite.filters = null;
			_flashSprite = null;
			
			if (_pixels != null) _pixels.dispose();
			if (_scratchBitmapData != null) _scratchBitmapData.dispose();
			_pixels = null;
			_scratchBitmapData = null;
			
			super.destroy();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function draw(aCamera:AntCamera):void
		{
			updateBounds();
			drawLight(aCamera);
		}
		
		/**
		 * Рассчитывает источник света.
		 */
		public function bake():void
		{
			if (live || !_isBacked)
			{
				AntLightEnvironment.NUM_LIVE++;
				_delay += 2 * AntG.elapsed;
				if (_delay <= updateInterval)
				{
					return;
				}
				
				_delay = 0;
				_flashSprite.graphics.clear();
				_alphas[0] = alpha;
				_flashMatrix.identity();
				_flashMatrix.createGradientBox(radius, radius, 0, radius * -0.5, radius * -0.5);
				_flashSprite.graphics.beginGradientFill(GradientType.RADIAL, _colors, _alphas, _ratio, _flashMatrix);
				_flashSprite.graphics.moveTo(0, 0);
				
				var px:Number;
				var py:Number;
				var j:int = _lowerAngle + angle;
				var q:int = 0;
				const n:int = _upperAngle + angle;
				while (j <= n)
				{	
					while (q < _radius)
					{
						px = x + q * Math.cos(j * Math.PI / 180);
						py = y + q * Math.sin(j * Math.PI / 180);
						
						toScreenPosition(px, py, null, _p);
						if (environment.isOpaque(_p.x, _p.y))
						{
							_flashSprite.graphics.lineTo(px - x, py - y);
							break;
						}

						if (q >= (_radius - rayStep))
						{
							_flashSprite.graphics.lineTo(px - x, py - y);
							break;
						}
						q += rayStep;
					}
					
					q = 0;
					j += angleStep;
				}
				
				_isBacked = true;
				makeCache();
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Отрисовывает источник света в указанную камеру.
		 * 
		 * @param	aCamera	 Камера в которую будет отрисован источник света.
		 */
		protected function drawLight(aCamera:AntCamera):void
		{
			if (_pixels == null || !onScreen(aCamera))
			{
				return;
			}
			
			AntLightEnvironment.NUM_ON_SCREEN++;
			getScreenPosition(aCamera, _p);
			_flashPoint.x = _p.x + origin.x;
			_flashPoint.y = _p.y + origin.y;
			_flashRect.x = _flashRect.y = 0;
			_flashRect.width = _pixels.width;
			_flashRect.height = _pixels.height;

			if (blend == null)
			{
				aCamera.buffer.copyPixels(_pixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			{
				_flashMatrix.identity();
				_flashMatrix.translate(origin.x, origin.y);
				_flashMatrix.translate(_flashPoint.x - origin.x, _flashPoint.y - origin.y);
				aCamera.buffer.draw(_pixels, _flashMatrix, null, blend, null, false);
			}
		}
		
		/**
		 * Создает растровую копию источника света.
		 */
		protected function makeCache():void
		{
			var flooredX:int;
			var flooredY:int;

			_flashRect = _flashSprite.getBounds(_flashSprite);
			_flashRect.width = Math.ceil(_flashRect.width) + INDENT_FOR_FILTER_DOUBLED;
			_flashRect.height = Math.ceil(_flashRect.height) + INDENT_FOR_FILTER_DOUBLED;

			flooredX = Math.floor(_flashRect.x) - INDENT_FOR_FILTER;
			flooredY = Math.floor(_flashRect.y) - INDENT_FOR_FILTER;
			_flashMatrix.identity();
			_flashMatrix.tx = -flooredX;
			_flashMatrix.ty = -flooredY;
			
			if (_scratchBitmapData == null || 
				(_scratchBitmapData != null && (_scratchBitmapData.width < _flashRect.width ||
				_scratchBitmapData.height < _flashRect.height)))
			{
				if (_scratchBitmapData != null) _scratchBitmapData.dispose();
				_scratchBitmapData = new BitmapData(_flashRect.width, _flashRect.height, true, 0);
			}
			else
			{
				_clearRect.width = _scratchBitmapData.width;
				_clearRect.height = _scratchBitmapData.height;
				_scratchBitmapData.fillRect(_clearRect, 0x00FFFFFF);
			}
			
			_scratchBitmapData.draw(_flashSprite, _flashMatrix);

			var trimBounds:Rectangle = _scratchBitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			trimBounds.x -= 1;
			trimBounds.y -= 1;
			trimBounds.width += 2;
			trimBounds.height += 2;
			
			if ((_pixels == null) || 
				(_pixels != null && (_pixels.width < trimBounds.width || _pixels.height < trimBounds.height)))
			{
				if (_pixels != null) _pixels.dispose();
				_pixels = new BitmapData(trimBounds.width, trimBounds.height, true, 0);
			}
			else
			{
				_clearRect.width = _pixels.width;
				_clearRect.height = _pixels.height;
				_pixels.fillRect(_clearRect, 0x00FFFFFF);
			}
			
			_pixels.copyPixels(_scratchBitmapData, trimBounds, DEST_POINT);
			
			flooredX += trimBounds.x;
			flooredY += trimBounds.y;
			
			origin.x = flooredX;
			origin.y = flooredY;

			width = (width < trimBounds.width) ? trimBounds.width : width;
			height = (height < trimBounds.height) ? trimBounds.height : height;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет радиус источника света.
		 * @default    300
		 */
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void
		{
			_radius = value;
			_isBacked = false;
		}
		
		/**
		 * Определяет наименьший угол источника света.
		 * @default    0
		 */
		public function get lowerAngle():Number { return _lowerAngle; }
		public function set lowerAngle(value:Number):void
		{
			_lowerAngle = value;
			_isBacked = false;
		}
		
		/**
		 * Определяет наибольший угол источника света.
		 * @default    360
		 */
		public function get upperAngle():Number { return _upperAngle; }
		public function set upperAngle(value:Number):void
		{
			_upperAngle = value;
			_isBacked = false;
		}
		
		/**
		 * Определяет начальный цвет источника света (точка горения).
		 * @default    0xFFFF83
		 */
		public function get colorIn():uint { return _colors[0]; }
		public function set colorIn(value:uint):void
		{
			_colors[0] = value;
			_isBacked = false;
		}
		
		/**
		 * Определяет конечный цвет источника света (затухание).
		 * @default    0xFFFFFF
		 */
		public function get colorOut():uint { return _colors[1]; }
		public function set colorOut(value:uint):void
		{
			_colors[1] = value;
			_isBacked = false;
		}
		
		/**
		 * Определяет интенсивность источника света.
		 * @default    100
		 */
		public function get ratio():int { return _ratio[0]; }
		public function set ratio(value:int):void
		{
			_ratio[0] = (value < 0) ? 0 : (value > 255) ? 255 : value;
			_isBacked = false;
		}
		
		/**
		 * Определяет сглаживание источника света.
		 * 
		 * <p>Чтобы отключить сглаживание, установите (0,0).</p>
		 * 
		 * @default    (10,10)
		 */
		public function get blur():AntPoint { return new AntPoint(_blur.x, _blur.y); }
		public function set blur(value:AntPoint):void
		{
			_blur.copyFrom(value);
			if (_blur.x == 0 && _blur.y == 0 && _flashSprite.filters.length > 0)
			{
				_flashSprite.filters = null;
			}
			else if (_blur.x > 0 || _blur.y >= 0 && _flashSprite.filters == null)
			{
				_flashSprite.filters = [ new BlurFilter(_blur.x, _blur.y, 2) ];
			}
			else if (_flashSprite.filters != null)
			{
				var bf:BlurFilter = _flashSprite.filters[0] as BlurFilter;
				if (bf != null)
				{
					bf.blurX = _blur.x;
					bf.blurY = _blur.y;
				}
			}
			
			_isBacked = false;
		}
		
	}

}