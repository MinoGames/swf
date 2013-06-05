﻿package com.codeazur.hxswf.data.actions.swf4
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionSetVariable extends Action implements IAction
	{
		public static inline var CODE:Int = 0x1d;
		
		public function ActionSetVariable(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionSetVariable]";
		}
	}
}
