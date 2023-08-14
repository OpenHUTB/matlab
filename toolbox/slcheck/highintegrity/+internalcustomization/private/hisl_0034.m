function hisl_0034




    rec=getNewCheckObject('mathworks.hism.hisl_0034',false,@hCheckAlgo,'PostCompile');

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

function violations=hCheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    switchBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Switch');
    switchBlocks=mdladvObj.filterResultWithExclusion(switchBlocks);

    flags=false(1,numel(switchBlocks));
    for i=1:length(switchBlocks)

        pHandles=get_param(switchBlocks{i},'PortHandles');
        ipHandles=pHandles.Inport;
        dt=get_param(ipHandles(2),'CompiledPortDataType');

        if isempty(dt)
            continue;
        end

        criteria=get_param(switchBlocks{i},'criteria');

        if(strcmp(dt,'double')||strcmp(dt,'single'))&&contains(criteria,'~=')
            flags(i)=true;
        end

    end
    violations=switchBlocks(flags);

end
