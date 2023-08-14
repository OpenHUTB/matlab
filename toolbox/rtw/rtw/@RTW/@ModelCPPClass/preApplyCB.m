function[status,errMsg]=preApplyCB(hObj)






    status=1;
    errMsg='';

    if~isempty(hObj.cache)
        hObj.Data=hObj.cache.Data;
        hObj.FunctionName=hObj.cache.FunctionName;
        hObj.ModelClassName=hObj.cache.ModelClassName;
        hObj.ClassNamespace=hObj.cache.ClassNamespace;
        hObj.cache=[];
    end

