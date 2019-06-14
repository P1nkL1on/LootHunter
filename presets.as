class presets{
    static function getRandomElemnt(arr:Array):Number{
        return random(arr.length);
    }
    static function getCommonlyFirstElement(arr:Array):Number{
        if (random(101) < 75)
            return 0;
        return random(arr.length - 1) + 1;
    }

    static function getName (){
        var prefix = stats.raceSizePrefix[getCommonlyFirstElement(stats.raceSizePrefix)];
        var alivePrefix = stats.raceAlivePrefixs[getCommonlyFirstElement(stats.raceAlivePrefixs)];
        var race = stats.races[getRandomElemnt(stats.races)];
        var prof = stats.proffesions[getRandomElemnt(stats.proffesions)];
        return prefix + ((prefix.length > 0)? ' ' : '')
            + alivePrefix + ((alivePrefix.length > 0)? ' ' : '')
            + race + ((prof.length > 0)? ' ' : '')
            + prof;
    }
}