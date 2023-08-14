function[varExists,object,isModelWorkspace]=evalObject(modelName,objectName)






    modelWorkSpace=get_param(modelName,'ModelWorkspace');

    varExists=false;
    object=[];
    isModelWorkspace=false;

    if~isvarname(objectName)

        return;
    end


    if~isempty(modelWorkSpace)
        varExistsInModelWS=modelWorkSpace.hasVariable(objectName)==1;
        if varExistsInModelWS
            object=slprivate('modelWorkspaceGetVariableHelper',modelWorkSpace,objectName);
            isModelWorkspace=true;
            varExists=true;
            return;
        end
    end

    if existsInGlobalScope(modelName,objectName)
        if~Simulink.data.isSupportedEnumClass(objectName)

            object=evalinGlobalScope(modelName,objectName);
            varExists=true;
            return;
        end
    end
end
