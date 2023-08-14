function styleguide_na_0038

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.na_0038',false,@hCheckAlgo,'None');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0038';

    rec.setLicense({'SL_Verification_Validation'});

    rec.setInputParametersLayoutGrid([2,4]);

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:styleguide:na_0038_StateThreshold');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='3';
    inputParamList{end}.Visible=false;


    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

end

function violations=hCheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;
    nestingThreshold=str2double(inputParams{1}.Value);

    if~isnumeric(nestingThreshold)||nestingThreshold<=0
        violations=ModelAdvisor.ResultDetail;
        violations.IsInformer=true;
        violations.IsViolation=true;
        ModelAdvisor.ResultDetail.setSeverity(violations,'fail');
        violations.Status=' ';
        violations.Description=DAStudio.message('ModelAdvisor:styleguide:InputParamError',inputParams{1}.Value,DAStudio.message('ModelAdvisor:styleguide:na_0038_StateThreshold'),DAStudio.message('ModelAdvisor:styleguide:InputPositiveInteger'));
        violations.RecAction=' ';
        return;
    end

    states=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.State'},true);
    states=mdladvObj.filterResultWithExclusion(states);
    Flags=false(1,length(states));
    for i=1:length(states)
        if getDepth(states{i})>nestingThreshold
            Flags(i)=true;
        end
    end

    violations=states(Flags);
end




function depth=getDepth(state)
    depth=0;



    if isa(state,'Stateflow.Chart')||...
        isa(state,'Stateflow.StateTransitionTableChart')
        return;

    elseif isa(state,'Stateflow.State')&&state.IsSubchart
        depth=1;
        return;
    else
        depth=1+getDepth(state.getParent);
    end
end