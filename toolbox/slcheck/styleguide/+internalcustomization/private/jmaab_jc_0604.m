function jmaab_jc_0604





    checkID='jc_0604';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0604');

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

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@checkActionCallback);
    modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    modifyAction.Description=DAStudio.message('ModelAdvisor:jmaab:jc_0604_ActionDescription');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);


    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end


function[ResultDescription]=checkCallBack(system)
    ResultDescription={};
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    subtitle=DAStudio.message('ModelAdvisor:jmaab:jc_0604_subtitle');
    ft.setInformation(subtitle);
    ft.setSubBar(false);

    FailingNames=checkAlgo(mdlAdvObj,system);
    if~isempty(FailingNames)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0604_fail'));
        ft.setListObj(FailingNames);
        ft.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0604_recAction'));
        mdlAdvObj.setCheckResultStatus(false);
        mdlAdvObj.setActionEnable(true);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0604_pass'));
        mdlAdvObj.setCheckResultStatus(true);
        mdlAdvObj.setActionEnable(false);
    end
    ResultDescription{end+1}=ft;

end


function FailingBlocks=checkAlgo(mdlAdvObj,system)

    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');




    blocks=find_system(system,'FollowLinks',FollowLinks.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',LookUnderMasks.Value,'Type','block');

    blocks=mdlAdvObj.filterResultWithExclusion(blocks);



    shadedBlocks=cellfun(@(x)isBlockShaded(x),blocks);
    FailingBlocks=blocks(shadedBlocks);

end


function result=isBlockShaded(block)
    result=false;

    if~ismember(get_param(block,'MaskType'),{'DocBlock','CMBlock'})
        result=isequal(get_param(block,'DropShadow'),'on');
    end
end


function result=checkActionCallback(taskobj)
    result=ModelAdvisor.Paragraph;
    mdlAdvObj=taskobj.MAObj;
    mdlAdvObj.setActionEnable(false);
    ch_result=mdlAdvObj.getCheckResult(taskobj.MAC);
    FailingObjs=ch_result{1}.ListObj;

    cellfun(@(x)set_param(x,'DropShadow','off'),FailingObjs);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setInformation(DAStudio.message('ModelAdvisor:jmaab:jc_0604_Action'));
    ft.setListObj(FailingObjs);
    result.addItem(ft.emitContent);
end
