










function[bResultStatus,ResultDescription]=modelAdvisorCheck_forBlock(system,xlateTagPrefix)






    ResultDescription={};
    bResultStatus=true;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message('ModelAdvisor:iec61508:forBlockDesc'));
    ft.setInformation({DAStudio.message([xlateTagPrefix,'forBlockCheckDesc'])});
    ft.setSubBar(0);



    searchResult=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','ForIterator');

    if isempty(searchResult);
        xlateTagNoBlocks='ReportNoForIterBlocks';
        if strcmp(bdroot(system),system)==false
            xlateTagNoBlocks='ReportNoForIterBlocksSubsystem';
        end
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,xlateTagNoBlocks]));
        ResultDescription{end+1}=ft;
    else
        forVI={};
        for i=1:length(searchResult)
            iterPort=get_param(searchResult{i},'ShowIterationPort');
            extInc=get_param(searchResult{i},'ExternalIncrement');
            iterSrc=get_param(searchResult{i},'IterationSource');
            if(strcmp(iterPort,'on')&&strcmp(extInc,'on'))
                forVI{end+1}=searchResult{i};
            elseif strcmp(iterSrc,'external')
                ports=get_param(searchResult{i},'PortHandles');
                line=get_param(ports.Inport(1),'Line');
                srcPort=get_param(line,'NonVirtualSrcPorts');
                parent=get_param(srcPort,'Parent');
                blockType=get_param(parent,'BlockType');
                if~iscell(blockType)
                    blockType={blockType};
                    parent={parent};
                end
                for k=1:length(blockType)
                    blockObj=get_param(parent{k},'Object');
                    if isempty(regexpi(blockType{k},'^(Constant|Width|Probe)$'))&&...
                        ~blockObj.isPostCompileVirtual
                        forVI{end+1}=searchResult{i};
                        break;
                    end
                end
            end
        end


        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        forVI=mdladvObj.filterResultWithExclusion(forVI);

        if~isempty(forVI)
            bResultStatus=false;
        end


        if bResultStatus
            ft.setSubResultStatus('Pass');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'forIterBlockCorrect']));
            ResultDescription{end+1}=ft;
        else
            ft.setSubResultStatus('Warn');
            ft.setListObj(forVI);
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'forVariableIter']));
            ft.setRecAction(DAStudio.message([xlateTagPrefix,'forVariableIterRecAction']));
            ResultDescription{end+1}=ft;
        end
    end
