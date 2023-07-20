function out=sliceMdlMapperObj(method,modelH,mapObj)
    persistent SlicerMapperTable;
    mlock;

    if isempty(SlicerMapperTable)
        SlicerMapperTable=containers.Map('KeyType','double','ValueType','any');
    end

    if nargin<3
        mapObj=[];
    end

    switch(lower(method))
    case 'get'
        if~SlicerMapperTable.isKey(modelH)
            out=[];
        else
            out=SlicerMapperTable(modelH);
        end

    case 'set'
        if isempty(mapObj)
            if SlicerMapperTable.isKey(modelH)
                SlicerMapperTable.remove(modelH);
            end
        else
            SlicerMapperTable(modelH)=mapObj;
        end
    end
end


