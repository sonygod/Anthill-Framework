/**

 * Хранилище позволяет хранить любые данные под понятными для нас 

 * текстовыми именами. Пример добавления и извлечения данных:

 * <code>var o:SomeObject = new SomeObject();

 * collection.set("someObject", o);

 * 

 * var o:SomeObject;

 * o = collection.get("someObject") as SomeObject;

 * </code>

 * 

 * @langversion ActionScript 3

 * @playerversion Flash 9.0.0

 * 

 * @author Антон Карлов

 * @since  19.09.2011

 */
package ru.antkarlov.anthill;

import flash.utils.Dictionary;
using Reflect;
class AntStorage extends Dictionary {
	@:isVar public var length(get, never) : Int;
	@:isVar public var isEmpty(get, never) : Bool;

	//---------------------------------------
	// CONSTRUCTOR
	//---------------------------------------
	/**

	 * @constructor

	 */
	public function new(useWeakReference : Bool = true) {
		super(useWeakReference);
	}

	//---------------------------------------
	// PUBLIC METHODS
	//---------------------------------------
	/**

	 * Добавляет данные в хранилище.

	 * 

	 * @param	aKey	 Ключевое имя данных.

	 * @param	aValue	 Какие-либо данные.

	 */
	public function set(aKey : String, aValue : Dynamic) : Void {
		//this[aKey] = aValue;
		this.setField(aKey, aValue);
	}

	/**

	 * Извлекает данные из хранилища.

	 * 

	 * @param	aKey	 Ключевое имя данных которые необходимо извлечь.

	 * @return		Возвращает какие-либо данные соотвествующие указанному ключу. Если данных нет, вернет null.

	 */
	public function get(aKey : String) : Dynamic {
		return this.field(aKey);
	}

	/**

	 * Возвращает ключ соотвествущий указанным данным.

	 * 

	 * @param	value	 Данные для которых необходимо получить ключ.

	 * @return		Возвращает null если указанных данных нет в хранилище.

	 */
	public function getKey(aValue : Dynamic) : String {
		for(prop in  Reflect.fields(this)) {
			if(this.field(prop)== aValue)  {
				return prop;
			}
		}

		return null;
	}

	/**

	 * Удаляет данные из хранилища по ключу.

	 * 

	 * @param	aKey	 Ключ данных которые необходимо удалить.

	 * @return		Возвращает указатель на удаленные данные.

	 */
	public function remove(aKey : String) : Dynamic {
		var data : Dynamic = this.field(aKey);//this[aKey];
		this.setField(aKey, null);
		return data;
	}

	/**

	 * Определяет содержит ли хранилище данные с указанным ключом.

	 * 

	 * @param	aKey	 Ключ для данных существование которых надо проверить.

	 * @return		Возвращает true если данные с указанным ключом существуют.

	 */
	public function containsKey(aKey : String) : Bool {
		return this.field(aKey) != null;//this[aKey] != null;
	}

	/**

	 * Определяет содержит ли хранилище указанные данные.

	 * 

	 * @param	aValue	 Данные наличие которых необходимо проверить.

	 * @return		Возвращает true если указанные данные имеются в хранилище.

	 */
	public function contains(aValue : Dynamic) : Bool {
		for(prop in  Reflect.fields(this)) {
			if(this.field(prop) == aValue)  {
				return true;
			}
		}

		return false;
	}

	/**

	 * Очищает хранилище.

	 */
	public function clear() : Void {
		for(prop in  Reflect.fields(this)) {
			
			this.remove(prop);
		}

	}

	//---------------------------------------
	// GETTER / SETTERS
	//---------------------------------------
	/**

	 * Возвращает количество данных имеющихся в хранилище.

	 */
	function get_length() : Int {
		var len : Int = 0;
		for(prop in  Reflect.fields(this)) {
			if(this.field(prop) != null)  {
				len++;
			}
		}

		return len;
	}

	/**

	 * Вернет true если хранилище пустое.

	 */
	function get_isEmpty() : Bool {
		return (this.length <= 0);
	}

}

