class EventTree {

	// System for creating, editing and processing multiple ivents,
	// which are folowwing one by one with concreate conditions
	// There are 4 types of permanents in this net:
	//		Events
	//		Conditions
	//		Connection
	//		Special block blocks (XOR, control-separator, etc)
	
	
	static function test(){
		KeyTracker.init();
		initMouseController();
	
		var T = initClear("testing");
		
		var count = 10;
		while(count--)
			T.events.push(createEvent(T));
		
		var E1 = createEvent(T, teCallfunction, "Starter", "Simple event which continues 5 frames.");
		var E2 = createEvent(T);
		var E3 = createEvent(T);
		var E4 = createEvent(T);
		
		T.events.push(E1);
		T.events.push(E2);
		T.events.push(E3);
		T.events.push(E4);
		
		//T.connections.push(createConnection(E1, E2));
		//T.connections.push(createConnection(E2, E3));
		//T.connections.push(createConnection(E2, E4));
		
		T.createView();
		
		//T.start(E1, "no-context");
	}

	static var controller = undefined;
	static function initMouseController (){
		if (controller != undefined)
			return;
		controller = _root.attachMovie("emptyMc", "mcr", _root.getNextHighestDepth());
		_root.mcr.prevHovered = null;
		_root.mcr.onEnterFrame = function(){
			for (var i = movablePointers.length - 1; i>= 0; --i)
				if (movablePointers[i].hitTest(_root._xmouse, _root._ymouse, true)){
					unhover(this.prevHovered);
					this.prevHovered = movablePointers[i];
					hover(movablePointers[i]);
					return;
				}
			if (this.prevHovered == null)
				return;
			unhover(this.prevHovered);
			this.prevHovered = null;
		}
	}
	
	static function hover(something:MovieClip, isHovering){
		if (isHovering == undefined) isHovering = true;
		if (something.canMove)
			something.signalTo.isHovered = isHovering;
		else
			something.source.isSelected = isHovering;
		
	}
	static function unhover(something:MovieClip) {hover(something, false);}
	
	static var treeCount = 0;
	static function initClear(name:String):Object{
		var tree:Object = new Object();
		tree.name = name;
		tree._name = "EventTree_" + name;
		
		// make cross-pointers
		tree.mc = createViewOfTree(tree);
		tree.mc.source = tree;
		
		tree.editedConView = undefined;
		tree.mc.onEnterFrame = function (){
			var T = this.source;
			this.source.tick();
			
			// continue any of existing actions
			// moving new connection and find a place to it
			if (T.editedConView != undefined){
				if (KeyTracker.pressTimer[0]){
					var con = T.editedConView.freeEnd;
					con._x = _root._xmouse;
					con._y = _root._ymouse;
				}else{
					T.editedConView = undefined;
				}
			}
			
			
			
			
			// track any input commands
			var hoveredObj = T.selectHovered();
			if (hoveredObj == null)
				return;
			// activate a custom indexed event
			if (KeyTracker.isPressed(32) && hoveredObj.blockType == "event")
				T.start(hoveredObj, "callback from mc structure");
				
			// create a new connection
			if (KeyTracker.isPressedIndex(0) && hoveredObj.blockType == "port"){
				var parent = hoveredObj._parent.source;
				var createdConnection = true;
				switch(hoveredObj.subType){
					case "input":	T.connections.push(createConnection(null, parent)); break;
					case "output":	T.connections.push(createConnection(parent, null)); break;
					default: createdConnection = false; break;
				}
				if (createdConnection){
					T.editedConView = createViewOfConnection(T.connections[T.connections.length - 1], this);
					T.mcs.push(T.editedConView);
					T.editedConView.freeEnd = 
						T.editedConView.source.from == null?
						T.editedConView.in0 : T.editedConView.out0;
				}
			}
		}
		
		
		// logical realisation
		tree.events = new Array();
		tree.conditions = new Array();
		tree.connections = new Array();
		tree.logick = new Array();
		
		// visual interpritation
		// *** must be completely separated, because
		// 	   tree should work fine even without any
		//     visual perfomance
		// contains only a movieclips,
		// which shows structure and current state
		// of a event-based-tree
		tree.mcs = new Array();	
		// delete all movieclips
		tree.clearView = function(){
			for (var i = 0; i < this.mcs.length; ++i)
				this.mcs[i].removeMovieClip();
		}
		tree.selectHovered = function():Object{
			for (var i = 0; i < movablePointers.length; ++i)
				if (movablePointers[i].signalTo.isHovered == true || movablePointers[i].source.isSelected == true)
					return movablePointers[i].source;
			return null;
		}
		
		// create all possible visual blocks
		tree.createView = function(){
			if (this.mcs.length > 0)
				this.clearView();
			for (var i = 0; i < this.events.length; ++i)
				this.mcs.push(createViewOfEvent(this.events[i], this.mc));
				
			for (var i = 0; i < this.connections.length; ++i)
				this.mcs.push(createViewOfConnection(this.connections[i], this.mc));
		}
		tree.tick = function (){
			for (var i = 0; i < this.events.length; ++i){
				var e = this.events[i];
				//trace(e._name + '/' + e.isValid + '/' + e.isEnabled());
				if (e.isValid == true && e.isEnabled() == true && e.isDeleted == false)
					e.tick();
			}
			for (var i = 0; i < this.connections.length; ++i){
				var c = this.connections[i];
				// work only with enabled connections
				if (!c.isEnabled)
					continue;
				// if enabled check all conditions
				// **checking all conditions**
				// **if not all are complete, then continue;**
				
				// find a connected to it events
				// to pass them a control-execution-flow
				for (var j = 0; j < this.events.length; ++j)
					if (c.to == this.events[j])
						this.events[j].start(c.passedContext);
				// erase context
				c.isEnabled = false;
				c.passedContext = undefined;
			}
		}
		// start tree executing from any event
		tree.start = function (Event:Object, executingContext){
			Event.start(executingContext);
		}
		
		return tree;
	}
	
