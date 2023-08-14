function styleguide_na_0003()





    rec=ModelAdvisor.Check('mathworks.maab.na_0003');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0003_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:na_0003_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:na_0003_title_tip')];
    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');
    rec.Value=true;
    rec.setLicense({styleguide_license});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0003';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportHighlighting=true;


    rec.setInputParametersLayoutGrid([1,4]);
    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@InputParameterCallBack);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end




function ResultDescription=checkCallBack(system)
    ResultDescription={};
    bResultStatus=false;
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    xlateTagPrefix='ModelAdvisor:styleguide:';


    FailingExpressions=checkRun(system,mdlAdvObj);



    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubTitle(DAStudio.message([xlateTagPrefix,'na_0003_subtitle']))
    ft.setSubBar(false);
    ft.setColTitles({DAStudio.message([xlateTagPrefix,'na_0003_colTitle1']),...
    DAStudio.message([xlateTagPrefix,'na_0003_colTitle2']),...
    DAStudio.message([xlateTagPrefix,'na_0003_colTitle3'])});
    if isempty(FailingExpressions)
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'na_0003_pass']));
        bResultStatus=true;
    else
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'na_0003_fail']));
        ft.setTableInfo(FailingExpressions);
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'na_0003_recAction']));
    end

    mdlAdvObj.setCheckResultStatus(bResultStatus);
    ResultDescription{1}=ft;

end



function FailingExpressions=checkRun(system,mdlAdvObj)
    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');


    ifBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks',LookUnderMasks.Value,'FollowLinks',FollowLinks.Value,'BlockType','If');
    ifBlocks=mdlAdvObj.filterResultWithExclusion(ifBlocks);
    FailingExpressions={};
    for i=1:length(ifBlocks)
        FailingExpressions=[FailingExpressions;AnalyzeIfExpression(ifBlocks{i})];%#ok
        FailingExpressions=[FailingExpressions;AnalyzeElseIfExpression(ifBlocks{i})];%#ok
    end
end



function FailureDetails=AnalyzeIfExpression(ifBlock)
    expression=get_param(ifBlock,'IfExpression');
    FailureDetails={};
    if~ModelAdvisor.internal.styleguide_na_0003_algo(expression)
        FailureDetails{1}=ifBlock;
        FailureDetails{2}='IfExpression';
        FailureDetails{3}=expression;
    end
end



function FailureDetails=AnalyzeElseIfExpression(ifBlock)
    expression=get_param(ifBlock,'ElseIfExpressions');
    FailureDetails={};index=1;


    expressions=strsplit(expression,',');
    for i=1:numel(expressions)
        if~ModelAdvisor.internal.styleguide_na_0003_algo(expressions{i})
            FailureDetails{index,1}=ifBlock;
            FailureDetails{index,2}='ElseIfExpressions';
            FailureDetails{index,3}=expressions{i};
            index=index+1;
        end
    end
end



