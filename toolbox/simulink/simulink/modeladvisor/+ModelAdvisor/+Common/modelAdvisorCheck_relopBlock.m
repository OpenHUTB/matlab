










function[bResultStatus,ResultDescription]=modelAdvisorCheck_relopBlock(system,xlateTagPrefix)






    ResultDescription={};
    bResultStatus=true;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message('ModelAdvisor:iec61508:relopBlockDesc'));
    ft.setInformation({DAStudio.message([xlateTagPrefix,'relopBlockCheckDesc'])});




    searchResult=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','RelationalOperator');
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    if isempty(searchResult);
        ft.setSubResultStatus('Pass');
        xlateTagNoBlocks='ReportNoRelopBlocks';
        if strcmp(bdroot(system),system)==false
            xlateTagNoBlocks='ReportNoRelopBlocksSubsystem';
        end
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,xlateTagNoBlocks]));
        ResultDescription{end+1}=ft;
    else
        relopDT={};
        relopBO={};
        relopFV={};
        relopPT={};
        for i=1:length(searchResult)
            portTypes=get_param(searchResult{i},'CompiledPortDataTypes');
            if~isempty(portTypes)
                inputType=portTypes.Inport;
                outputType=portTypes.Outport;

                inputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,inputType);
                outputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,outputType);
                opType=get_param(searchResult{i},'Operator');
                if(length(inputType)==2)&&~strcmp(inputType{1},inputType{2})
                    relopDT{end+1}=searchResult{i};%#ok<AGROW>
                end
                if~strcmp(outputType,'boolean')
                    relopBO{end+1}=searchResult{i};%#ok<AGROW>
                end
                if any(strcmp(opType,{'==','~='}))
                    if any(strcmp(inputType{1},{'double','single'}))||any(strcmp(inputType{2},{'double','single'}))
                        relopFV{end+1}=searchResult{i};%#ok<AGROW>
                    end
                end
            else

                relopPT{end+1}=searchResult{i};%#ok<AGROW>
            end
        end


        relopPT=mdladvObj.filterResultWithExclusion(relopPT);
        relopFV=mdladvObj.filterResultWithExclusion(relopFV);
        relopBO=mdladvObj.filterResultWithExclusion(relopBO);
        relopDT=mdladvObj.filterResultWithExclusion(relopDT);

        if~(isempty(relopPT)&&isempty(relopFV)&&isempty(relopBO)&&isempty(relopDT))
            bResultStatus=false;
        end


        if bResultStatus
            ft.setSubResultStatus('Pass');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'relopBlockCorrect']));
            ResultDescription{end+1}=ft;
        else
            ft.setSubResultStatus('Warn');
            ft.setSubBar(0);
            ResultDescription{end+1}=ft;
            if~isempty(relopDT)
                ft1=ModelAdvisor.FormatTemplate('ListTemplate');
                ft1.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'relopDataTypes']));
                ft1.setRecAction(DAStudio.message([xlateTagPrefix,'relopDataTypesRecAction']));
                ft1.setListObj(relopDT);
                if(~isempty(relopBO)||~isempty(relopFV)||~isempty(relopPT))
                    ft1.setSubBar(0);
                end
                ResultDescription{end+1}=ft1;
            end
            if~isempty(relopBO)
                ft2=ModelAdvisor.FormatTemplate('ListTemplate');
                ft2.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'relopBlockOutput']));
                ft2.setRecAction(DAStudio.message([xlateTagPrefix,'relopBlockOutputRecAction']));
                ft2.setListObj(relopBO);
                if(~isempty(relopFV)||~isempty(relopPT))
                    ft2.setSubBar(0);
                end
                ResultDescription{end+1}=ft2;
            end
            if~isempty(relopFV)
                ft3=ModelAdvisor.FormatTemplate('ListTemplate');
                ft3.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'relopFloatValues']));
                ft3.setRecAction(DAStudio.message([xlateTagPrefix,'relopFloatValuesRecAction']));
                ft3.setListObj(relopFV);
                if(~isempty(relopPT))
                    ft3.setSubBar(0);
                end
                ResultDescription{end+1}=ft3;
            end
            if~isempty(relopPT)
                ft4=ModelAdvisor.FormatTemplate('ListTemplate');
                ft4.setFormatType('ListTemplate');
                ft4.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'relopNoPortTypes']));
                ft4.setRecAction(DAStudio.message([xlateTagPrefix,'relopNoPortTypesRecAction']));
                ft4.setListObj(relopPT);
                ResultDescription{end+1}=ft4;
            end
        end
    end

