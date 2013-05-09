/**

 * Базовый класс для игровых состояний. Все игровые состояния будь то игровое меню или

 * игровой процесс - следует наследовать от этого класса.

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Anton Karlov

 * @since  30.08.2012

 */
package ru.antkarlov.anthill;

import flash.display.Sprite;

class AntState extends Sprite {

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**

	 * Основная группа сущностей для текущего состояния.

	 */
	public var defGroup : AntEntity;
	/**

	 * Указатель на метод <code>defGroup.add()</code>.

	 */
	public var add : AntEntity->AntEntity;
	/**

	 * Указатель на метод <code>defGroup.remove()</code>.

	 */
	public var remove : AntEntity->?Bool->Void;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new() {
		super();
		defGroup = new AntEntity();
		add = defGroup.add;
		remove = defGroup.remove;
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Инициализация состояния. 

	 * Вызывается автоматически после создания и добавления в структуру игрового движка.

	 */
	public function create() : Void {
		/*

		Перекройте этот метод чтобы в нем корректно создавать все игровые объекты.

		*/
	}

	/**

	 * Уничтожение остояния. 

	 * Вызывается автоматически перед удалением состояния из структуры игрового движка.

	 */
	public function destroy() : Void {
		/*

		Перекройте этот метод чтобы в нем корректно освобождать все игровые объекты.

		*/
	}

	/**

	 * Вызывается каждый кадр перед вызовом метода <code>update()</code>.

	 */
	public function preUpdate() : Void {
		//
	}

	/**

	 * Вызывается каждый кадр после вызова метода <code>preUpdate()</code>.

	 */
	public function update() : Void {
		defGroup.preUpdate();
		defGroup.update();
		defGroup.postUpdate();
	}

	/**

	 * Вызывается каждый кадр сразу после вызова метода <code>update()</code>.

	 */
	public function postUpdate() : Void {
		//
	}

}

