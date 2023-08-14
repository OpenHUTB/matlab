










function manageAMISources(operation,tree,parameter,varargin)
    portsToHookUp=[];
    if numel(varargin)>0
        portsToHookUp=varargin{1};
    end
    paramName=char(parameter.NodeName);
    blockName=char(tree.getParent(parameter).NodeName);
    if isa(parameter,'serdes.internal.ibisami.ami.parameter.AmiParameter')
        paramUsage=char(parameter.Usage.Name);
    else
        paramUsage=char(tree.getTapsUsageOfBlock(blockName));
    end
    if isempty(paramUsage)||...
        isempty(paramName)||...
        isempty(blockName)||...
        ~isSimulinkStarted||...
        isempty(bdroot)||...
        strcmp(paramUsage,'Info')
        return
    end
    subsystemContainingBlock=[getfullname(tree.modelHandle),'/',char(tree.Direction)];

    if strcmp(operation,'add')

        if strcmp(paramUsage,'In')
            addConstant(subsystemContainingBlock,blockName,paramName,portsToHookUp);
        elseif strcmp(paramUsage,'InOut')
            if~isempty(portsToHookUp)&&length(portsToHookUp)==2
                portsToHookUpRead=portsToHookUp(1);
                portsToHookUpWrite=portsToHookUp(2);
            else
                portsToHookUpRead=[];
                portsToHookUpWrite=[];
            end
            addDataStore(subsystemContainingBlock,'read',blockName,paramName,portsToHookUpRead);
            addDataStore(subsystemContainingBlock,'write',blockName,paramName,portsToHookUpWrite);
        elseif strcmp(paramUsage,'Out')
            addDataStore(subsystemContainingBlock,'write',blockName,paramName,portsToHookUp);
        end
    elseif strcmp(operation,'delete')
        if strcmp(paramUsage,'In')
            deleteConstant('local',subsystemContainingBlock,blockName,paramName)
        elseif strcmp(paramUsage,'InOut')
            deleteDataStore('local',subsystemContainingBlock,'read',blockName,paramName);
            deleteDataStore('local',subsystemContainingBlock,'write',blockName,paramName);
        elseif strcmp(paramUsage,'Out')
            deleteDataStore('local',subsystemContainingBlock,'write',blockName,paramName);
        end
    end

    blockPath=[subsystemContainingBlock,'/',blockName];
    if isempty(portsToHookUp)
        open_system(blockPath,'force');
    end


    set_param(blockPath,'ZoomFactor','FitSystem');
end
function addConstant(subsystemContainingBlock,blockName,paramName,portToHookUp)
    blockpath=[subsystemContainingBlock,'/',blockName,'/',paramName];
    param=[blockName,'Parameter.',paramName];
    bestPosition=findBestBlockPosition([subsystemContainingBlock,'/',blockName]);
    blockHandle=add_block('simulink/Sources/Constant',blockpath,'MakeNameUnique','on');
    set_param(blockHandle,'Value',param);
    setBlockSize(blockHandle,bestPosition);
    if isempty(portToHookUp)
        highlightBlock(blockHandle);
    else
        addedBlockName=get_param(blockHandle,'Name');
        add_line([subsystemContainingBlock,'/',blockName],...
        [addedBlockName,'/1'],...
        portToHookUp,...
        'autorouting','on');
    end
