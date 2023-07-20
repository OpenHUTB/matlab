






function parameters=getParametersUsedByBlocks(obj,blocks,startingBlock,includeIndirect)
    import slslicer.internal.ParameterDependenceInfo.isIndirectUser;
    parameters=[];
    indirectParamKeys={};
    paramKeys={};



    for idx=1:length(blocks)
        blockSID=Simulink.ID.getSID(blocks(idx));
        if isKey(obj.directUsersParamMap,blockSID)
            paramKeys=horzcat(paramKeys,reshape(obj.directUsersParamMap(blockSID),1,[]));
        end
    end



    if isIndirectUser(startingBlock)
        blockSID=Simulink.ID.getSID(startingBlock);
        if isKey(obj.indirectUsersParamMap,blockSID)


            paramKeys=horzcat(paramKeys,reshape(obj.indirectUsersParamMap(blockSID),1,[]));
        end
    end

    if includeIndirect


        for idx=1:length(paramKeys)
            if isKey(obj.paramsAffectedByParamMap,paramKeys{idx})
                indirectParamKeys=horzcat(indirectParamKeys,reshape(obj.paramsAffectedByParamMap(paramKeys{idx}),1,[]));
            end
        end
    end

    paramKeys=unique(horzcat(paramKeys,reshape(indirectParamKeys,1,[])));

    for idx=1:length(paramKeys)
        parameters=[parameters,obj.paramVarUsageMap(paramKeys{idx})];
    end
end
