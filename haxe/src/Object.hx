package ;

/**
 * ...
 * @author sonygod
 */
abstract Object(Dynamic)  {
  private inline function new(a:Dynamic) {
		  this = a;
		
		 a = null;
  }
  
  @:from static public inline function from(a:Dynamic):Object {
	 
	return new  Object(a);
  }
  
   @:to public inline function to():Object{
	 
		return this;
   }
   
   
   @:arrayAccess public inline function arrayAccess(key:String):Dynamic {
		return Reflect.field(this, key);
	}
	
	@:arrayAccess public inline function arrayWrite<T>(key:String, value:T):T {
		Reflect.setField(this, key, value);
		return value;
	}
  }