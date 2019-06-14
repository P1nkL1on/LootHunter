
// function Update(){						//обновл¤ет стэк консоли в соответсвтвии с последними тьебовани¤ми. ѕо запросу переменной 'requireUpdate'
// 	stackTXT.text = ""; 	color_zones = new Array(); color_zones.push(0);
	
// 	for (var i=nowInStack; i<nowInStack + StackLong; i++){ 
// 		stackTXT.text += stack[i]+"\n";  color_zones.push((stackTXT.text+"").length);
// 	}
// 	for (var i=0; i<StackLong; i++){ 
// 		C = (stack[(i)+nowInStack]+"").charAt(0);	//first letter of row 
// 		clr = 0; if (C=='*')clr = 1; if (C=='#')clr = 3; if (C=='@')clr = 2; if (C=='~')clr = 4;
// 		NewColor.color = colors[clr]; stackTXT.setTextFormat(color_zones[i], color_zones[i+1], NewColor);
// 	}
// }

class console{
    static var neutralColor = 0xCCCCCC;
    static var neutralDarkColor = 0x555555;

    static var vitColor = 0x6FAD30;
    static var spdColor = 0x6FC2E6;
    static var dexColor = 0xFFA31A;
    static var attColor = 0xB94646;
    static var intColor = 0x2F7BC8;
    static var wizColor = 0x6D4BA3;
    static var defColor = 0x12E4BA;

    static var plusColor = 0x9AE052;
    static var minusColor = 0xF14141;

    static function writeStats(person, textBox1, textBox2, changes:Array){
        var showStatsAsNumbers = true, bornCount = 5, rpgCount = 10;

        var statColorArray = new Array(), statCalcColorArray = new Array();
        for (var i = 0; i < bornCount + rpgCount; ++i){
            var st = stats.allStats[i], clr = console[st + 'Color'];
            if (clr == undefined) clr = neutralDarkColor;
            var str = stats.getString(person, st), adding = getAddString(changes[i]);
        
            statColorArray.push(clr, st, neutralColor, ': ' 
                + (str != undefined && (i <= bornCount || !showStatsAsNumbers)?
                   str : (stats.getStat(person, st))),
                   getColor(adding), ' ' + adding+ ((i == bornCount)? '\n\n' : '\n'));
        }
        for (var i = bornCount + rpgCount; i < stats.allStats.length; ++i){
            var st = stats.allStats[i], clr = neutralDarkColor,
                stName = stats.getDesciption(st), adding = getAddString(changes[i]); 

            if (stName.indexOf('-') >= 0) stName = stName.slice(0, stName.indexOf('-') - 1);
            statCalcColorArray.push(
                clr, stName + ': ', 
                neutralColor, stats.getStat(person, st),
                getColor(adding), ' ' + adding+'\n');
        }
        textBox1.text = textBox2.text = "";
        writeWithColor(textBox1, statColorArray);
        writeWithColor(textBox2, statCalcColorArray);
        textBox1.person = textBox2.person = person;
    }
    static function getAddString(value){
        var res = (value != undefined && value != 0)? (value+'') : '';
        if (res == 'NaN') res = '';
        if (res.charAt(0) != '-' && res.length > 0) res = '+' + res;
        return res;
    }
    static function getColor(adding:String){
        var addColor = 0xFFFFFF;
        if (adding.charAt(0) == '-') addColor = minusColor; else if (adding.length > 0)addColor = plusColor;
        return addColor;
    }
    // arr = new Array(0xffaabb, 'okey', 0xaabb11, 'next');
    static var textFormat = new TextFormat();
    static function writeWithColor(textBox, array){
        var zones = new Array(), text = "";
        zones.push(0);
        for (var i = 1; i < array.length; i += 2){
            text += array[i];
            zones.push(text.length);
        }
        textBox.text += text;
        for (var i = 1; i < zones.length; ++i){
            textFormat.color = array[(i - 1) * 2];
            textBox.setTextFormat(zones[i- 1], zones[i], textFormat);
        }
    }

    static var crs = null;
    static function becomeCursor(cursor, textBox){
        cursor.info._visible = false; cursor._alpha = 100; Mouse.hide();
        cursor.timer = 0;
        // cursor.person = null;
        // cursor.statName = '';
        cursor.tb = textBox; cursor.prevStatName = null;
        cursor.fontSize = 27;
        cursor.findHittest = function(){
            var foundAnything = false;
            this.prevStatName = this.statName;
                for (var i = 0; i < stats.allStats.length - 15; ++i)
                    if (this._y > this.fontSize * i && this._y <= this.fontSize * (i + 1)){
                        foundAnything = true;
                        this.person = this.tb.person;
                        if (this._x > this.tb._x + this.tb._parent._x)
                               this.statName = stats.allStats[15 + i];
                        else   this.statName = stats.allStats[i];
                    }
                
            if (!foundAnything){
                this.statName = ''; this.person = null;
            }
        }
        cursor.onEnterFrame = function(){
            this._x = _root._xmouse;
            this._y = _root._ymouse;
            this.findHittest();
            if (this.person != null && this.statName != '')
                this.timer ++; else { this.timer = 0; this.hideText(); }
            if (this.timer == 30 || (this.timer > 30 && this.prevStatName != this.statName))
                this.showText(
                    stats.getDesciption(this.statName) + '\n' + 
                    this.person.calcStats.getFormula(this.statName)
                );
        }
        cursor.showText = function(text:String){
            var tf = new TextFormat();
            this.info._visible = true;
            this.info.text = text;
            var p = text.split('\n'), prevL = 0;
            for (var i = 0; i < p.length; ++i){
                var L = prevL + p[i].length + 1;
                tf.color = (p[i].charAt(0) == '-')? minusColor : ((p[i].charAt(0) == '+')? plusColor : neutralColor);
                this.info.setTextFormat(prevL, L + 1, tf);    
                prevL = L;
            }
        }
        cursor.hideText = function(){
            this.info._visible = false;
            this.info.text = "";
        }
        crs = cursor;
    }
}