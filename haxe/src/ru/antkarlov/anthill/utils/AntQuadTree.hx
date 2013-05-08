//import ru.antkarlov.anthill.debug.AntDrawer;
/**
 * Древовидный список сущностей для быстрой обработки большого количества объектов.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Anton Karlov
 * @since  30.08.2012
 */
package ru.antkarlov.anthill.utils;

import ru.antkarlov.anthill.*;
using Lambda;

class AntQuadTree extends AntRect {

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	public var members : AntList;
	public var northWestRect : AntRect;
	public var northEastRect : AntRect;
	public var southWestRect : AntRect;
	public var southEastRect : AntRect;
	public var northWest : AntQuadTree;
	public var northEast : AntQuadTree;
	public var southWest : AntQuadTree;
	public var southEast : AntQuadTree;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	var _widthHalf : Float;
	var _heightHalf : Float;
	var _devisions : Int;
	var _canSubdivide : Bool;
	var _min : Float;
	var _num : Int;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * @constructor
	 */
	public function new(aX : Float, aY : Float, aWidth : Float, aHeight : Float) {
		_devisions = 6;
		super(aX, aY, aWidth, aHeight);
		members = null;
		_num = 0;
		_min = (width + height) / (2 * _devisions);
		_canSubdivide = (width > _min) || (height > _min);
		_widthHalf = width * 0.5;
		_heightHalf = height * 0.5;
		northWestRect = new AntRect(x, y, _widthHalf, _heightHalf);
		northEastRect = new AntRect(x + _widthHalf, y, _widthHalf, _heightHalf);
		southWestRect = new AntRect(x, y + _heightHalf, _widthHalf, _heightHalf);
		southEastRect = new AntRect(x + _widthHalf, y + _heightHalf, _widthHalf, _heightHalf);
		northWest = null;
		northEast = null;
		southWest = null;
		southEast = null;
	}

	/**
	 * Добавляет объект или группу в дерево.
	 * 
	 * @param	aObject	 Объект который необходимо добавить в дерево.
	 * @return		Возвращает true если объект был добавлен в дерево.
	 */
	public function add(aEntity : AntBasic) : Bool {
		var e : AntEntity = try cast(aEntity, AntEntity) catch(e:Dynamic) null;
		if(e != null && e.isGroup)  {
			// Если объект для добавления является группой,
			// то выполняем метод add() рекурсивно для каждого объекта из группы.
			var g : AntEntity = e;
			var n : Int = e.children.length;
			var i : Int = 0;
			while(i < n) {
				e = try cast(g.children[i], AntEntity) catch(e:Dynamic) null;
				if(e != null && e.exists && e.active)  {
					add(e);
				}
				i++;
			}
		}

		else if(e != null && !e.isGroup)  {
			var t : Float = e.bounds.y;
			var r : Float = e.bounds.x + e.bounds.width;
			var b : Float = e.bounds.y + e.bounds.height;
			var l : Float = e.bounds.x;
			// Если объект целиком помещается в левую часть.
			if(l > northWestRect.left && r < northWestRect.right)  {
				// Если объект помещается целиком в левую верхнюю часть.
				if(t > northWestRect.top && b < northWestRect.bottom)  {
					if(northWest == null)  {
						northWest = new AntQuadTree(northWestRect.x, northWestRect.y, northWestRect.width, northWestRect.height);
					}
					if(northWest.add(e))  {
						return true;
					}
				}
				if(t > southWestRect.top && b < southWestRect.bottom)  {
					if(southWest == null)  {
						southWest = new AntQuadTree(southWestRect.x, southWestRect.y, southWestRect.width, southWestRect.height);
					}
					if(southWest.add(e))  {
						return true;
					}
				}
			}
			if(l > northEastRect.left && r < northEastRect.right)  {
				// Если объект целиком помещается в правую верхнюю часть.
				if(t > northEastRect.top && b < northEastRect.bottom)  {
					if(northEast == null)  {
						northEast = new AntQuadTree(northEastRect.x, northEastRect.x, northEastRect.width, northEastRect.height);
					}
					if(northEast.add(e))  {
						return true;
					}
				}
				if(t > southEastRect.top && b < southEastRect.bottom)  {
					if(southEast == null)  {
						southEast = new AntQuadTree(southEastRect.x, southEastRect.y, southEastRect.width, southEastRect.height);
					}
					if(southEast.add(e))  {
						return true;
					}
				}
			}
			if(l > left && r < right && t > top && b < bottom)  {
				addToMembers(e);
				return true;
			}
			if(!_canSubdivide || intersects(e.bounds.x, e.bounds.y, e.bounds.width, e.bounds.height))  {
				addToMembers(e);
				return true;
			}
		}
		return false;
	}

