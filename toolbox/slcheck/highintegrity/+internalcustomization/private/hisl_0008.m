function hisl_0008




    rec=getNewCheckObject('mathworks.hism.hisl_0008',false,@hCheckAlgo,'PostCompile');

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

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    forIterBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks',inputParams{2}.Value,'FollowLinks',inputParams{1}.Value,'BlockType','ForIterator');
    forIterBlocks=mdladvObj.filterResultWithExclusion(forIterBlocks);

    flags=false(1,length(forIterBlocks));
    for i=1:length(forIterBlocks)
        iterPort=get_param(forIterBlocks{i},'ShowIterationPort');
        extInc=get_param(forIterBlocks{i},'ExternalIncrement');
        iterSrc=get_param(forIterBlocks{i},'IterationSource');
        if(strcmp(iterPort,'on')&&strcmp(extInc,'on'))
            flags(i)=true;
        elseif strcmp(iterSrc,'external')
            ports=get_param(forIterBlocks{i},'PortHandles');
            line=get_param(ports.Inport(1),'Line');
            srcPort=get_param(line,'NonVirtualSrcPorts');
            parent=get_param(srcPort,'Parent');
            blockType=get_param(parent,'BlockType');
            if~iscell(blockType)
                blockType={blockType};
                parent={parent};
            end
            for k=1:length(blockType)
                blockObj=get_param(parent{k},'Object');
                if isempty(regexpi(blockType{k},'^(Constant|Width|Probe)$'))&&~blockObj.isPostCompileVirtual
                    flags(i)=true;
                    break;
                end
            end
        end
    end
    FailingObjs=forIterBlocks(flags);
end


