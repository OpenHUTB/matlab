function mapInfo=getCustomFuncInfo








    mapInfo={};

    mapInfo{end+1}='SqrtDesignErrorDetection';
    mapInfo{end+1}='sqrtInputRange.m';

    mapInfo{end+1}='MathDesignErrorDetection';
    mapInfo{end+1}='mathFcnInputRange.m';

    if slavteng('feature','Hisl_0005')
        mapInfo{end+1}='ProductDesignErrorDetection';
        mapInfo{end+1}='productInputRange.m';
    end
end
