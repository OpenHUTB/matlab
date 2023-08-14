function hisf_0013

    rec=getNewCheckObject('mathworks.hism.hisf_0013',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});


end




function violations=hCheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    allTxns=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Transition'},true);
    allTxns=mdladvObj.filterResultWithExclusion(allTxns);
    flags=false(1,numel(allTxns));
    for i=1:length(allTxns)






        if isempty(allTxns{i}.Source)
            continue;
        end

        txParent=allTxns{i}.getParent;

        if((isa(txParent,'Stateflow.State')||isa(txParent,'Stateflow.Chart'))&&...
            strcmp(allTxns{i}.getParent.Decomposition,'PARALLEL_AND'))
            flags(i)=true;
        end
    end

    violations=allTxns(flags);
end
