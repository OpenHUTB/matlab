


function[status,result]=...
    modelAdvisorCheck_SampleTimeDependentBlocks(system,TAG)

    formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    formatTemplate.setSubTitle(TEXT(TAG,'Hisl_0007_0009_SubTitle'));
    formatTemplate.setInformation(TEXT(TAG,'Hisl_0007_0009_Info'));



    forIterators=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'BlockType','ForIterator');
    whileIterators=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'BlockType','WhileIterator');
    iteratorBlocks=[forIterators;whileIterators];

    if isempty(iteratorBlocks)

        status=true;
        formatTemplate.setSubResultStatus('Pass');
        formatTemplate.setSubResultStatusText(...
        TEXT(TAG,'Hisl_0007_0009_StatusTextPassNoIterator'));
        result{1}=formatTemplate;
        return;
    end

    iteratorSubsystems=get_param(iteratorBlocks,'Parent');


    blocks={};
    for index=1:numel(iteratorSubsystems)
        thisIteratorSubsystem=iteratorSubsystems{index};


        blocksBelow=find_system(thisIteratorSubsystem,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'Type','Block');
        blocks=unique([blocks;blocksBelow]);
    end

    nonRecommendedBlocks=...
    ModelAdvisor.Common.getSampleTimeDependentBlocks();


    keep=false(size(blocks));
    for index=1:numel(blocks)
        thisBlock=blocks{index};
        if isNonRecommendBlock(thisBlock,nonRecommendedBlocks)
            keep(index)=true;
        end
    end
    flaggedBlocks=blocks(keep);


    flaggedBlocks=removeNestedFindings(flaggedBlocks);


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flaggedBlocks=mdladvObj.filterResultWithExclusion(flaggedBlocks);

    formatTemplate.setListObj(flaggedBlocks);

    if isempty(flaggedBlocks)
        status=true;
        formatTemplate.setSubResultStatus('Pass');
        formatTemplate.setSubResultStatusText(...
        TEXT(TAG,'Hisl_0007_0009_StatusTextPass'));
    else
        status=false;
        formatTemplate.setSubResultStatus('Warn');
        formatTemplate.setSubResultStatusText(...
        TEXT(TAG,'Hisl_0007_0009_StatusTextFail'));
        formatTemplate.setRecAction(TEXT(TAG,'Hisl_0007_0009_RecAction'));
    end

    result{1}=formatTemplate;

end

function string=TEXT(TAG,MSG)
    string=DAStudio.message([TAG,MSG]);
end

function result=isNonRecommendBlock(block,nonRecommendBlocks)
    result=false;
    blockType=get_param(block,'BlockType');
    maskType=get_param(block,'MaskType');
    if any(strcmp(blockType,nonRecommendBlocks(:,1))&...
        strcmp(maskType,nonRecommendBlocks(:,2)))
        result=true;
        return;
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

