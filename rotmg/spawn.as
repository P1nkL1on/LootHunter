class spawn
{
    

    static function create(libraryName:String, newName:String, where:MovieClip):MovieClip{
        if (where == undefined) where = _root;
        if (libraryName == undefined){ ut.log('Can not create movieclip with undefined name!'); return null;}
        var newDepth = where.getNextHighestDepth();
        if (newName == undefined) newName = libraryName + '_' + newDepth;
        var obj = where.attachMovie(libraryName, newName, newDepth);
        if (obj == undefined){ ut.log('Can not create movieclip with name ' + libraryName + '!'); return null; } 
        return obj;
    }
}