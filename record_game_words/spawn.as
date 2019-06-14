class spawn
{
    static function log(message){
        trace(message);
    }

    static function create(libraryName:String, newName:String, where:MovieClip):MovieClip{
        if (where == undefined) where = _root;
        if (libraryName == undefined){ log('Can not create movieclip with undefined name!'); return;}
        var newDepth = where.getNextHighestDepth();
        if (newName == undefined) newName = libraryName + '_' + newDepth;
        var obj = where.attachMovie(libraryName, newName, newDepth);
        if (obj == undefined){ log('Can not create movieclip with name ' + libraryName + '!'); return; } 
        return obj;
    }
    static var nameDepth = new Array(
        'left', -100,
        'tail', -150,
        'leg', -20,
        'horn', -50
    );
    static function createBody(
        bodyParts:String,
        bodyPartPostfix,    // string or array
        visualStatusPrefix:String,
        bodyName:String,
        where:MovieClip
    ):MovieClip{
        if (bodyPartPostfix == undefined) bodyPartPostfix = 'human';
        var isPostfixArray = (bodyPartPostfix.push + '') != 'undefined';
        // trace(isPostfixArray);

        if (visualStatusPrefix == undefined) visualStatusPrefix = '';
        var bc = create('body_container', bodyName, where);
        bc.bodyPartMcs = new Array();
        
        for (var i = 0; i < bodyParts.length; ++i){
            var bp = create(
                bodyParts[i] + '_' + (isPostfixArray? 
                    bodyPartPostfix[Math.min(i,bodyPartPostfix.length - 1)] 
                    : bodyPartPostfix),
                'bp_' + i, bc);
            bp.gotoAndStop(visualStatusPrefix+'_idle');
            bp.prefix = visualStatusPrefix;
            bp.state = bp.prevState = 'idle';
            bp.phase = 0;
            bp.onEnterFrame = function(){
                if (this.state == this.prevState) return;
                this.gotoAndStop(this.prefix + '_' + this.state);                
                this.prevState = this.state; this.phase = 0;
            }
            var minusDepth = i;
            for (var j = 0; j < nameDepth.length; j += 2)
                if (bodyParts[i].indexOf(nameDepth[j]) >= 0)
                    minusDepth += nameDepth[j + 1];
            trace(bp._name + ': ' + bodyParts[i] + ' -> ' + (minusDepth + bp.getDepth()));
            bp.swapDepths(minusDepth + bp.getDepth());
            if (i > 0)
                for (var j = 0; j < bc.bodyPartMcs.length; ++j)
                    for (var k = 0; k < 4; ++k){
                        var foundName = bodyParts[i] + (k > 0?  (k + 1 + ''): '');
                        if (bc.bodyPartMcs[j][foundName] != undefined 
                         && bc.bodyPartMcs[j][foundName].used != true){
                            bp.attachTo = bc.bodyPartMcs[j][foundName];
                            bc.bodyPartMcs[j][foundName].used = true;
                            break;
                        }
                    }
            bc.bodyPartMcs.push(bp);
        }
        
        bc.attachHolder = create('body_container', 'attach_holder', bc);
        bc.attachHolder.onEnterFrame = function(){
            for (var i = 0; i < this._parent.bodyPartMcs.length; ++i){
                var bp = this._parent.bodyPartMcs[i];
                if (bp.attachTo == undefined) continue;
                aligment.attachTo(bp, bp.attachTo);
            }
        }

        return bc;
    }

    //
    static var bodyPartsHumanoid = new Array(   'body', 'head', 'left_hand', 'right_hand', 'left_leg', 'right_leg');
    static var bodyPartsTailHorns = new Array(  'body', 'head', 'left_hand', 'right_hand', 'left_leg', 'right_leg', 'tail', 'horn', 'horn');
    static var bodyPartsTail = new Array(       'body', 'head', 'left_hand', 'right_hand', 'left_leg', 'right_leg', 'tail');
    static function summArr(a, b):Array{
        var ar = new Array();
        for (var i = 0; i < a.length; ++i) ar.push(a[i]);
        for (var i = 0; i < b.length; ++i) ar.push(b[i]);
        return ar;
    }
    //
    static function test0(){
        var pt = new Array('', 'vampire', 'skeleton', 'zombie'), b = null;
        var pr = new Array(
            spawn.bodyPartsHumanoid, 'human'
            ,spawn.bodyPartsHumanoid, new Array('elf', 'elf', 'human')
            ,spawn.bodyPartsHumanoid, new Array('human', 'gnome', 'human', 'human', 'gnome')
            ,spawn.bodyPartsHumanoid, new Array('orc', 'gnome', 'human')
            ,spawn.bodyPartsHumanoid, new Array('orc', 'orc', 'human')
            ,spawn.bodyPartsTailHorns,new Array('strong', 'bull', 'hair', 'hair', 'bull')
            ,spawn.bodyPartsTail,     new Array('little', 'human', 'human', 'human', 'bird')
        );
        for (var i = 0; i < pt.length; ++i){
            for (var j = 0; j < pr.length; j+=2){
                b = spawn.createBody(pr[j], pr[j+1], pt[i]);
                b._x = 80 + 10 * i + 30 * j; b._y = 80 + 10 * i;
                b.key = 37 + i;
                b.onEnterFrame = function(){
                    this._visible = Key.isDown(this.key);
                    // this._visible = (this.key != 37)? Key.isDown(this.key) : (!Key.isDown(this.key));
                }
                // b.bodyPartMcs[0].onEnterFrame = function(){
                //     if (this.phase == undefined) this.phase = 0; else this.phase += .1;
                //     this._xscale = 100 + 20 * Math.cos(this.phase);
                // }
            }
        }
        //b.onEnterFrame = function(){this._x = _root._xmouse; this._y = _root._ymouse;}
    }
}