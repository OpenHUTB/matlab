function[objExists,storageClass,isModelWSObject]=evalObject(modelName,objName)




    obj=[];
    storageClass='';
    objExists=false;
    isModelWSObject=false;
    if~ischar(objName)&&~isstring(objName)
        return;
    end
    if existsInGlobalScope(modelName,objName)
        obj=evalinGlobalScope(modelName,objName);
    else
        hws=get_param(modelName,'modelworkspace');
        if hws.hasVariable(objName)
            obj=hws.evalin(objName);
            isModelWSObject=true;
        end
    end
    if~isempty(obj)
        if isa(obj,'Simulink.Signal')
            objExists=true;
            storageClass=obj.CoderInfo.StorageClass;
        elseif isa(obj,'Simulink.Parameter')
            objExists=true;
            storageClass=obj.CoderInfo.StorageClass;
        end
    end
end
