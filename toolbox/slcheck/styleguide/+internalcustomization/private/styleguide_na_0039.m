function styleguide_na_0039()





    rec=ModelAdvisor.Check('mathworks.maab.na_0039');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na_0039_title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:na_0039_tip');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0039';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:styleguide:na_0039',@hCheckAlgo),'None','DetailStyle');

    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportHighlighting=true;

    rec.setLicense({styleguide_license});
    rec.Value(true);

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


    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end



function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;


    SFSimObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.SLFunction'});

    for i=1:length(SFSimObjs)
        blockHandle=sf('get',SFSimObjs{i}.id,'state.simulink.blockHandle');


        SFCharts=find_system(blockHandle,'regexp','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'SFBlockType','Chart|Transition|Truth Table');
        if~isempty(SFCharts)
            FailingObjs=[FailingObjs;SFCharts(:)];%#ok<AGROW>
        end
    end
    FailingObjs=mdladvObj.filterResultWithExclusion(FailingObjs);
end


