function[aResultDescription]=checkOldMaskedBuiltInBlocks(aLibName)




    aResultDescription={};
    aModelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(aLibName);

    if~i_IsValidLibrary(aLibName)
        aResultDescription{end+1}=i_PassStatus(aModelAdvisorObj,'ModelAdvisor:engine:MA_MaskedBlocks_CheckLibraryContext');
        return;
    end

    aBlockList=i_FindMaskedBuiltInBlocks(aLibName);
    if isempty(aBlockList)
        aResultDescription{end+1}=i_PassStatus(aModelAdvisorObj,'ModelAdvisor:engine:MA_MaskedBlocks_NoMaskedBuiltinBlocks');
        return;
    end

    aBlocksNeedingUpdate=i_BlocksNeedingUpdate(aBlockList);
    if isempty(aBlocksNeedingUpdate)
        aResultDescription{end+1}=i_PassStatus(aModelAdvisorObj,'ModelAdvisor:engine:MA_MaskedBlocks_NoMaskedBuiltinBlocks');
        return;
    end

    aResultDescription{end+1}=i_FailStatus(aModelAdvisorObj,aBlocksNeedingUpdate);
end


function[bIsValidLibrary]=i_IsValidLibrary(aLibName)
    bIsValidLibrary=false;

    try
        aMdlInfo=Simulink.MDLInfo(bdroot(aLibName));
    catch
        return;
    end

    if~(aMdlInfo.IsLibrary)
        return;
    end

    if(str2double(aMdlInfo.SimulinkVersion)>=7.8)
        return;
    end

    bIsValidLibrary=true;
end


function[aBlockList]=i_FindMaskedBuiltInBlocks(aLibName)


    aBlockList=find_system(aLibName,'SkipLinks','on','LookUnderMasks','off',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','off','Mask','on','LinkStatus','none');
    aBlkTypes=get_param(aBlockList,'BlockType');
    aBlockList(strcmp(aBlkTypes,'SubSystem')|strcmp(aBlkTypes,'S-Function')|strcmp(aBlkTypes,'M-S-Function')|strcmp(aBlkTypes,'ModelReference'))=[];
    aBlockList=get_param(aBlockList,'Handle');

    if~iscell(aBlockList)
        aBlockList={aBlockList};
    end
end


function[aInfo]=i_PopulateRequiredInfo(aBlockHdl)
    aInfo.aDialogParameters=get_param(aBlockHdl,'IntrinsicDialogParameters');
    aInfo.aMaskWorkspaceVars=get_param(aBlockHdl,'MaskWSVariables');
    aInfo.aPromotableParameters=Simulink.Mask.getPromotableParameters(aBlockHdl,0);
end


function[bNeedsToBePromoted]=i_NeedsToBePromoted(aPromotableParameter,aInfo)

    aIntrinsicParameter=aInfo.aDialogParameters.(aPromotableParameter.m_Name);
    if(isempty(find(strcmp(aIntrinsicParameter.Attributes,'link-instance'),1)))
        bNeedsToBePromoted=false;
        return;
    end


    for i=1:length(aInfo.aMaskWorkspaceVars)
        if(strcmp(aInfo.aMaskWorkspaceVars(i).Name,aPromotableParameter.m_Value))
            bNeedsToBePromoted=false;
            return;
        end
    end

    bNeedsToBePromoted=true;
end


function[aBlocksNeedingUpdate]=i_BlocksNeedingUpdate(aBlockList)
    aBlocksNeedingUpdate={};

    for i=1:length(aBlockList)
        if i_BlockNeedsUpdate(aBlockList{i})
            aBlocksNeedingUpdate{end+1}=aBlockList{i};
        end
    end
end


function[bIsAlreadyUpdated]=i_IsAlreadyUpdated(aBlockHdl)
    aStyleString=get_param(aBlockHdl,'MaskStyleString');
    bIsAlreadyUpdated=contains(aStyleString,'promote(');
end


function[bNeedsUpdate]=i_BlockNeedsUpdate(aBlockHdl)
    bNeedsUpdate=false;

    if i_IsAlreadyUpdated(aBlockHdl)
        return;
    end

    aInfo=i_PopulateRequiredInfo(aBlockHdl);
    for i=1:length(aInfo.aPromotableParameters)
        if i_NeedsToBePromoted(aInfo.aPromotableParameters{i},aInfo)
            bNeedsUpdate=true;
            return;
        end
    end
end


function[aTemplate]=i_PassStatus(aModelAdvisorObj,aMessageId)
    aTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    aTemplate.setSubBar(false);
    aTemplate.setInformation(DAStudio.message('ModelAdvisor:engine:MACheckOldMaskedBuiltinBlocks'));

    aTemplate.setSubResultStatus('pass');
    aTemplate.setSubResultStatusText(DAStudio.message(aMessageId));

    aModelAdvisorObj.setCheckResultStatus(true);
end


function[aTemplate]=i_FailStatus(aModelAdvisorObj,aBlocksNeedingUpdate)
    aTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    aTemplate.setSubBar(false);
    aTemplate.setInformation(DAStudio.message('ModelAdvisor:engine:MACheckOldMaskedBuiltinBlocks'));

    aTemplate.setSubResultStatus('warn');
    aTemplate.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MA_MaskedBlocks_ListMaskedBuiltinBlocks',DAStudio.message('ModelAdvisor:engine:MAUpdateButtonCheckOldMaskedBuiltinBlocks')));
    aTemplate.setListObj(aBlocksNeedingUpdate);

    aModelAdvisorObj.setCheckResultStatus(false);
    aModelAdvisorObj.setActionEnable(true);
end


%#ok<*AGROW>
%#ok<*CTCH>