	static var teCallfunction = 1;
	
	static var tcTimewait = 1;
	static var tcLogCatch = 2;
	
	static var tlXOR = 1;
	static var tlParallel = 2;
	
	static function createValueableElement (tree:Object):Object{
		var o = new Object();
		// for checking of correct of executing
		o.isValid = true;
		o.isDeleted = false;
		o.tree = tree;
		
		return o;
	}
	
	static function createEvent (tree:Object, eventType, name:String, description:String):Object{
		var event = createValueableElement(tree);
		event.blockType = "event";
		event.eventType = eventType == undefined? teCallfunction : eventType;
		event.currentTime = -1;
		event.maxTime = 0;
		event._name = "Event_" + event.eventType + (name != undefined? ("_" + name) : "");
		
		event.execute = function (context): Number{
			return 30;
		}
		event.start = function (context){
			this.usedContext = context;
			this.maxTime = this.execute(context);
			var skipped = this.maxTime <= 0;
			log(!skipped? "Started successfully" : "Executed and finished.", this);
			if (skipped)
				this.finish();
			else
				// set timer to enable running
				this.currentTime = 0;
		}
		event.tick = function (){
			++this.currentTime;
			if (this.currentTime < this.maxTime)
				return;
			this.currentTime = -1;
			this.finish();
		}
		event.finish = function (){
			log ("Finished", this);
			// pass a control flow to all children
			// find a connections
			var ff = allConnectionsFrom(this.tree, this);
			for (var i = 0; i < ff.length; ++i){
				// for any connection, which is come from this event
				// set it enabled and pass a context
				ff[i].isEnabled = true;
				ff[i].passedContext = this.usedContext;
			}
		}
		event.isEnabled = function():Boolean{return this.currentTime >= 0;}
		return event;
	}
	
	static function allConnectionsFrom (tree:Object, event:Object):Array{
		var f = new Array();
		for (var i = 0; i < tree.connections.length; ++i)
			if (tree.connections[i].from == event)
				f.push(tree.connections[i]);
		return f;
	}
	
	static function createConnection (eventFrom:Object, eventTo:Object, name:String):Object{
		trace(eventFrom._name + '<-->' + eventTo._name);
		
		var connection = createValueableElement(eventFrom.tree);
		connection._name = "Connection" + (name != undefined? ("_" + name) : "");
		connection.blockType = "connection";
		connection.from = eventFrom;
		connection.to = eventTo;
		connection.fromInd = connection.toInd = -1;
		
		connection.isEnabled = false;
		
		connection.findIndices = function(tree:Object){
			if (this.from == null || this.to == null)
				return;
			this.fromInd = tree.connections.indexOf(this.from);
			this.toInd = tree.connections.indexOf(this.to);
		}
		connection.findObjects = function(tree:Object){
			if (this.fromInd == -1 || this.toInd == -1)
				return;
			this.from = tree.connections[this.fromInd];
			this.to = tree.connections[this.toInd];
		}
		return connection;
	}
	
