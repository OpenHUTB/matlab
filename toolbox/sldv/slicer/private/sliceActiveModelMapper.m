function[out,isTopModel]=sliceActiveModelMapper(method,modelHs,mapObj)
    persistent SlicerMapperTable;
    persistent TopModelHMap;
    mlock;

    if isempty(SlicerMapperTable)
        SlicerMapperTable=containers.Map('KeyType','double','ValueType','any');
        TopModelHMap=containers.Map('KeyType','double','ValueType','double');
    end

    if nargin<3
        mapObj=[];
    end

    switch(lower(method))
    case 'get'
        if~SlicerMapperTable.isKey(modelHs)
            out=[];
            isTopModel=false;
        else
            out=SlicerMapperTable(modelHs);
            isTopModel=(modelHs==TopModelHMap(modelHs));
        end

    case 'set'
        if isempty(mapObj)
            for mdlH=modelHs(:)'
                if SlicerMapperTable.isKey(mdlH)
                    SlicerMapperTable.remove(mdlH);
                    TopModelHMap.remove(mdlH);
                end
            end
        else
            TopModelH=modelHs(1);
            TopModelHMap(TopModelH)=TopModelH;
            for mdlH=modelHs(:)'
                SlicerMapperTable(mdlH)=mapObj;
                TopModelHMap(mdlH)=TopModelH;
            end
        end
    end
end


