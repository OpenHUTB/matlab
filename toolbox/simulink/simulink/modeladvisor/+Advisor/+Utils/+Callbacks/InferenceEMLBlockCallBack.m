function FailingObjs=InferenceEMLBlockCallBack(system,hObjectFcn)






















    FailingObjs={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    FollowLinks=inputParams{2}.Value;
    LookUnderMasks=inputParams{3}.Value;


    mfbs=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'SFBlockType','MATLAB Function');
    sfcs=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'SFBlockType','Chart');
    objs=[mfbs;sfcs];

    for i=1:length(objs)
        FailingObjs=[FailingObjs;hObjectFcn(objs{i})];%#ok<AGROW>
    end
    return;

    fcnObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,inputParams{2}.Value,inputParams{3}.Value);
    fcnObjs=mdladvObj.filterResultWithExclusion(fcnObjs);


    s=size(fcnObjs);
    if s(1)~=length(fcnObjs)

        fcnObjs=fcnObjs';
    end
    if inputParams{1}.Value
        fcnObjs=Advisor.Utils.Eml.getReferencedMFiles(system,fcnObjs);
    end


    for i=1:length(fcnObjs)
        FailingObjs=[FailingObjs;hObjectFcn(fcnObjs{i})];%#ok<AGROW>
    end

end
