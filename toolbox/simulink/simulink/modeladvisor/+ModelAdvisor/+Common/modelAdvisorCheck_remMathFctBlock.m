function[bResultStatus,ResultDescription]=modelAdvisorCheck_remMathFctBlock(system,xlateTagPrefix,enabled)





    bResultStatus=false;%#ok<NASGU>
    ResultDescription={};

    systemHandle=get_param(system,'Handle');
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'Hisl0002_remSubTitle']));

    if enabled==false
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SubcheckDisabled']));
        ResultDescription{end+1}=ft;
        bResultStatus=true;
        return;
    end

    ft.setInformation(DAStudio.message([xlateTagPrefix,'Hisl0002_remDescription']));



    remMathFunctionBlocks=find_system(systemHandle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','BlockType','Math','Operator','rem');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    remMathFunctionBlocks=mdladvObj.filterResultWithExclusion(remMathFunctionBlocks);


    if~isempty(remMathFunctionBlocks)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'mathBlocksUsageRemainderFail']));

        ft.setListObj(remMathFunctionBlocks);

        ft.setRecAction(DAStudio.message([xlateTagPrefix,'mathBlocksUsageRemainderRecAction']));
        ResultDescription{end+1}=ft;
        bResultStatus=false;
    else
        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'Hisl0002_PassNoRem']));
        ResultDescription{end+1}=ft;
    end
