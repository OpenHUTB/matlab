function out=slicerMapper(method,modelH,uiObj)
    persistent ModelSlicerObjMap;
    mlock;

    if isempty(ModelSlicerObjMap)
        ModelSlicerObjMap=containers.Map('KeyType','double','ValueType','any');
    end

    if nargin<3
        uiObj=[];
    end



    try
        modelH=get_param(modelH,'Handle');
    catch mex
    end

    switch(lower(method))
    case 'get'
        if~ModelSlicerObjMap.isKey(modelH)
            out=[];
        else
            out=ModelSlicerObjMap(modelH);
        end

    case 'getui'
        if~ModelSlicerObjMap.isKey(modelH)
            out=[];
        else
            obj=ModelSlicerObjMap(modelH);
            out=obj.dlg;
        end

    case 'set'
        if isempty(uiObj)
            if ModelSlicerObjMap.isKey(modelH)
                ModelSlicerObjMap.remove(modelH);
            end
        else
            ModelSlicerObjMap(modelH)=uiObj;
        end
    end
end


