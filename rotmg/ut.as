class ut
{

    static function log(message){
        trace(message);
    }

    static function setDefaultValuesIfMissing(args:Array, defaultValues:Array){
        if (defaultValues == undefined || defaultValues.length == 0)
            return args;
        var iMax = Math.max(args.length, defaultValues.length);
        for (var i = 0; i < iMax; ++i)
            if (args[i] == undefined && defaultValues[i] != undefined){
                args[i] = defaultValues[i];
            }
        return args;
    }

}