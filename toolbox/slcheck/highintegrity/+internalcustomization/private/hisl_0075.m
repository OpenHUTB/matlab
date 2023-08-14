function hisl_0075




    rec=getNewCheckObject('mathworks.hism.hisl_0075',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end




function FailingObjs=hCheckAlgo(system)

    FailingObjs={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    fl_val=inputParams{1}.Value;
    lum_val=inputParams{2}.Value;







    linkblocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks',lum_val,'FollowLinks',fl_val,'LinkStatus','resolved');


    confblocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks',lum_val,'FollowLinks',fl_val,'RegExp','on','BlockType','SubSystem','BlockChoice','.');

    allblocks=[linkblocks(:);confblocks(:)];
    linkdata=get_param(allblocks,'LinkData');
    hasdata=~cellfun('isempty',linkdata);
    parameterizedlinks=allblocks(hasdata);


    parameterizedlinks=mdladvObj.filterResultWithExclusion(parameterizedlinks);

    if~isempty(parameterizedlinks)
        for num=1:length(parameterizedlinks)
            vObj=ModelAdvisor.ResultDetail;
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0075_warn');
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0075_rec_action');
            ModelAdvisor.ResultDetail.setData(vObj,'SID',parameterizedlinks{num});
            FailingObjs=[FailingObjs;vObj];
        end
    end




    disabledlinks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'RegExp','on','LookUnderMasks',lum_val,'FollowLinks',fl_val,'AncestorBlock','.');

    disabledlinks=mdladvObj.filterResultWithExclusion(disabledlinks);
    if~isempty(disabledlinks)
        for num=1:length(disabledlinks)
            vObj1=ModelAdvisor.ResultDetail;
            vObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0075_warn2');
            vObj1.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0075_rec_action2');
            ModelAdvisor.ResultDetail.setData(vObj1,'SID',disabledlinks{num});
            FailingObjs=[FailingObjs;vObj1];
        end
    end

end
