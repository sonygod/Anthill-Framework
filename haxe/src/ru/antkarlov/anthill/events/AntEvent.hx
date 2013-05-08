/**
 * Простая реализация всплывающего события.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 9.0.0
 * 
 * @author Антон Карлов
 * @since  25.02.2013
 */
package ru.antkarlov.anthill.events;

import msignal.EventSignal;

class AntEvent implements IEvent {
	@:isVar public var signal(get, set) : EventSignal<Dynamic,Dynamic>;
	@:isVar public var target(get, set) : Dynamic;
	@:isVar public var currentTarget(get, set) : Dynamic;
	@:isVar public var bubbles(get, set) : Bool;

	//---------------------------------------
	// PUBLIC VARIABLES
	//---------------------------------------
	/**
	 * Любые пользовательские данные которые может нести в себе событие.
	 * @default	null;
	 */
	public var userData : Dynamic;
	//---------------------------------------
	// PROTECTED VARIABLES
	//---------------------------------------
	var _bubbles : Bool;
	var _target : Dynamic;
	var _currentTarget : Dynamic;
	var _signal : EventSignal<Dynamic,Dynamic>;
	public function new(aBubbles : Bool = false, aUserData : Dynamic = null) {
		//super()
		_bubbles = aBubbles;
		userData = aUserData;
	}

	/**
	 * @inheritDoc
	 */
	function get_signal() : EventSignal<Dynamic,Dynamic> {
		return _signal;
	}

	function set_signal(value : EventSignal<Dynamic,Dynamic>) : EventSignal<Dynamic,Dynamic> {
		_signal = value;
		return value;
	}

	/**
	 * @inheritDoc
	 */
	function get_target() : Dynamic {
		return _target;
	}

	function set_target(value : Dynamic) : Dynamic {
		_target = value;
		return value;
	}

	/**
	 * @inheritDoc
	 */
	function get_currentTarget() : Dynamic {
		return _currentTarget;
	}

	function set_currentTarget(value : Dynamic) : Dynamic {
		_currentTarget = value;
		return value;
	}

	/**
	 * @inheritDoc
	 */
	function get_bubbles() : Bool {
		return _bubbles;
	}

	function set_bubbles(value : Bool) : Bool {
		_bubbles = value;
		return value;
	}

	/**
	 * @inheritDoc
	 */
	public function clone() : IEvent {
		var newEvent : AntEvent = new AntEvent(_bubbles);
		newEvent.userData = userData;
		return newEvent;
	}

}

