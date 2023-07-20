function hisl_0006




    rec=getNewCheckObject('mathworks.hism.hisl_0006',false,@hCheckAlgo,'None');

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

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;



    whileIterBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','WhileIterator');
    whileIterBlocks=mdlAdvObj.filterResultWithExclusion(whileIterBlocks);

    flags=false(1,length(whileIterBlocks));
    for i=1:length(whileIterBlocks)
        try
            maxIters=Advisor.Utils.Simulink.evalSimulinkBlockParameters(whileIterBlocks{i},'MaxIters');
        catch
            maxIters=[];
        end
        if isempty(maxIters)
            continue;
        end
        if maxIters{1}<=0
            flags(i)=true;
        end
    end
    FailingObjs=whileIterBlocks(flags);
end


