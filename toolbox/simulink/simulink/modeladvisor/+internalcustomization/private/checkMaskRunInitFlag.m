function[result]=checkMaskRunInitFlag(system)




    result={};
    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    [blockList,excludedBlockList]=getBlocksForRunInitFlagUpdate(modelAdvisorObj,system);
    if isempty(blockList)
        result{end+1}=generateNoUpdateRequiredMessage(modelAdvisorObj);
    else
        result{end+1}=generateFailureMessage(modelAdvisorObj,blockList);
        if~isempty(excludedBlockList)
            result{end+1}=generateExclusionMessage(modelAdvisorObj,excludedBlockList);
        end
    end
end


function[blockList,excludedBlockList]=getBlocksForRunInitFlagUpdate(modelAdvisorObj,system)
    blockList={};
    excludedBlockList={};
    masks=find_system(system,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','off','LookInsideSubsystemReference','off','Mask','on');
    for i=1:length(masks)
        linkStatus=get_param(masks{i},'StaticLinkStatus');
        if(~strcmpi(linkStatus,'none'))
            continue;
        end

        maskObj=get_param(masks{i},'MaskObject');


        if maskObj.isAutoGeneratedModelBlockMask()
            continue;
        end

        wsVars=maskObj.getWorkspaceVariables();
        cmdList={};
        parseType='parseForDependencyAndCommands';
        try
            [~,wsDependent,~]=parseMaskDisplay(maskObj.Display,wsVars,cmdList,parseType);
        catch
            excludedBlockList{end+1}=masks{i};%#ok<AGROW>
            continue;
        end
        if((~wsDependent&&~strcmp(maskObj.RunInitForIconRedraw,'off'))...
            ||(wsDependent&&~strcmp(maskObj.RunInitForIconRedraw,'on')))
            blockList{end+1}=masks{i};%#ok<AGROW>
        end
    end
    blockList=modelAdvisorObj.filterResultWithExclusion(blockList);
end


function[template]=generateNoUpdateRequiredMessage(modelAdvisorObj)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);
    template.setInformation(DAStudio.message('ModelAdvisor:engine:MACheckMaskRunInitFlag'));

    template.setSubResultStatus('pass');
    template.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MAEmptyListMasksToUpdateForCheckMaskRunInitFlag'));

    modelAdvisorObj.setCheckResultStatus(true);
end


function[template]=generateFailureMessage(modelAdvisorObj,blocksNeedingUpdate)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);
    template.setInformation(DAStudio.message('ModelAdvisor:engine:MACheckMaskRunInitFlag'));
    template.setSubResultStatus('warn');
    template.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MAListMasksToUpdateForCheckMaskRunInitFlag'));
    template.setRecAction(DAStudio.message('ModelAdvisor:engine:MARecommendationCheckMaskRunInitFlag',DAStudio.message('ModelAdvisor:engine:MAUpdateButtonCheckMaskRunInitFlag')));
    template.setListObj(blocksNeedingUpdate);
    modelAdvisorObj.setCheckResultStatus(false);
    modelAdvisorObj.setActionEnable(true);
end


function[template]=generateExclusionMessage(modelAdvisorObj,blocksExcluded)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);
    template.setSubResultStatus('warn');
    template.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MAListMasksExcludedForCheckMaskRunInitFlag'));
    template.setListObj(blocksExcluded);
    modelAdvisorObj.setCheckResultStatus(false);
    modelAdvisorObj.setActionEnable(true);
end