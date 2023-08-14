function[constraints,constraintVariables]=createGroupConstraints(model,activeGroups,inactiveGroups,specs,constraintFactory)








    uid2gID=fxptds.Utils.uniqueKeyToGroupID([activeGroups,inactiveGroups]);


    groupId2GroupInfo=cpopt.internal.createGroupIdToGroupInfoMap(activeGroups,inactiveGroups);




    refMdls=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        options=Simulink.FindOptions('IncludeCommented',false,...
        'MatchFilter',@Simulink.match.activeVariants);
    else
        options=Simulink.FindOptions('IncludeCommented',false,'Variants','ActiveVariants');
    end
    blkHandles=Simulink.findBlocks(refMdls,options);
    blks=get_param(blkHandles,'Object')';


    cpopt.internal.addSpecificationsToGroupInfos(specs,groupId2GroupInfo);


    eai=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
    constraints={};
    for blkIndex=1:length(blks)
        blkObj=blks{blkIndex};
        autoscaler=eai.getAutoscaler(blkObj);


        if~cpopt.internal.checkNeedsConstraint(blkObj)
            continue;
        end


        cpopt.internal.updatePortGroupComplexities(blkObj,autoscaler,uid2gID,groupId2GroupInfo);


        cpopt.internal.updateKnownGroupTypes(blkObj,autoscaler,uid2gID,groupId2GroupInfo);


        inputGroupIds=cpopt.internal.getInputGroups(blkObj,autoscaler,uid2gID);
        inputGroupInfos=cpopt.internal.getInputGroupInfos(inputGroupIds,groupId2GroupInfo);


        pathItemToGroupId=cpopt.internal.getPathToGroupMapping(blkObj,autoscaler,uid2gID);
        pathItemToGroupInfo=cpopt.internal.getPathToGroupInfoMapping(pathItemToGroupId,groupId2GroupInfo);


        constraints{end+1}=constraintFactory.makeConstraint(blkObj,inputGroupInfos,pathItemToGroupInfo);%#ok<AGROW>
    end


    redundantIdx=cellfun(@(constraint)constraint.isRedundant(),constraints,'UniformOutput',true);
    constraints(redundantIdx)=[];
    constraintVariables=groupId2GroupInfo.values;
end


