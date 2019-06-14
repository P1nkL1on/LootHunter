class engine{
    static var screenWidth = 512;
    static var screenHeight = 384;

    static var objs = new Array();
    static function createObj (where:MovieClip, libName:String, X:Number, Y:Number):MovieClip{
        if (where == undefined) where = _root;
        if (libName == undefined) libName = 'empty';
        if (X == undefined) X = 0;
        if (Y == undefined) Y = 0;

        var newDepth = where.getNextHighestDepth();
        var mc = where.attachMovie(libName, libName+'_'+newDepth, newDepth);
        if (libName != 'player'){
            mc.model = where.attachMovie('model', 'doom_'+ newDepth , newDepth + 1);
            mc.model._xscale = mc.model._yscale = 30; 
            // mc.model.cacheAsBitmap = true;
        }
        mc.x = X; mc.y = Y;
        mc.calculatePosition = function(viewpoint:MovieClip){
            this._rotation = this.watchAngle / Math.PI * 180;
            this._x = this.x * 10 + 150;
            this._y = this.y * 10 + 50;
            this._xscale = this._yscale = 40;
            if (this == viewpoint) return;

            this.watchAngle = Math.atan2(this._y - viewpoint._y, this._x - viewpoint._x) + Math.PI / 2;
            this.lastDistance = Math.sqrt(Math.pow(this.x - viewpoint.x, 2) + Math.pow(this.y - viewpoint.y, 2));
            
            var deltaAng = this.watchAngle - viewpoint.watchAngle;
            this.isVisible = 
                this.lastDistance < viewpoint.maxViewDistance
                && Math.abs(deltaAng) >=  Math.PI - viewpoint.angleViewing * .5 
                && Math.abs(deltaAng) < Math.PI + viewpoint.angleViewing * .5;

            this._alpha = this.isVisible? 100 : 15;
            this.model._visible = this.isVisible;

            if (!this._visible){ return;}

            this.visibleAng = (deltaAng < 0? (deltaAng + Math.PI) : (deltaAng - Math.PI)) / viewpoint.angleViewing; // -.5 .. .5
            this.visibleDist = this.lastDistance / viewpoint.maxViewDistance;

            this.model._x = screenWidth * (.5 + this.visibleAng * (1.2 - this.visibleDist * .2));
            this.model._yscale = this.model._xscale = /*screenHeight*/ 120 * (1 - this.visibleDist);
            this.model._y = screenHeight * (1 - this.visibleDist) * .75;
        }
        objs.push(mc);
        return mc;
    }

    static var player = null;
    static function test(){
        player = createObj(undefined, 'player', 0, 0);
        player.maxViewDistance = 40;
        player.viewWide = 2;
        player.angleViewing = Math.PI * .5;
        player.watchAngle = 0;

        player.onEnterFrame = function(){
            this.watchAngle +=  (Math.PI * .05) * (Key.isDown(Key.LEFT)? -1 : Key.isDown(Key.RIGHT)? 1 : 0);
            if (this.watchAngle > Math.PI * 2) this.watchAngle -= Math.PI * 2;
            if (this.watchAngle < 0) this.watchAngle += Math.PI * 2;

            this.y = _root._ymouse * .1 - 5 - .4;
            this.x = _root._xmouse * .1 - 15 - .4;
            //this._rotation = this.watchAngle / Math.PI * 180;
            for (var i = 0; i < objs.length; ++i)
                objs[i].calculatePosition(this);
        }

        for (var i = 0; i < 40; ++i)
            for (var j = -9; j <= 9; j+= 3){
                var dot = createObj(undefined, 'dot', j, i);
                dot.calculatePosition(player);
            }
    }

}