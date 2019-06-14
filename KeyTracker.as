class KeyTracker{
	static var buttonKeys = new Array(1, 32, 65);
	static var pressTimer = new Array();
	static var pressed = new Array();
	
	
	static var tracker = undefined;
	
	static function init(){
		if (tracker != undefined)
			return;
			
		for (var i = 0; i < buttonKeys.length; ++i){
			pressTimer.push(0);
			pressed.push(false);
		}
		tracker = _root.attachMovie("emptyMc", "button_tracker", _root.getNextHighestDepth());
		tracker.onEnterFrame = function(){
			for (var i = 0; i < buttonKeys.length; ++i){
				if (Key.isDown(buttonKeys[i]))
					pressTimer[i]++;
				else
					pressTimer[i] = 0;
				pressed[i] = pressTimer[i] == 1;
			}
		}
	}
	
	static function isPressed (keyCode:Number):Boolean{
		for (var i = 0; i < buttonKeys.length; ++i)
			if (buttonKeys[i] == keyCode && isPressedIndex(i))
				return true;
		return false;
	}
	static function isPressedIndex(keyCodeIndex:Number):Boolean{
		return pressed[keyCodeIndex];
	}
	
}