	static function createViewOfTree(tree:Object):MovieClip{
		return _root.attachMovie("emptyMc", tree._name, _root.getNextHighestDepth());
	}
	
	static function createViewOfAny(any:Object, parentTreeView:MovieClip):MovieClip{
		if (parentTreeView.layersUsed == undefined) parentTreeView.layersUsed = parentTreeView.getNextHighestDepth();
		++parentTreeView.layersUsed;
		var mc = parentTreeView.attachMovie(any.blockType + "Mc", "mc_" + parentTreeView.layersUsed, parentTreeView.layersUsed);
		mc.source = any;
		return mc;
	}
	
	static var drawElementsCount = 0;
	static var spawnOffsetX = 5;
	static var spawnOffsetY = 5;
	static function createViewOfEvent(event:Object, parentTreeView:MovieClip):MovieClip{
		var mc = createViewOfAny(event, parentTreeView);
		event.mc = mc;
		mc.source = event;
		mc._x = (50 + drawElementsCount * spawnOffsetX);
		mc._y = (50 + drawElementsCount * spawnOffsetY);
		makeMovable(mc, mc.hb, new Array(mc.in0, mc.out0));
		
		// port problems
		mc.hb_in.source = mc.in0;
		mc.hb_out.source = mc.out0;
		mc.in0.blockType = mc.out0.blockType = "port";
		mc.in0.subType = "input";
		mc.out0.subType = "output";
		movablePointers.push(mc.hb_in, mc.hb_out);
		++drawElementsCount;
		return mc;
	}
	
	static function createViewOfConnection(connection:Object, parentTreeView:MovieClip):MovieClip{
		var mc = createViewOfAny(connection, parentTreeView);
		connection.mc = mc;
		mc.source = connection;
		makeMovable(mc.in0, undefined, undefined, 3, 2);
		makeMovable(mc.out0, undefined, undefined, 3, 2);
		return mc;
	}
	
	static var logs = new Array();
	static function log (mes:String, source:Object){
		logs.push(mes);
		if (source != undefined) mes = source._name + ": " + mes;
		trace(mes);
	}
	
	
	static var defaultHoverScale = 1.15;
	static var defaultHoverScalingSpeed = 5;
	
	static var movablePointers = new Array();
	
	static function makeMovable (
		who:MovieClip, 
		whoHitbox:MovieClip, 
		whoIgnoreScalingParts:Array,
		hoverScale:Number, 
		hoverScalingSpeed:Number
	){
		if (whoHitbox == undefined) whoHitbox = who;// else who.hitbox = whoHitbox;
		whoHitbox.signalTo = who;
		whoHitbox.source = who.source;
		whoHitbox.canMove = true;
		movablePointers.push(whoHitbox);
		
		if (hoverScale == undefined) who.hoverScale = defaultHoverScale; else who.hoverScale = hoverScale;
		if (hoverScalingSpeed == undefined) who.hoverScalingSpeed = defaultHoverScalingSpeed; else who.hoverScalingSpeed = hoverScalingSpeed;
		who.isHovered = false;
		who.isMoving = false;
		who.x0 = 0; who.y0 = 0;
		if (whoIgnoreScalingParts == undefined) whoIgnoreScalingParts = new Array();
		for (var i = 0; i < whoIgnoreScalingParts.length; ++i)
			whoIgnoreScalingParts[i].yy = whoIgnoreScalingParts[i]._y;
		who.ignores = whoIgnoreScalingParts;
		
		who.onMouseDown = function(e){
			if (!this.isHovered)
				return;
			this.isMoving = true;
			this.x0 = this._parent._xmouse - this._x;
			this.y0 = this._parent._ymouse - this._y;
		}
		who.onMouseUp = function(e){
			if (this.isHovered)
				this.isMoving = false;
		}
		who.onMouseMove = function(){
			//this.isHovered = this.hitbox.hitTest(_root._xmouse, _root._ymouse);
			if (!this.isMoving)
				return;
			this._x = this._parent._xmouse - this.x0;
			this._y = this._parent._ymouse - this.y0;
		}
		who.scale = 1;
		who.scaleTo = 1;
		who.onEnterFrame = function(){
			this.scaleTo = this.isHovered? who.hoverScale : 1;
			if (Math.abs(this.scale - this.scaleTo) > .001)
				this.scale += (this.scaleTo - this.scale) / who.hoverScalingSpeed;
			this._xscale = this._yscale = 100 * this.scale;
			for (var i = 0; i < this.ignores.length; ++i)
				this.ignores[i]._y = this.ignores[i].yy * 100 / this._yscale;
		}
	}
}