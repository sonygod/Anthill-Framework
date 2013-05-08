/**
 * Простой связный список.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  20.08.2012
 */
package ru.antkarlov.anthill.utils;

class AntList {

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**
	 * Указатель на данные которые содержит текущий элемент.
	 */
	public var data : Dynamic;
	/**
	 * Указатель на следующий элемент списка.
	 * @default	null
	 */
	public var next : AntList;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**
	 * Создает новый элемент списка.
	 * 
	 * @param	aData	 Данные которые необходимо поместить в текущий элемент.
	 * @param	aNext	 Указатель на следующий элемент списка.
	 */
	public function new(aData : Dynamic, aNext : AntList = null) {
		//super()
		data = aData;
		next = aNext;
	}

	/**
	 * Уничтожает элемент списка и последующие связанные с ним.
	 */
	public function destroy() : Void {
		data = null;
		if(next != null)  {
			next.destroy();
		}
		next = null;
	}

}

