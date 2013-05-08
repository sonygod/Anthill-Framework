/**

 * Позволяет быстро рассчитать среднее значение из имеющегося диапазона значений.

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Anton Karlov

 * @since  23.11.2011

 */
package ru.antkarlov.anthill.utils;

class AntRating {

	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	/**

	 * Максимальное количество значений.

	 */
	var _size : UInt;
	/**

	 * Индекс ячейки в которую будет записано новое значение.

	 */
	var _ind : UInt;
	/**

	 * Массив значений.

	 */
	var _data : Array<Dynamic>;
	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new(aSize : UInt, aDefault : Float = 0) {
		//super()
		_size = ((aSize <= 0)) ? 1 : aSize;
		_ind = 0;
		_data = new Array<Dynamic>();
		var i : UInt = 0;
		while(i < _size) {
			_data[i] = aDefault;
			i++;
		}
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Добавляет новое значение.

	 * 

	 * @param	value	 Новое значение.

	 */
	public function add(value : Float) : Void {
		_data[_ind++] = value;
		if(_ind >= _size)  {
			_ind = 0;
		}
	}

	/**

	 * Рассчитывает среднее значение.

	 * 

	 * @return		Среднее значение из текущего диапазона.

	 */
	public function average() : Float {
		var sum : Float = 0;
		var i : UInt = 0;
		while(i < _size) {
			sum += _data[i];
			i++;
		}
		return sum / _size;
	}

	/**

	 * Возвращает количество значений.

	 */
	public function length() : Int {
		return _size;
	}

}

