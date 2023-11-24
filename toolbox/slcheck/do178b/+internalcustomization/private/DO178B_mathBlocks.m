function DO178B_mathBlocks
    rec=ModelAdvisor.Check('mathworks.do178.MathBlksUsage');
    rec.Title=DAStudio.message('ModelAdvisor:do178b:mathBlocksUsageTitle');
    rec.setCallbackFcn(@MathBlockUsageCallback,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:do178b:mathBlocksUsageTip');
    rec.CSHParameters.MapKey='ma.do178b';
    rec.CSHParameters.TopicID='mathBlocksUsageTitle';
    rec.setLicense({do178b_license});
    rec.Value(true);
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);



    function ResultDescription=MathBlockUsageCallback(system)
        ResultDescription={};
        bResultStatus=true;

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);

        xlateTagPrefix='ModelAdvisor:do178b:';
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(0);
        ft.setInformation(DAStudio.message([xlateTagPrefix,'mathBlocksUsageTip']));
        searchResult=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','Math');

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

        if isempty(searchResult);
            ft.setSubResultStatus('Pass');
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageNoBlocks']));
            ResultDescription{end+1}=ft;
        else
            opType=get_param(searchResult,'Operator');
            elogErr=searchResult(strcmp(opType,'log'));

            log10Err=searchResult(strcmp(opType,'log10'));

            remErr=searchResult(strcmp(opType,'rem'));

            elogErr=mdladvObj.filterResultWithExclusion(elogErr);
            log10Err=mdladvObj.filterResultWithExclusion(log10Err);
            remErr=mdladvObj.filterResultWithExclusion(remErr);


            if isempty(elogErr)&&isempty(log10Err)&&isempty(remErr)
                ft.setSubResultStatus('Pass');
                ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageSuccess']));
                ResultDescription{end+1}=ft;
            else
                ft.setSubResultStatus('Warn');
                ResultDescription{end+1}=ft;
                bResultStatus=false;
                if~isempty(elogErr)
                    ft1=ModelAdvisor.FormatTemplate('ListTemplate');
                    ft1.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageNaturalLogFail']));
                    ft1.setRecAction(DAStudio.message([xlateTagPrefix,'mathBlocksUsageNaturalLogRecAction']));
                    ft1.setListObj(elogErr);
                    ft1.setSubBar(0);
                    ResultDescription{end+1}=ft1;
                end
                if~isempty(log10Err)
                    ft2=ModelAdvisor.FormatTemplate('ListTemplate');
                    ft2.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageBase10LogFail']));
                    ft2.setRecAction(DAStudio.message([xlateTagPrefix,'mathBlocksUsageBase10LogRecAction']));
                    ft2.setListObj(log10Err);
                    ft2.setSubBar(0);
                    ResultDescription{end+1}=ft2;
                end
                if~isempty(remErr)
                    ft3=ModelAdvisor.FormatTemplate('ListTemplate');
                    ft3.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageRemainderFail']));
                    ft3.setRecAction(DAStudio.message([xlateTagPrefix,'mathBlocksUsageRemainderRecAction']));
                    ft3.setListObj(remErr);
                    ft3.setSubBar(0);
                    ResultDescription{end+1}=ft3;
                end
            end
        end
        mdladvObj.setCheckResultStatus(bResultStatus);

