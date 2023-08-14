function[bResultStatus,ResultDescription]=modelAdvisorCheck_log10MathFctBlock(system,xlateTagPrefix,enabled)





    bResultStatus=false;%#ok<NASGU>
    ResultDescription={};

    systemHandle=get_param(system,'Handle');
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'Hisl0004_log10SubTitle']));

    if enabled==false
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SubcheckDisabled']));
        ResultDescription{end+1}=ft;
        bResultStatus=true;
        return;
    end

    ft.setInformation(DAStudio.message([xlateTagPrefix,'Hisl0004_log10Description']));



    log10MathFunctionBlocks=find_system(systemHandle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','BlockType','Math','Operator','log10');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    log10MathFunctionBlocks=mdladvObj.filterResultWithExclusion(log10MathFunctionBlocks);


    if~isempty(log10MathFunctionBlocks)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageBase10LogFail']));

        ft.setListObj(log10MathFunctionBlocks);

        ft.setRecAction(DAStudio.message([xlateTagPrefix,'mathBlocksUsageBase10LogRecAction']));
        ResultDescription{end+1}=ft;
        bResultStatus=false;
    else
        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'Hisl0004_PassNolog10']));
        ResultDescription{end+1}=ft;
    end
