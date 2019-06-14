class stats{
    // <statDescriptionAndLevels>
    static var calculationaccuracy = 100;
    static var showAlerts = false;

    static var raceSizePrefix = new Array(
        '', 'undergrown', 'overgrown'
    );
    static var raceAlivePrefixs = new Array(
        '', 'vampire', 'skeleton', 'zombie', 'lich'
    );
    static var races = new Array(
        'human', 'elf', 'gremlin', 'fairy', 'harpy', 
        'centaur', 'minotaur', 'mermaid', 'siren',                         
        'sphynx', 'orc', 'dwarf', 'demon', 'imp', 
        'troll', 'lizard', 'dragon'
    );
    static var proffesions = new Array(
        '', 'miner', 'steel worker', 'stoker',
        'deliveryman', 'banker', 'agent', 'lawyer',
        'freelancer', 'businessman', 'artist', 
        'singer', 'bum'
    );


    static var allStats = new Array(
        'size', 'material', 'wingsize', 'will', 'order', 'side',
        'vit', 'spd', 'dex', 'att', 'int', 'wiz', 'def', 'age', 'weight',
        'hp', 'pdef', 'ddg', 'wtcr',
        'firres', 'eleres', 'frores', 'toxres', 
        'corres','stres', 'ini', 'cha', 'sps',
        'acc', 'ats','ars', 'pdmg', 'mdmg', 'ms', 
        'itus'
    );

    static var bornStats = 
        ' size . material . wingsize . will . order . side '
    static var rpgStatNames =
        new Array('vit', 'spd', 'dex', 'att', 'int', 'wiz', 'def', 'age', 'weight');
    static var rpgStats = 
        ' vit . spd . dex . att . int . wiz . def . age . weight '
    static var calcStats = 
        ' hp . pdef . ddg . wtcr . firres . eleres . frores . toxres . corres . ini . cha . sps . acc . ats . ars . pdmg . mdmg . ms . stres . itus '

    static var sizeDescr =
        "Size defines the physical size of a unit.";
    static var sizes = new Array(
        'tiny', 'small', 'medium', 
        'large', 'huge', 'giant');
    static var materialDescr =
        "Each unit has it owns weak and strong spots, "
        +"based on it own properties, such as material,"
        +" for example.";
    static var materials = new Array(
        'skin', 'leather', 'bone', 
        'fur', 'woord', 'metal', 
        'stone', 'liquid', 'plasma', 
        'ice', 'feather', 'cells');
    static var wingsizeDescr =
        "Defines whether a unit has wings, "
        +"and if so, how large they are.";
    static var wingsizes = new Array(
        'none', 'small','normal','huge'
    );
    static var willDescr = 
        "Defines unit's behaviour in danger"
        +" situations.";
    static var wills = new Array(
        'weak', 'normal','strong','determined'
    );
    static var orders = new Array(
        'lawful', 'neutral', 'chaotic'
    );
    static var sides = new Array(
        'evil', 'neutral', 'good'
    );
    
    static var ages = new Array('child', 'young', 'adult', 'mature', 'old', 'ancient');
    static var masteryLevels = new Array(
        'sad sack', 'novice', 'below average', 'medium',
        'above average', 'advanced', 'professional', 'great',
        'extraordinary', 'superior' 
    );
    static var vits = masteryLevels;
    static var spds = masteryLevels;
    static var dexs = masteryLevels;
    static var atts = masteryLevels;
    static var ints = masteryLevels;
    static var wizs = masteryLevels;
    static var defs = masteryLevels;
    static var vitDescr = "vitality - overall constitution and stamina level.";
    static var spdDescr = "speed - overall swiftness and ability to perform fast actions.";
    static var dexDescr = "dexterity - overall briskbess and agility.";
    static var attDescr = "attack - overall fight mastery and battle skills.";
    static var intDescr = "intellect - overall knowledge and education level.";
    static var wizDescr = "wizzardy - overall magic efficiency and witchcraft practice.";
    static var defDescr = "defence - overall toughness and resistance level.";

    // resist are showing a bar-length of status resisting
    // where fireball + 40 flaming, 30 - base usuall unit (5 - if wooden) (250 - if flaming) (400 - world max resist)
    // 

    static var hpDescr = "hit points";// *
    static var pdefDescr = "% physical defence";
    static var ddgDescr = "dodge";
    static var wtcrDescr = "weight carrying";// *
    static var firresDescr = "fire resist";
    static var eleresDescr = "electricity resist";
    static var froresDescr = "frost resist";
    static var toxresDescr = "toxic resist";// *
    static var corresDescr = "corrosion resist";
    static var iniDescr = "initiative";
    static var chaDescr = "charisma";
    static var spsDescr = "spell cast speed";
    static var accDescr = "accuracy";// *
    static var atsDescr = "attack speed";
    static var arsDescr = "att. recover speed";
    static var pdmgDescr = "physical damage";
    static var mdmgDescr = "magical damage";// *
    static var msDescr = "movement speed";// *
    static var stresDescr = "stunlock resist";// * head-self-defence
    static var itusDescr = "item using speed";
        
    // </statDescriptionAndLevels>


    static function minorOf(arr:Array){
        return Math.round(arr.length / 2 - .99);
    }
    static function defaultOf(arr:Array){
        return 0;
    }
    static var maxPossibleCarryWeightStunlock = 200;
    static function setStats (o){
        //o.stats = new Array();
        o.bornStats = getDefaultBornStats();
        o.rpgStats = getDefaultRpgStats();
        // returns 0 if free, 1 if fully weight, >1 - if overweight
        o.carryWeight = function(){return (this.rpgStats.weight) / this.calcStats.wtcr;}
        o.weightKg = function(){return this.rpgStats.weight / maxPossibleCarryWeightStunlock;}
        o.yearsOld = function(){return this.rpgStats.age / this.bornStats.ageMax;}
        o.calcStats = getDefaultCalculatedStats();
        o.calcStats.recalculate(o);
    }
    static function getDefaultBornStats():Object{
        var bs = new Object();
        bs.race = 0;
        bs.size = minorOf(sizes);
        bs.material = new Array(); 
        bs.material.push(defaultOf(materials));
        bs.wingsize = defaultOf(wingsizeDescr);
        bs.will = minorOf(wills);
        bs.order = minorOf(orders);
        bs.side = minorOf(sides);
        // base chars
        bs.hpBase = 20;
        bs.hpMax = 50;
        bs.wtcrMax = 95;       // max possible carry weight is in maxPossibleCarryWeightStunlock;
        bs.toxresMax = 120;    // humans limit
        bs.accBase = 2; // has eyes, 0 - has no eye, 4 - bird or elf eye
        bs.mdmgBase = 0;
        bs.msMax = 6; // ~25 m/s
        bs.stresBase = 60;
        return bs;
    }

    static function getDefaultRpgStats():Object{
        var bs = new Object();
        bs.vit = bs.spd = bs.dex = bs.att = bs.int = bs.wiz = bs.def = 3;
        bs.age = minorOf(ages);
        bs.weight = 10;
        return bs;
    }
    static function addSymbol(S, C):String{
        var ar = S.split('\n');
        for (var i = 0; i < ar.length - 1; ++i)
            ar[i] = C + ar[i];
        return ar.join('\n');
    }
    static function getDefaultCalculatedStats():Object{
        var bs = new Object();
        bs.requiresStatsRecalculation = true;
        bs.formulas = new Array();
        bs.hp = bs.pdef = bs.ddg = bs.wtcr = 
        bs.firres = bs.eleres = bs.frores = bs.toxres = 
        bs.corres = bs.ini = bs.sps = bs.acc = bs.ats = 
        bs.ars = bs.pdmg = bs.mdmg = bs.ms = bs.stres = 
        bs.itus = bs.cha = -1;
        bs.catchFormula = function(statName, plusOrMinus/* string, which contains only '-' or '+' */, value){
            if (plusOrMinus == undefined) plusOrMinus = '+';
            // plusOrMinus = plusOrMinus;
            for (var i = 0; i < this.formulas.length; i += 3) 
            if (this.formulas[i] == statName){
                this.formulas[i + 1] += '\n' + plusOrMinus + lastFormula;
                this.formulas[i + 2] +=  addSymbol(lastShowFormula, plusOrMinus);
                return value;
            }
            this.formulas.push(statName, plusOrMinus + lastFormula, addSymbol(lastShowFormula, plusOrMinus));
            return value;
        }
        bs.getFormula = function(statName):String{
            for (var i = 0; i < this.formulas.length; i += 3) if (this.formulas[i] == statName)
                return this.formulas[i + 2];
            return undefined;
        }
        bs.recalculate = function(person){
            // if (!this.requiresStatsRecalculation)
                // return;
            // this.requiresStatsRecalculation = false;
            this.formulas = new Array();
            //' hp . pdef . ddg . wtcr . firres . eleres . frores .
            //  toxres . corres . ini . sps . acc . ats . ars . pdmg
            //  mdmg . ms . stres . itus '
            var bs = person.bornStats;
            calculateStatUsing(person, 'wtcr',   new Array(bs.wtcrMax * .1, bs.wtcrMax * .8, 1, 'vit'));
            calculateStatUsing(person, 'hp', new Array(bs.hpBase, bs.hpMax,  8, 'vit', 1, 'def')); 
            calculateStatUsing(person, 'pdef', new Array(0, 90,  4, 'def', 3, 'vit', 2, 'will')); // + material
            calculateStatUsing(person, 'ddg', new Array(0, 16,  1.5, 'spd', 1, 'dex', .6, 'int'), new Array(0, 8,  1.5, 'size', .7, 'vit')); // - weight
            calculateStatUsing(person, 'firres', new Array(5, 80,  5, 'def', 1, 'wiz', .5, 'dex')); // + material as base
            calculateStatUsing(person, 'eleres', new Array(10, 150,  1, 'wiz')); // + material
            calculateStatUsing(person, 'frores', new Array(60, 360, 1, 'vit', .1, 'spd', 1.5, 'size'));
            calculateStatUsing(person, 'toxres', new Array(15, bs.toxresMax,  1, 'def', .1, 'wiz'));
            calculateStatUsing(person, 'corres', new Array(5, 45,   1, 'def')); // + material
            calculateStatUsing(person, 'ini',
                new Array(0, 10,    2, 'spd', 1, 'int', 1, 'dex', .5, 'def'), new Array(0, 3,   5, 'size', 3, 'vit'));
            calculateStatUsing(person, 'cha', new Array(4, 10,      1, 'int'), new Array(0, 4, 1, 'age', .75, 'wiz'));
            calculateStatUsing(person, 'sps', new Array(1, 10,      5, 'wiz', 3, 'int', 2, 'dex'),
                                    undefined,new Array(0, -2, 'carryWeight')); // - weight
            calculateStatUsing(person, 'acc', new Array(bs.accBase, 10, 2, 'att', 1, 'int', .5, 'dex')); // - distance
            calculateStatUsing(person, 'ats', new Array(0, 10,      2, 'dex', 3, 'spd', 3, 'att'),
                                    undefined,new Array(0, -4, 'carryWeight')); // - weight
            calculateStatUsing(person, 'ars', new Array(0, 10,      5, 'vit', 1, 'spd', 3, 'att'),
                                    undefined,new Array(0, -6, 'carryWeight'));
            calculateStatUsing(person, 'pdmg', new Array(35, 150,   undefined, 'att'));
            calculateStatUsing(person, 'mdmg', new Array(45 + bs.mdmgBase, 175, 5, 'wiz', 1, 'age'), 
                                               new Array(0, 10, undefined, 'int'));
            calculateStatUsing(person, 'ms',  
                new Array(1, bs.msMax * 1.75, 2, 'wingsize', 1, 'size', 2, 'spd', .6, 'vit'), undefined,
                new Array(0, bs.msMax * (-1), 'carryWeight')); // - weight
            calculateStatUsing(person, 'stres', new Array(bs.stresBase, 150,   3, 'vit', 1, 'def', .5, 'dex', 1, 'int'),
                                      undefined,new Array(0, 250, 'weightKg')); // + weight
            calculateStatUsing(person, 'itus',  new Array(1, 10,    4, 'dex', 3, 'spd', 2, 'int'));
        
            // bs.toxresMax = 120;    // humans limit
            // bs.accBase = 2; // has eyes, 0 - has no eye, 4 - bird or elf eye
            // bs.mdmgBase = 0;
            // bs.msMax = 5; // ~25 m/s
            // bs.stresBase = 60;
        }
        return bs;
    }
    static var lastFormula = "";
    static var lastShowFormula = "";
    // positiveArrayFormat = new Array(baseValue, maxValue, k1, statName1, k2, statNam2, .. .. etc);
    // negativeArray = new Array(baseValue, maxValue, k1, statName1, k2, statNam2, .. .. etc);
    // koeffArray = new Array(baseValue, maxValue, valueNormilised1Name, valueNormili2Name, .. .. etc);
    static function calculateStatUsing(person, statName, positiveArray, negativeArray, koeffArray){
        person.calcStats[statName+''] = person.calcStats.catchFormula(statName, '+', calculateUsing(person, positiveArray));
        if (negativeArray != undefined)
            person.calcStats[statName+''] -= person.calcStats.catchFormula(statName, '-', calculateUsing(person, negativeArray));
        if (koeffArray != undefined)
            person.calcStats[statName+''] += person.calcStats.catchFormula(statName, '~', calculateKoefUsing(person, koeffArray));
        person.calcStats[statName+''] = Math.max(0, person.calcStats[statName+'']);
    }
    static function calculateKoefUsing(
        person, 
        paramArr //new Array(baseValue, maxValue, valueNormilised1Name, valueNormili2Name, .. .. etc);
    ){
        var base = paramArr[0], maxValue = paramArr[1], summ = 0, 
        summK = paramArr.length - 2, diagnos = "", diagnoses= '';
        for (var i = 2; i < paramArr.length; ++i){
            var add = person[''+paramArr[i]]();
            summ += add;
            if (diagnos.length > 0) diagnos += ", "; diagnos += paramArr[i];
            var stringValue =  Math.round(add * (maxValue - base) / summK * calculationaccuracy) / calculationaccuracy;
            if (stringValue != 0) diagnoses += stringValue + ' (' + paramArr[i] + ')'
        }
        var res = Math.round((base + (maxValue - base) * summ / summK) * calculationaccuracy) / calculationaccuracy;
        if (res == 0) 
            lastFormula = "not changed by " + diagnos;
        else
            // lastFormula = (base != 0? ( '(base: '+ base+') +' + (res - base)) : (res+ '')) + (', cause by: '+diagnos);
            lastFormula = (base != 0? ( '(base: '+ base+') +' + (res - base)) : (res+ '')) + (' (max:'+(maxValue)+', cause by: '+diagnos+')');
        lastShowFormula = (base != 0? ( base+' (base)\n') : '') + diagnoses;
        return res;
    }
    static function calculateUsing(
        person, 
        paramArr // {base, max, k1 param1name k2 param2name, ...}
    )
    {
        // paramArr = 3, 'vit', 2, 'def'
        // it means min to max in proportion of 
        // (3 * vit / vitMax + 2 * def / defMax) / (2 + 3) *  maxValue + base
        var ksumm = 0, summ = 0, diagnos = "", diagnoses= '', diagnosesValues = new Array(),
            base = paramArr[0],  maxValue = paramArr[1];

        for (var i = 1; i < paramArr.length / 2; ++i){
            var paramk = paramArr[i * 2]; // 3 * 
            var paramName = paramArr[i * 2 + 1];    // vit
            if (paramName == undefined){ continue;}
            if (paramk == undefined) paramk = 1;

            var paramMax = getAllpossibleValues(paramName).length - 1;
            if (paramMax == undefined) paramMax = stats[paramName + "Max"];
            if (isNaN(paramMax)){ trace('Warning: can not define max limit of ' + paramName +', skipping it.'); continue; }
            ksumm += paramk;
            var summAddition = getStat(person, paramName) / paramMax * paramk;
            if (isNaN(summAddition)){
                if (showAlerts) trace('Warning: can not calculate addition caused by "' 
                    + paramName+'" : ' + getStat(person, paramName) 
                    + '/' + paramMax + '*' + paramk + ' = ' + summAddition +', skipping it.'); 
                    continue;
            }else{
                if (diagnos.length > 0) diagnos += ", ";
                diagnos += getString(person, paramName) + " " + paramName;
                diagnosesValues.push(summAddition, getString(person, paramName) + ' ' + paramName);
            }
            summ += summAddition;
        }
        for (var i = 0; i < diagnosesValues.length; i += 2){ 
            var value = Math.round(diagnosesValues[i] / ksumm * (maxValue - base) * calculationaccuracy) / calculationaccuracy;
            if (value != 0) diagnoses += 
                value + ' (' + diagnosesValues[i + 1] +')\n';
        }
        if (maxValue == undefined){
            if (showAlerts) trace('Warning: can not define  max value! Set it to 100 (%).');
            maxValue = 100; 
        }
        if (base == undefined){ 
            if (showAlerts) trace('Warning: can not define base value! Set it to 0.');
            base = 0;
        }
        var res = Math.round((summ / ksumm *  (maxValue - base) + base) * calculationaccuracy) / calculationaccuracy;
        res = Math.max(0, res);
        // lastFormula = (base != 0? ( '(base: '+ base+') +' + (res - base)) : (res+ '')) + (', cause by: '+diagnos);
        lastFormula = (base != 0? ( '(base: '+ base+') +' + (res - base)) : (res+ '')) + (' (max:'+(maxValue)+', cause by: '+diagnos+')');
        lastShowFormula = (base != 0? (base + ' (base)\n') : '') + diagnoses;
        // trace(lastShowFormula);
        return res;
    }
    static function getStatType(statName):String{
        var checkStatName = ' ' + statName + ' ';
        return (bornStats.indexOf(checkStatName) >= 0)?
        'bornStats':((rpgStats.indexOf(checkStatName) >= 0)?
        'rpgStats':((calcStats.indexOf(checkStatName) >= 0)?
        'calcStats' : ''));
    }
    static function getStat(o, statName:String):Number{
        var findIn = getStatType(statName);
        if (findIn == '')
            return 0;
        return o[findIn+''][statName+''];
    }
    static function getString(o, statName):String{
        var statNum = getStat(o, statName);
        if (statNum == undefined) return "inexplicable";
        if (statNum[1] == undefined){
            if (statNum < 0) statNum = 0;
            var res = getAllpossibleValues(statName)[statNum];
            return res == undefined? '' : res;
        }
        var res = "", vars = getAllpossibleValues(statName);
        for (var i =0; i < statNum.length; ++i)
            res += vars[statNum[i]] + (i < statNum.length -1 ?", " : "");
        return res;
    }
    static function getStatString(o, statName):String{
        var interpritation = getString(o, statName);
        var string = interpritation.length > 0 && interpritation != 'undefined'? ('('+ interpritation + ')') : ''; 
        return statName + ': ' + getStat(o, statName) + ' ' + string;
    }
    static function getAllpossibleValues(statName):Array{
        return stats[statName+'s'];
    }
    static function getDesciption(statName):String{
        var desc = stats[statName + 'Descr'];
        return desc == undefined? '?' : desc;
    }
    static function getAligment(T):String{
        var res = getString(T, 'order') + ' ' + getString(T, 'side');
        return res == 'neutral neutral'? 'true neutral' : res;
    }

    static function traceAllStats(person){
        for (var i = 0; i < allStats.length; ++i){
            var st = allStats[i];
            var str = (getStatString(person, st) + ': ' + getDesciption(st));
            trace(str);
            var calc = (calcStats.indexOf(st) >= 0)? person.calcStats.getFormula(st) : undefined;
            if (calc != undefined) trace(calc);
        }
        trace(getAligment(person));
    }

    // array = new Array(vitStatPlus, attStatPlus, . . . , weighStatPlus);
    static function previewStatsChanges(person, statIncreaseArray:Array):Array{
        var statCount = allStats.length,
            wasStats = new Array(statCount), 
            changeStats = new Array(statCount);
        for (var i = 0; i < statCount; ++i) wasStats[i] = getStat(person, allStats[i]);
        applyStatChanges(person, statIncreaseArray);
        for (var i = 0; i < statCount; ++i) changeStats[i] = 
            getStat(person, allStats[i]) - wasStats[i];
        revertStatChanges(person, statIncreaseArray);
        return changeStats;
    }
    static function applyStatChanges(person, statIncreaseArray){
        changeStats(person, statIncreaseArray, true);
    }
    static function revertStatChanges(person, statIncreaseArray){
        changeStats(person, statIncreaseArray, false);
    }
    static function changeStats(person, statIncreaseArray, isPlus){
        for (var i = 0; i < /* rpgStatNames */statIncreaseArray.length; ++i)
            if (isPlus) person.rpgStats[rpgStatNames[i]] += statIncreaseArray[i];
            else        person.rpgStats[rpgStatNames[i]] -= statIncreaseArray[i];
        person.calcStats.recalculate(person);
    }
    static function test(){
        // var T = new Object();
        // setStats(T);
        // traceAllStats(T);
    }
}