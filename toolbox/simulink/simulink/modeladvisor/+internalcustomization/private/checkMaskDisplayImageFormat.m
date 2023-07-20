function[result]=checkMaskDisplayImageFormat(system)






    result={};
    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    blockList=getBlocksForImageDisplayCommandUpdate(modelAdvisorObj,system);
    if isempty(blockList)
        result{end+1}=generateNoUpdateRequiredMessage(modelAdvisorObj);
    else
        result{end+1}=generateFailureMessage(modelAdvisorObj,blockList);
    end
end


function[blockList]=getBlocksForImageDisplayCommandUpdate(modelAdvisorObj,system)
    blockList={};


    masks=find_system(system,'LookUnderMasks','all','FollowLinks','off',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookInsideSubsystemReference','off','Mask','on');
    for i=1:length(masks)
        linkStatus=get_param(masks{i},'LinkStatus');
        if isequal(linkStatus,'resolved')
            continue;
        end

        originalMaskDisplayString=get_param(masks{i},'MaskDisplay');
        [displayStringChanged,~]=slprivate('removeImageImreadFromMaskDisplayString',originalMaskDisplayString);
        if displayStringChanged
            blockList{end+1}=masks{i};%#ok<AGROW>
        end
    end
    blockList=modelAdvisorObj.filterResultWithExclusion(blockList);
end


function[template]=generateNoUpdateRequiredMessage(modelAdvisorObj)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);
    template.setInformation(DAStudio.message('ModelAdvisor:engine:MACheckMaskDisplayImageFormat'));

    template.setSubResultStatus('pass');
    template.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MAEmptyListMasksToUpdateForCheckMaskDisplayImageFormat'));

    modelAdvisorObj.setCheckResultStatus(true);
end


function[template]=generateFailureMessage(modelAdvisorObj,blocksNeedingUpdate)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);
    template.setInformation(DAStudio.message('ModelAdvisor:engine:MACheckMaskDisplayImageFormat'));
    template.setSubResultStatus('warn');
    template.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MAListMasksToUpdateForCheckMaskDisplayImageFormat'));
    template.setRecAction(DAStudio.message('ModelAdvisor:engine:MARecommendationCheckMaskDisplayImageFormat',DAStudio.message('ModelAdvisor:engine:MAUpdateButtonCheckMaskDisplayImageFormat')));
    template.setListObj(blocksNeedingUpdate);
    modelAdvisorObj.setCheckResultStatus(false);
    modelAdvisorObj.setActionEnable(true);
end
