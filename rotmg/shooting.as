class shooting
{
    static var tileSize = 40;


    // return no effect status for
    // just damaging attacks
    static var noEffect = new Array();
    static var colorWhite = new Array(255, 255, 255);

    static function spawnBullet(
        source:MovieClip,
        shootingAngle:Number,
        bulletSpriteNameInLibrary:String,
        bulletSpeedTilesPerSecond:Number,
        bulletRangeTiles:Number,
        bulletDamageOnContact:Number,
        bulletDestroyOnDamage:Boolean,
        bulletEffectApplyOnContact:Array   // {effectId, effectDurationInSeconds}
    ):MovieClip{
        var bullet = spawn.create(bulletSpriteNameInLibrary);
        bullet._x = source._x; bullet._y = source._y;
        bullet.host = source;

        var speed = bulletSpeedTilesPerSecond / fps.DefaultLimit  * tileSize;
        bullet.range = bulletRangeTiles * tileSize;
        bullet.dmg = bulletDamageOnContact;
        bullet.autodestroy = bulletDestroyOnDamage;
        bullet.damaged = new Array(); // movieclips of damaged enemies
        bullet.effectApply = bulletEffectApplyOnContact;

        bullet._rotation = shootingAngle / Math.PI * 180;
        bullet.dx = speed * Math.cos(shootingAngle);
        bullet.dy = speed * Math.sin(shootingAngle);
        bullet.dt = speed; bullet.travelDistance = 0;
        bullet.onEnterFrame = function(){
            this.travelDistance += this.dt * fps.updatesPerFrame;
            this._x += this.dx * fps.updatesPerFrame;
            this._y += this.dy * fps.updatesPerFrame;
            // check collisions


            if (this.travelDistance < this.range) return;
            this.removeMovieClip();
        }
        return bullet;
    }

    static function attackDescription (
        bulletCount:Number,
        bulletSpreadRad:Number,
        bulletSpeedTilesPerSecond:Number,
        bulletRangeTiles:Number,
        bulletDamageOnContact:Number,
        bulletDestroyOnDamage:Boolean,
        bulletEffectApplyOnContact:Array,   // {effectId, effectDurationInSeconds}
        bulletEffectApplyOnSelf:Array,      // {effectId, effectDurationInSeconds}
        preAttackTimeSeconds:Number,
        postAttackTimeSeconds:Number,
        movePenaltyDuringAttack:Number,

        bulletSpriteNameInLibrary:String,
        bulletSpriteSize:Number,
        bulletSpriteColor:Array             // {R = 0..255, G, B}
    ){
        ut.setDefaultValuesIfMissing(arguments, new Array(
        //___combat effects
            1, // 0     bulletCount:Number,
            0, // 1     bulletSpreadRad:Number,
            6, // 2     bulletSpeedTilesPerSecond:Number,
            4, // 3     bulletRangeTiles:Number,
            10,     // 4     bulletDamageOnContact:Number,
            true,   // 5     bulletDestroyOnDamage:Boolean,
            noEffect,   // 6     bulletEffectApplyOnContact:Array,  
            noEffect,   // 7     bulletEffectApplyOnSelf:Array,   
            .1, // 8     preAttackTimeSeconds:Number,
            .5, // 9     postAttackTimeSeconds:Number,
            0, // 10     movePenaltyDuringAttack:Number,
        
        //___visible effects
            'test_projectile',  // 11     bulletSpriteNameInLibrary:String,
            1,                  // 12     bulletSpriteSize:Number,
            colorWhite          // 13     bulletSpriteColor:Array  

        //___additional effects          
        ));
        return arguments;
    }



    // entity, which attached to any movieclip available to perform attacks
    // it manages the time of attacking and summoning correct bullets
    static function spawnAttackHandler(
        unit:MovieClip
    ):MovieClip{
        unit.attackHandler = spawn.create('empty', 'attackHandler', unit);
        if (unit.attackHandler == null){
            ut.log('Can not create attack handler for ' + unit._name);
            return;
        }
        // create a cross link
        unit.attackHandler.host = unit;
        // timer for preattack - post attack calculating
        unit.attackHandler.attackTimerSeconds = 0;
        unit.attackHandler.currentDescription = new Array();
        // disabling is required during out of view, or cutscene episodes
        unit.attackHandler.enabled = true;
        unit.attackHandler.isBusy = false;
        unit.attackHandler.attackPerformed = false;
        unit.attackHandler.onEnterFrame = function(){
            if (!this.enabled || !this.currentDescription.length) return;
            if (!this.isBusy){ this.isBusy = true; this.attackPerformed = false; this.host.speedModifier -= this.currentDescription[10]; }
            this.attackTimerSeconds += fps.secondsPerFrame;
            if (!this.attackPerformed &&
                this.attackTimerSeconds >= this.currentDescription[8]){
                this.attackPerformed = true;
                // perform an attack
                var shootingAngle = 
                    this.host.chasing == null?
                    0 : getChasingAngleRad(this.host, this.host.chasing);
                var currentShootingAngle = shootingAngle - this.currentDescription[1] * .5;
                var shootingAngleIncreasement = this.currentDescription[1] / (1 + this.currentDescription[0]);

                for (var bulletIndex = 0; bulletIndex < this.currentDescription[0];
                     ++bulletIndex, currentShootingAngle += shootingAngleIncreasement){
                        var bullet = spawnBullet(
                            this.host, currentShootingAngle,
                            this.currentDescription[11], this.currentDescription[2],
                            this.currentDescription[3],  this.currentDescription[4],
                            this.currentDescription[5],  this.currentDescription[6]
                        );
                        bullet._xscale = bullet._yscale = 100 * this.currentDescription[12];
                        colorSprite(bullet, this.currentDescription[13]);
                    }
            }
            if (this.attackTimerSeconds < this.currentDescription[8] + this.currentDescription[9])
                return;
            // return a speed modufier to normal
            if (this.isBusy){ this.isBusy = false; this.host.speedModifier += this.currentDescription[10]; }
            this.currentDescription = new Array();
            this.attackTimerSeconds = 0;
        }
        return unit.attackHandler;
    }
    // force a units attack handler to remember a granted description
    // then enable it to perform it in right time
    static function attack (
        attacker:MovieClip, 
        attackDescription:Array
    ):Array{
        var aah = attacker.attackHandler;
        if (aah == undefined)
            aah = spawnAttackHandler(attacker);
        if (aah.isBusy) return; // can not perform an attack (maybe queue it?)
        aah.currentDescription = attackDescription;
        aah.enabled = true;
    }

    static function colorSprite(sprite:MovieClip, spriteColor:Array){             // {R = 0..255, G, B)

        return sprite;
    }
    
    static function applyEffect(unit:MovieClip, effect:Array){
        if (effect.length == 0 || effect[0] == 'none' || effect[1] == undefined || isNaN(effect[1]) || effect[1] <= 0)
            return;
        ut.log('Applied ' + effect[0] + ' to ' + unit._name + ' for ' + effect[1] + ' seconds.');
    }

    static function getChasingAngleRad (chaser:MovieClip, victim:MovieClip){
        return Math.atan2(chaser._y - victim._y, chaser._x - victim._x) + Math.PI;
    }

    static function spawnEnemy(){
        var unit = spawn.create('test');
        unit.chasing = _root.player;
        unit.speedModifier = 1;
        return unit;
    }


    static function test(){
        var en = spawnEnemy();
        en._x = 200; en._y = 150;

        attack(en, attackDescription(
            5, Math.PI / 4
        ));
    }
}