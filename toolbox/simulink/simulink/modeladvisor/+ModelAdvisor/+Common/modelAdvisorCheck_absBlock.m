










function[bResultStatus,ResultDescription]=modelAdvisorCheck_absBlock(system,xlateTagPrefix,enabled)




    ResultDescription={};
    bResultStatus=true;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'absBlockDesc']));

    if enabled==false
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SubcheckDisabled']));
        ResultDescription{end+1}=ft;
        return;
    end

    ft.setInformation({DAStudio.message([xlateTagPrefix,'absBlockCheckDesc'])});




    searchResult=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','Abs');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    if isempty(searchResult)
        ft.setSubResultStatus('Pass');
        if strcmp(bdroot(system),system)==false
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'ReportNoAbsBlocksSubsystem']));
        else
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'ReportNoAbsBlocks']));
        end
        ResultDescription{end+1}=ft;
    else


        absUVBlks={};
        absSatBlks={};
        absNoPTypes={};
        for i=1:length(searchResult)
            portTypes=get_param(searchResult{i},'CompiledPortDataTypes');
            if~isempty(portTypes)
                inputType=portTypes.Inport;
                if~isempty(strmatch(inputType,{'boolean','uint8','uint16','uint32'}))
                    absUVBlks{end+1}=searchResult{i};
                elseif~isempty(strmatch(inputType,{'int8','int16','int32'}))
                    if strmatch(get_param(searchResult{i},'SaturateOnIntegerOverflow'),'off')
                        absSatBlks{end+1}=searchResult{i};
                    end
                end
            else
                absNoPTypes{end+1}=searchResult{i};
            end
        end

        absNoPTypes=mdladvObj.filterResultWithExclusion(absNoPTypes);
        absUVBlks=mdladvObj.filterResultWithExclusion(absUVBlks);
        absSatBlks=mdladvObj.filterResultWithExclusion(absSatBlks);

        if~(isempty(absNoPTypes)&&isempty(absUVBlks)&&isempty(absSatBlks))
            bResultStatus=false;
        end



        if bResultStatus
            ft.setSubResultStatus('Pass');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'absBlockCorrect']));
            ResultDescription{end+1}=ft;




        else


            ft.setSubBar(0);
            ResultDescription{end+1}=ft;
            if~isempty(absUVBlks)
                ft1=ModelAdvisor.FormatTemplate('ListTemplate');
                ft1.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'absUnsignedValue']));
                ft1.setRecAction(DAStudio.message([xlateTagPrefix,'absUnsignedValueRecAction']));
                ft1.setListObj(absUVBlks);
                ft1.setSubResultStatus('Warn');
                if isempty(absNoPTypes)&&isempty(absSatBlks)
                    ft1.setSubBar(0);
                end
                ResultDescription{end+1}=ft1;
            end
            if~isempty(absSatBlks)
                ft2=ModelAdvisor.FormatTemplate('ListTemplate');
                ft2.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'absSaturate']));
                ft2.setRecAction(DAStudio.message([xlateTagPrefix,'absSaturateRecAction']));
                ft2.setListObj(absSatBlks);
                ft2.setSubResultStatus('Warn');
                if isempty(absNoPTypes)
                    ft2.setSubBar(0);
                end
                ResultDescription{end+1}=ft2;
            end
            if~isempty(absNoPTypes)
                ft3=ModelAdvisor.FormatTemplate('ListTemplate');
                ft3.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'absNoPortTypes']));
                ft3.setRecAction(DAStudio.message([xlateTagPrefix,'absNoPortTypesRecAction']));
                ft3.setSubResultStatus('Warn');
                ft3.setListObj(absNoPTypes);
                ft3.setSubBar(0);
                ResultDescription{end+1}=ft3;
            end
        end
    end