	/**
	 * Запрос на получение объектов из дерева в заданном прямоугольнике.
	 * 
	 * @param	aRect	 Прямоугольник в пределах которого необходимо получить объекты из дерева.
	 * @param	aResult	 Массив куда будет записан результат.
	 * @return		Возвращает список объектов входящих в заданный прямоугольник.
	 */
	public function queryRect(aRect : AntRect, aResult : Array<Dynamic> = null) : Array<Dynamic> {
		if(aResult == null)  {
			aResult = [];
		}
		if(members == null || !intersectsRect(aRect))  {
			return aResult;
		}
		var e : AntEntity;
		var cur : AntList = members;
		while(cur != null) {
			e = try cast(cur.data, AntEntity) catch(e:Dynamic) null;
			if(e != null && e.exists && e.active && aRect.intersects(e.bounds.x, e.bounds.y, e.bounds.width, e.bounds.height))  {
				if(aResult.indexOf(e) == -1)  {
					aResult[aResult.length] = e;
				}
			}
			cur = cur.next;
		}

		// Извлекаем объекты из вложенных узлов.
		if(northWest != null)  {
			northWest.queryRect(aRect, aResult);
		}
		if(northEast != null)  {
			northEast.queryRect(aRect, aResult);
		}
		if(southWest != null)  {
			southWest.queryRect(aRect, aResult);
		}
		if(southEast != null)  {
			southEast.queryRect(aRect, aResult);
		}
		return aResult;
	}

	/**
	 * Отладачная отрисовка дерева.
	 * 
	 * @param	aCamera	 Указатель на камеру.
	 */
	public function debugDraw(aCamera : AntCamera = null) : Void {
		/*if (AntG.debugDrawer == null)
		{
		return;
		}
		
		if (aCamera == null)
		{
		aCamera = AntG.getCamera();
		}
		
		var drawer:AntDrawer = AntG.debugDrawer;
		drawer.drawRect(x + aCamera.scroll.x, y + aCamera.scroll.y, width, height, AntColor.GRAY);
		
		if (northWest != null)
		{
		northWest.debugDraw(aCamera);
		}
		
		if (northEast != null)
		{
		northEast.debugDraw(aCamera);
		}
		
		if (southWest != null)
		{
		southWest.debugDraw(aCamera);
		}
		
		if (southEast != null)
		{
		southEast.debugDraw(aCamera);
		}*/
	}

	//---------------------------------------
	// PROTECTED METHODS
	//---------------------------------------
	/**
	 * Разделяет текущий узел еще на четыре узла.
	 */
	/*protected function subdivide():void
	{
	var widthHalf:Number = width * 0.5;
	var heightHalf:Number = height * 0.5;
	northWest = new AntQuadTree(x, y, widthHalf, heightHalf);
	northEast = new AntQuadTree(x + widthHalf, y, widthHalf, heightHalf);
	southWest = new AntQuadTree(x, y + heightHalf, widthHalf, heightHalf);
	southEast = new AntQuadTree(x + widthHalf, y + heightHalf, widthHalf, heightHalf);
	}*/
	/**
	 * Добавляет объект в текущий узел.
	 */
	function addToMembers(aObject : AntBasic) : Void {
		if(members == null)  {
			members = new AntList(aObject);
			_num++;
			return;
		}
		var item : AntList = new AntList(aObject);
		var cur : AntList = members;
		while(cur.next != null) {
			cur = cur.next;
		}

		cur.next = item;
		_num++;
	}

}

