function hisl_0002_old




    rec=getNewCheckObject('mathworks.hism.hisl_0002',false,@hCheckAlgo,'None');

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
    mdladvRoot.register(rec);

end


function violations=hCheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    recpObjs=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Math','Operator','reciprocal');
    recpObjs=mdladvObj.filterResultWithExclusion(recpObjs);

    v1=Advisor.Utils.createResultDetailObjs(recpObjs,'Status',DAStudio.message('ModelAdvisor:hism:hisl_0002_warn'),'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0002_rec_action'));



    recpObjs=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Math','Operator','rem');
    recpObjs=mdladvObj.filterResultWithExclusion(recpObjs);

    v2=Advisor.Utils.createResultDetailObjs(recpObjs,'Status',DAStudio.message('ModelAdvisor:hism:hisl_0002_warn'),'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0002_rec_action'));

    violations=[v1,v2];
end
