class aligment{

    static var parts = new Array('a', 'b', 'c', 'd', 'tx', 'ty');
    static function attachTo(source:MovieClip, target:MovieClip){
        var mat = target.transform.matrix//, curMat = source.transform.matrix, matDiff = curMat;
        mat.concat(target._parent.transform.matrix);
        source.transform.matrix = mat;
        // for (var i = 0; i < parts.length; ++i)
        //     matDiff[parts[i]] = curMat[parts[i]] + (mat[parts[i]] - curMat[parts[i]]) / 1.5;
        // source.transform.matrix = matDiff;
    }



}