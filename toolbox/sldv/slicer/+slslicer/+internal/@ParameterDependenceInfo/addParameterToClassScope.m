





function addParameterToClassScope(obj,varUsages)
    import slslicer.internal.ParameterDependenceInfo.*;
    parameters=getPopulatedVarUsages(obj.model,varUsages);

    existingParamKeys=keys(obj.paramVarUsageMap);
    currNumParams=length(parameters);
    exists=false(currNumParams,1);
    for idx=1:length(parameters)
        paramKey=getParamMapKey(parameters(idx));
        exists(idx)=any(strcmp(existingParamKeys,paramKey));
    end


    parameters(exists)=[];
    if~isempty(parameters)

        [paramToParamMapAdditional,paramDirectUsersMapAdditional,paramVarUsageMapAdditional,paramsAffectedByParamMapAdditional,directUsersParamMapAdditional,indirectUsersParamMapAdditional]=generateParamDataStructures(obj.model,parameters);

        obj.paramToParamMap=mergeMaps(obj.paramToParamMap,paramToParamMapAdditional);
        obj.paramDirectUsersMap=mergeMaps(obj.paramDirectUsersMap,paramDirectUsersMapAdditional);
        obj.paramVarUsageMap=[obj.paramVarUsageMap;paramVarUsageMapAdditional];
        obj.paramsAffectedByParamMap=mergeMaps(obj.paramsAffectedByParamMap,paramsAffectedByParamMapAdditional);
        obj.directUsersParamMap=mergeMaps(obj.directUsersParamMap,directUsersParamMapAdditional);
        obj.indirectUsersParamMap=mergeMaps(obj.indirectUsersParamMap,indirectUsersParamMapAdditional);
    else


        return;
    end
end
