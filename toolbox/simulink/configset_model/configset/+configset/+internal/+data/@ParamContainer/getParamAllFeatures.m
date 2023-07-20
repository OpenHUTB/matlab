function out=getParamAllFeatures(obj,name)



    if~obj.ParamMap.isKey(name)
        out=[];
    else
        out=obj.ParamMap(name);
    end


