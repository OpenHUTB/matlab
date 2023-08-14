function[bResultStatus,ResultDescription]=modelAdvisorCheck_logMathFctBlock(system,xlateTagPrefix,enabled)





    bResultStatus=false;%#ok<NASGU>
    ResultDescription={};

    systemHandle=get_param(system,'Handle');
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'Hisl0004_SubTitle']));

    if enabled==false
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SubcheckDisabled']));
        ResultDescription{end+1}=ft;
        bResultStatus=true;
        return;
    end

    ft.setInformation(DAStudio.message([xlateTagPrefix,'Hisl0004_Description']));



    logMathFunctionBlocks=find_system(systemHandle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','BlockType','Math','Operator','log');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    logMathFunctionBlocks=mdladvObj.filterResultWithExclusion(logMathFunctionBlocks);


    if~isempty(logMathFunctionBlocks)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageNaturalLogFail']));

        ft.setListObj(logMathFunctionBlocks);

        ft.setRecAction(DAStudio.message([xlateTagPrefix,'mathBlocksUsageNaturalLogRecAction']));
        ResultDescription{end+1}=ft;
        bResultStatus=false;
    else
        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'Hisl0004_PassNolog']));
        ResultDescription{end+1}=ft;
    end
