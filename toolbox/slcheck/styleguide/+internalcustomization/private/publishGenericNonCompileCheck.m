function rec=publishGenericNonCompileCheck(guideline,hCheckAlgo,licenses,group)
    rec=ModelAdvisor.Check(['mathworks.jmaab.',guideline]);
    rec.Title=DAStudio.message(['ModelAdvisor:styleguide:',guideline,'_title']);
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID=guideline;
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,guideline,hCheckAlgo),'None','DetailStyle');
    rec.TitleTips=DAStudio.message(['ModelAdvisor:styleguide:',guideline,'_tip']);
    rec.setLicense(licenses);
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    if~isempty(group)
        mdladvRoot=ModelAdvisor.Root;
        mdladvRoot.publish(rec,group);
    end
end