end
function addDataStore(subsystemContainingBlock,readwrite,blockName,paramName,portToHookUp)
    blockpath=[subsystemContainingBlock,'/',blockName,'/',paramName,' ',readwrite];
    signal=[blockName,'Signal'];
    signalAndParam=[signal,'.',paramName];
    bestPosition=findBestBlockPosition([subsystemContainingBlock,'/',blockName]);
    if strcmp(readwrite,'read')
        blockHandle=add_block('simulink/Signal Routing/Data Store Read',blockpath,'MakeNameUnique','on');
        set_param(blockHandle,'DataStoreName',signal);
        set_param(blockHandle,'DataStoreElements',signalAndParam);
    else
        blockHandle=add_block('simulink/Signal Routing/Data Store Write',blockpath,'MakeNameUnique','on');
        set_param(blockHandle,'DataStoreName',signal);
        set_param(blockHandle,'DataStoreElements',signalAndParam);
    end
    setBlockSize(blockHandle,bestPosition);
    if isempty(portToHookUp)
        highlightBlock(blockHandle);
    else
        if strcmp(readwrite,'read')
            addedBlockName=get_param(blockHandle,'Name');
            add_line([subsystemContainingBlock,'/',blockName],...
            [addedBlockName,'/1'],...
            portToHookUp,...
            'autorouting','on');
        else
            addedBlockName=get_param(blockHandle,'Name');
            add_line([subsystemContainingBlock,'/',blockName],...
            portToHookUp,...
            [addedBlockName,'/1'],...
            'autorouting','on');
        end
    end
end
function deleteConstant(scope,subsystemContainingBlock,blockName,paramName)
    blockPath=[subsystemContainingBlock,'/',blockName];
    param=[blockName,'Parameter.',paramName];
    if strcmp(scope,'global')


        foundBlocks=find_system(subsystemContainingBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2,'LookUnderMasks','all','FollowLinks','on','BlockType','Constant');
    else
        foundBlocks=find_system(blockPath,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','Constant');
    end
    if~isempty(foundBlocks)
        sizeFoundBlocks=size(foundBlocks,1);
        for blockIdx=1:sizeFoundBlocks
            foundBlockValue=get_param(foundBlocks{blockIdx},'Value');
            if strcmp(foundBlockValue,param)
                delete_block(foundBlocks{blockIdx});
            end
        end
    end
end
function deleteDataStore(scope,subsystemContainingBlock,readwrite,blockName,paramName)
    blockPath=[subsystemContainingBlock,'/',blockName];
    signal=[blockName,'Signal'];
    signalAndParam=[signal,'.',paramName];
    if strcmp(scope,'global')


        if strcmp(readwrite,'read')
            foundBlocks=find_system(subsystemContainingBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2,'LookUnderMasks','all','FollowLinks','on','BlockType','DataStoreRead');
        else
            foundBlocks=find_system(subsystemContainingBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2,'LookUnderMasks','all','FollowLinks','on','BlockType','DataStoreWrite');
        end
    else
        if strcmp(readwrite,'read')
            foundBlocks=find_system(blockPath,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','DataStoreRead');
        else
            foundBlocks=find_system(blockPath,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','DataStoreWrite');
        end
    end
    if~isempty(foundBlocks)
        sizeFoundBlocks=size(foundBlocks,1);
        for blockIdx=1:sizeFoundBlocks
            foundSignal=get_param(foundBlocks{blockIdx},'DataStoreName');
            foundSignalAndParam=get_param(foundBlocks{blockIdx},'DataStoreElements');
            if strcmp(foundSignal,signal)&&strcmp(foundSignalAndParam,signalAndParam)
                delete_block(foundBlocks{blockIdx});
            end
        end
    end
end
function highlightBlock(block)
    hilite_system(block,'unique');
end
function setBlockSize(block,bestPosition)

    width=175;
    height=26;
    blockPosition=get_param(block,'Position');
    newBlockPosition=[blockPosition(1),...
    bestPosition,...
    blockPosition(1)+width,...
    bestPosition+height];
    set_param(block,'Position',newBlockPosition);
end
function bestPosition=findBestBlockPosition(block)

    foundBlocks=find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on');
    if~isempty(foundBlocks)
        sizeFoundBlocks=size(foundBlocks,1);
        biggestBottom=[0,0,0,0];
        for blockIdx=2:sizeFoundBlocks
            blockPosition=get_param(foundBlocks{blockIdx},'Position');

            if blockPosition(4)>biggestBottom(4)
                biggestBottom=blockPosition;
            end
        end
    end
    deltaY=26;
    bestPosition=biggestBottom(4)+deltaY;
end


