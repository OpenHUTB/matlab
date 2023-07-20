










function[bResultStatus,ResultDescription]=modelAdvisorCheck_whileBlock(system,xlateTagPrefix)






    ResultDescription={};
    bResultStatus=true;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message('ModelAdvisor:iec61508:whileBlockDesc'));
    ft.setInformation({DAStudio.message([xlateTagPrefix,'whileBlockCheckDesc'])});



    searchResult=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','WhileIterator');

    if isempty(searchResult);
        ft.setSubResultStatus('Pass');
        xlateTagNoBlocks='ReportNoWhileIterBlocks';
        if strcmp(bdroot(system),system)==false
            xlateTagNoBlocks='ReportNoWhileIterBlocksSubsystem';
        end
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,xlateTagNoBlocks]));
        ResultDescription{end+1}=ft;
    else
        whileIU={};
        for i=1:length(searchResult)


            maxIters=Advisor.Utils.Simulink.evalSimulinkBlockParameters(searchResult{i},'MaxIters');

            if maxIters{1}==-1
                whileIU{end+1}=searchResult{i};%#ok<AGROW>
                bResultStatus=false;
            end
        end


        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        whileIU=mdladvObj.filterResultWithExclusion(whileIU);

        if~isempty(whileIU)
            bResultStatus=false;
        end


        if bResultStatus
            ft.setSubResultStatus('Pass');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'whileIterBlockCorrect']));
            ResultDescription{end+1}=ft;
        else
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'whileIterUnlimited']));
            ft.setRecAction(DAStudio.message([xlateTagPrefix,'whileIterUnlimitedRecAction']));
            ft.setListObj(whileIU);
            ResultDescription{end+1}=ft;
        end
    end
