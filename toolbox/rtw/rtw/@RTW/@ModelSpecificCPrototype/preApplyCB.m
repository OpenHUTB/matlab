function[status,errMsg]=preApplyCB(hObj)





    status=1;
    errMsg='';

    if~isempty(hObj.cache)

        hObj.Data=hObj.cache.Data;
        hObj.FunctionName=hObj.cache.FunctionName;
        hObj.InitFunctionName=hObj.cache.InitFunctionName;
        hObj.ModelHandle=hObj.cache.ModelHandle;
        hObj.cache=[];
    end

