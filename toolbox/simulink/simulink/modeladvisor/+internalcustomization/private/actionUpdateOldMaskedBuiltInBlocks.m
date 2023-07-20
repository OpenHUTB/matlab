function[aResultDescription]=actionUpdateOldMaskedBuiltInBlocks(aTaskObj)




    aResultDescription={};

    aModelAdvisorObj=aTaskObj.MAObj;
    aLibName=getfullname(aModelAdvisorObj.System);

    aTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    aTemplate.setSubBar(false);

    if~i_IsValidLibrary(aLibName)
        return;
    end

    aBlockList=i_FindMaskedBuiltInBlocks(aLibName);
    if isempty(aBlockList)
        return;
    end

    aBlocksNeedingUpdate=i_BlocksNeedingUpdate(aBlockList);
    if isempty(aBlocksNeedingUpdate)
        return;
    end

    i_UnlockLibrary(aLibName);
    i_UpdateAllBlocks(aBlocksNeedingUpdate);
    aAllLinkBlocks=i_BlocksHavingLinks(aLibName,aBlocksNeedingUpdate);

    aResultDescription=i_PassStatus(aModelAdvisorObj,aAllLinkBlocks);
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


    aBlockList=find_system(aLibName,'LookUnderMasks','off',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookInsideSubsystemReference','off','FollowLinks','off',...
    'Mask','on','LinkStatus','none');
    aBlkTypes=get_param(aBlockList,'BlockType');
    aBlockList(strcmp(aBlkTypes,'SubSystem')|strcmp(aBlkTypes,'S-Function')|strcmp(aBlkTypes,'M-S-Function')|strcmp(aBlkTypes,'ModelReference'))=[];
    aBlockList=get_param(aBlockList,'Handle');

    if~iscell(aBlockList)
        aBlockList={aBlockList};
    end
end


function i_UnlockLibrary(aLibName)
    set_param(bdroot(aLibName),'Lock','off');
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


function[bIsAlreadyMigrated]=i_IsAlreadyUpdated(aBlockHdl)
    aStyleString=get_param(aBlockHdl,'MaskStyleString');
    bIsAlreadyMigrated=contains(aStyleString,'promote(');
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


function i_UpdateAllBlocks(aBlocksNeedingUpdate)
    for i=1:length(aBlocksNeedingUpdate)
        i_UpdateBlock(aBlocksNeedingUpdate{i});
    end
end


function i_UpdateBlock(aBlockHdl)
    aInfo=i_PopulateRequiredInfo(aBlockHdl);

    aNeedsToBePromotedParameters={};
    for i=1:length(aInfo.aPromotableParameters)
        if i_NeedsToBePromoted(aInfo.aPromotableParameters{i},aInfo)
            aNeedsToBePromotedParameters{end+1}=aInfo.aPromotableParameters{i};
        end
    end

    if isempty(aNeedsToBePromotedParameters)
        return;
    end

    aStyles=get_param(aBlockHdl,'MaskStyles');
    aNameString=get_param(aBlockHdl,'MaskVariables');
    aPrompts=get_param(aBlockHdl,'MaskPrompts');
    aTunables=get_param(aBlockHdl,'MaskTunableValues');
    aEnables=get_param(aBlockHdl,'MaskEnables');
    aVisibles=get_param(aBlockHdl,'MaskVisibilities');
    aTabs=get_param(aBlockHdl,'MaskTabNames');
    iNumParameters=length(aStyles);

    if(i_AreAllExistingTabNamesEmpty(aTabs)&&~isempty(aNeedsToBePromotedParameters))
        aFirstTabName=aNeedsToBePromotedParameters{1}.m_TabName;
        for i=1:length(aTabs)
            aTabs{i}=aFirstTabName;
        end
    end

    for i=1:length(aNeedsToBePromotedParameters)
        aStyles{end+1}=['promote','(',aNeedsToBePromotedParameters{i}.m_Name,')'];

        if(aNeedsToBePromotedParameters{i}.m_Evaluate)
            aNameString=[aNameString,aNeedsToBePromotedParameters{i}.m_Name,'=@',num2str(iNumParameters+i),';'];
        else
            aNameString=[aNameString,aNeedsToBePromotedParameters{i}.m_Name,'=&',num2str(iNumParameters+i),';'];
        end

        aPrompts{end+1}=[aNeedsToBePromotedParameters{i}.m_Prompt];

        aTunables{end+1}=aNeedsToBePromotedParameters{i}.m_Tunable;

        if(aNeedsToBePromotedParameters{i}.m_Enable)
            aEnables{end+1}='on';
        else
            aEnables{end+1}='off';
        end

        if(aNeedsToBePromotedParameters{i}.m_Visible)
            aVisibles{end+1}='on';
        else
            aVisibles{end+1}='off';
        end

        aTabs{end+1}=aNeedsToBePromotedParameters{i}.m_TabName;
    end

    set_param(aBlockHdl,'MaskStyles',aStyles,...
    'MaskVariables',aNameString,...
    'MaskPrompts',aPrompts,...
    'MaskTunableValues',aTunables,...
    'MaskEnables',aEnables,...
    'MaskVisibilities',aVisibles,...
    'MaskTabNames',aTabs);
end

function[bAllTabsEmpty]=i_AreAllExistingTabNamesEmpty(aTabs)
    for i=1:length(aTabs)
        if(~isempty(aTabs{i}))
            bAllTabsEmpty=false;
            return;
        end
    end

    bAllTabsEmpty=true;
end

function[aAllLinkBlocks]=i_BlocksHavingLinks(aLibName,aBlocksNeedingUpdate)
    aAllLinkBlocks={};

    for i=1:length(aBlocksNeedingUpdate)
        aLinkBlocks=i_LinkToExistingLib(aLibName,aBlocksNeedingUpdate{i});
        for j=1:length(aLinkBlocks)
            aAllLinkBlocks{end+1}=aLinkBlocks{j};
        end
    end
end

function[aLinkBlocks]=i_LinkToExistingLib(aLibName,aBlockHdl)
    aBlockPath=getfullname(aBlockHdl);


    aLinkBlocks=find_system(aLibName,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','Mask','on','ReferenceBlock',aBlockPath);
end


function[aTemplate]=i_PassStatus(aModelAdvisorObj,aAllLinkBlocks)
    aTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    aTemplate.setSubBar(false);

    aStatusMessage={};
    aStatusMessage{end+1}=DAStudio.message('ModelAdvisor:engine:MA_MaskedBlocks_UpdatedMaskedBuiltinBlocks_Success');

    if isempty(aAllLinkBlocks)
        aTemplate.setSubResultStatus('pass');
        aTemplate.setSubResultStatusText(aStatusMessage);
    else
        aStatusMessage{end+1}=ModelAdvisor.LineBreak;
        aStatusMessage{end+1}=ModelAdvisor.LineBreak;
        aStatusMessage{end+1}=DAStudio.message('ModelAdvisor:engine:MA_MaskedBlocks_UpdatedMaskedBuiltinBlocks_Warning');

        aTemplate.setSubResultStatus('warn');
        aTemplate.setSubResultStatusText(aStatusMessage);
        aTemplate.setListObj(aAllLinkBlocks);
    end

    aModelAdvisorObj.setActionResultStatus(true);
    aModelAdvisorObj.setActionEnable(false);
end


%#ok<*AGROW>
%#ok<*CTCH>
