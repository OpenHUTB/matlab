function[result,ResultDescription]=modelAdvisorCheck_logicBlock(system,xlateTagPrefix)




    ResultDescription={};
    result=false;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsageSubtitle']));
    ft.setInformation(DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsageInformation']));



    LogicBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','Logic');

    blkHandles={};
    for i=1:length(LogicBlocks)
        pHandles=get_param(LogicBlocks{i},'PortHandles');
        ipHandles=pHandles.Inport;
        opHandles=pHandles.Outport;
        hasIssues=false;
        for ii=1:length(ipHandles)
            if~strcmp(get_param(ipHandles(ii),'CompiledPortDataType'),'boolean')
                hasIssues=true;
                break;
            end
        end
        if(~hasIssues)
            for ii=1:length(opHandles)
                if~strcmp(get_param(opHandles(ii),'CompiledPortDataType'),'boolean')
                    hasIssues=true;
                    break;
                end
            end
        end
        if hasIssues
            blkHandles{end+1}=LogicBlocks{i};%#ok<AGROW>
        end
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    blkHandles=mdladvObj.filterResultWithExclusion(blkHandles);

    if isempty(blkHandles)
        ft.setSubResultStatus('Pass');
        ResultDescription{end+1}=ft;
        if~isempty(LogicBlocks)
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsagePass']));
        else
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsageNoneFound']));
        end
        result=true;
    else
        ft.setSubResultStatus('Warn');
        ft.setSubBar(0);
        ResultDescription{end+1}=ft;
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsageWarning']));
        encodedModelName=modeladvisorprivate('HTMLjsencode',bdroot(system),'encode');
        encodedModelName=[encodedModelName{:}];

        hyperlink=['<a href = "matlab: modeladvisorprivate openCSAndHighlight ',[encodedModelName,' BooleanDataType'],'">',DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsageHyperlink']),'</a>'];
        ft.setRecAction([DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsageRecAction1']),'<br/>',...
        DAStudio.message([xlateTagPrefix,'LogicalOpsBlocksUsageRecAction2'],hyperlink)]);
        ft.setListObj(blkHandles);
        result=false;
    end


