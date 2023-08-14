







function blockList=getStartingPointsForParam(obj,varUsage,includeIndirect)
    import slslicer.internal.ParameterDependenceInfo.*;

    paramKey=getParamMapKey(varUsage);
    if~isKey(obj.paramDirectUsersMap,paramKey)
        error('Sldv:DebugUsingSlicer:ParameterNotPresentInModel',getString(message('Sldv:DebugUsingSlicer:ParameterNotPresentInModel')));
    end

    blockList=obj.paramDirectUsersMap(paramKey);
    if includeIndirect


        affectedParamKeys=obj.paramToParamMap(paramKey);


        for i=1:length(affectedParamKeys)
            indirectBlockListInstance=obj.paramDirectUsersMap(affectedParamKeys{i});
            blockList=vertcat(blockList,indirectBlockListInstance);
        end
    end
end
