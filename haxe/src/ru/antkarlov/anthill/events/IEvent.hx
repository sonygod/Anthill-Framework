package ru.antkarlov.anthill.events;

import msignal.EventSignal;

interface IEvent {
	var target(get_target, set_target) : Dynamic;
	var currentTarget(get_currentTarget, set_currentTarget) : Dynamic;
	var signal(get_signal, set_signal) : EventSignal<Dynamic,Dynamic>;
	var bubbles(get_bubbles, set_bubbles) : Bool;

	/**
	 * Указатель на объект который произвел событие.
	 */
	function get_target() : Dynamic;
	function set_target(value : Dynamic) : Dynamic;
	/**
	 * Указатель на текущий объект посредник через который прошло событие.
	 */
	function get_currentTarget() : Dynamic;
	function set_currentTarget(value : Dynamic) : Dynamic;
	/**
	 * Сигнал который произвел событие.
	 */
	function get_signal() : EventSignal<Dynamic,Dynamic>;
	function set_signal(value : EventSignal<Dynamic,Dynamic>) : EventSignal<Dynamic,Dynamic>;
	/**
	 * Определяет является ли событие всплывающим.
	 */
	function get_bubbles() : Bool;
	function set_bubbles(value : Bool) : Bool;
	/**
	 * Создает копию события.
	 */
	function clone() : IEvent;
}

