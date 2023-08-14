function hisl_0007




    rec=getNewCheckObject('mathworks.hism.hisl_0007',false,@hCheckAlgo,'None');

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

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;



    forIterators=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','ForIterator');
    whileIterators=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','WhileIterator');

    iterBlks=[forIterators;whileIterators];
    iterBlks=mdlAdvObj.filterResultWithExclusion(iterBlks);

    iteratorSubsystems=get_param(iterBlks,'Parent');


    blocks={};
    for i=1:numel(iteratorSubsystems)
        thisIteratorSubsystem=iteratorSubsystems{i};


        blocksBelow=find_system(thisIteratorSubsystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'Type','Block');
        blocks=unique([blocks;blocksBelow]);
    end

    nonRecommendedBlocks=ModelAdvisor.Common.getSampleTimeDependentBlocks();


    flag=false(size(blocks));
    for i=1:numel(blocks)
        thisBlock=blocks{i};
        if isNonRecommendBlock(thisBlock,nonRecommendedBlocks)
            flag(i)=true;
        end
    end
    violations=blocks(flag);


    violations=removeNestedFindings(violations);

end

function result=isNonRecommendBlock(block,nonRecommendBlocks)
    result=false;
    blockType=get_param(block,'BlockType');
    maskType=get_param(block,'MaskType');
    if any(strcmp(blockType,nonRecommendBlocks(:,1))&strcmp(maskType,nonRecommendBlocks(:,2)))
        result=true;
    end
end

function filteredBlocks=removeNestedFindings(flaggedBlocks)
    keep=true(size(flaggedBlocks));
    for index=1:numel(flaggedBlocks)
        thisBlock=flaggedBlocks{index};
        if isParentAlreadyFlagged(thisBlock,flaggedBlocks)
            keep(index)=false;
        end
    end
    filteredBlocks=flaggedBlocks(keep);
end

function result=isParentAlreadyFlagged(block,flaggedBlocks)
    result=false;
    parent=get_param(block,'Parent');
    while~isempty(parent)
        if any(strcmp(parent,flaggedBlocks))
            result=true;
            break;
        else
            parent=get_param(parent,'Parent');
        end
    end
end
