function[result]=actionUpdateMaskDisplayImageFormat(taskobj)







    modelAdvisorObj=taskobj.MAObj;
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);

    fullName=getfullname(modelAdvisorObj.System);
    blockList=getBlocksForImageDisplayCommandUpdate(modelAdvisorObj,fullName);

    if isLibrary(fullName)
        isLocked=strcmp(get_param(bdroot(fullName),'Lock'),'on');
        if isLocked
            result=generateLockedLibraryMessage(modelAdvisorObj,blockList);
            return;
        end
    end

    fixBlocksForImageDisplayCommandUpdate(blockList);
    result=generateSuccessMessage(modelAdvisorObj);
end

function[isValid]=isLibrary(libraryName)
    isValid=false;

    try
        mdlInfo=Simulink.MDLInfo(bdroot(libraryName));
    catch
        return;
    end

    if~mdlInfo.IsLibrary
        return;
    end

    isValid=true;
end


function fixBlocksForImageDisplayCommandUpdate(blockList)
    for i=1:length(blockList)
        block=blockList{i};
        originalMaskDisplayString=get_param(block,'MaskDisplay');
        [displayStringChanged,fixedMaskDisplayString]=slprivate('removeImageImreadFromMaskDisplayString',originalMaskDisplayString);
        if displayStringChanged
            set_param(block,'MaskDisplay',fixedMaskDisplayString);
        end
    end
end


function[blockList]=getBlocksForImageDisplayCommandUpdate(modelAdvisorObj,system)
    blockList={};


    masks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','off','Mask','on');
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


function[template]=generateSuccessMessage(modelAdvisorObj)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);

    statusMessage={};
    statusMessage{end+1}=DAStudio.message('ModelAdvisor:engine:MASuccessUpdatingListMasksToUpdateForCheckMaskDisplayImageFormat');
    template.setSubResultStatusText(statusMessage);
    template.setSubResultStatus('pass');

    modelAdvisorObj.setActionResultStatus(true);
    modelAdvisorObj.setActionEnable(false);
end


function[template]=generateLockedLibraryMessage(modelAdvisorObj,blocksNeedingUpdate)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    template.setSubBar(false);
    template.setInformation(DAStudio.message('ModelAdvisor:engine:MACheckMaskDisplayImageFormat'));

    template.setSubResultStatus('warn');
    template.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MALockedLibraryWarningCheckMaskDisplayImageFormat'));
    template.setListObj(blocksNeedingUpdate);

    modelAdvisorObj.setActionResultStatus(false);
    modelAdvisorObj.setActionEnable(true);
end
