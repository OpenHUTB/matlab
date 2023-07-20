function jmaab_jc_0656





    checkID='jc_0656';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0656');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;

    rec.setLicense({styleguide_license});


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.RowSpan=[1,1];
    paramLookUnderMasks.ColSpan=[3,4];

    inputParamList={paramFollowLinks,paramLookUnderMasks};

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);



    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');

    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end


function[ResultDescription]=checkCallBack(system)

    ResultDescription={};
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    subtitle=DAStudio.message('ModelAdvisor:jmaab:jc_0656_subtitle');
    ft.setSubTitle(subtitle);
    ft.setSubBar(false);

    [FailingIfBlocks,FailingSwitchBlocks]=checkAlgo(mdlAdvObj,system);

    if isempty(FailingIfBlocks)&&isempty(FailingSwitchBlocks)
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0656_pass'));
        mdlAdvObj.setCheckResultStatus(true);
    end

    ResultDescription{end+1}=ft;

    if~isempty(FailingIfBlocks)
        ft1=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatus('Warn');
        ft1.setSubBar(true);
        ft1.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0656_fail_if_block'));
        ft1.setListObj(FailingIfBlocks);
        ft1.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0656_recAction_if_block'));
        mdlAdvObj.setCheckResultStatus(false);
        ResultDescription{end+1}=ft1;
    end

    if~isempty(FailingSwitchBlocks)
        ft2=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatus('Warn');
        ft2.setSubBar(false);
        ft2.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0656_fail_switch_block'));
        ft2.setListObj(FailingSwitchBlocks);
        ft2.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0656_recAction_switch_block'));
        mdlAdvObj.setCheckResultStatus(false);
        ResultDescription{end+1}=ft2;
    end
end


function[FailingIfBlocks,FailingSwitchBlocks]=checkAlgo(mdlAdvObj,system)

    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');




    FailingIfBlocks=find_system(system,'FollowLinks',FollowLinks.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',LookUnderMasks.Value,'BlockType','If','ShowElse','off');

    FailingSwitchBlocks=find_system(system,'FollowLinks',FollowLinks.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',LookUnderMasks.Value,'BlockType','SwitchCase','ShowDefaultCase','off');


    FailingIfBlocks=mdlAdvObj.filterResultWithExclusion(FailingIfBlocks);
    FailingSwitchBlocks=mdlAdvObj.filterResultWithExclusion(FailingSwitchBlocks);
end


