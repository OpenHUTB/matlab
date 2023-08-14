function physicalBlockList=tracePhysicalBlocks(sourceBlock,blockList)


    physicalBlockList={};
    for idx=1:numel(blockList)
        thisBlock=blockList{idx};
        switch get_param(thisBlock,'BlockType')
        case 'SimscapeBlock'
            physicalBlockList=[physicalBlockList;thisBlock];

        case 'SubSystem'
            connectedPhysicalBlocks=ee.internal.graph.findPhysicalBlockIntoSubsystem(sourceBlock,thisBlock);
            physicalBlockList=[physicalBlockList;connectedPhysicalBlocks];

        case 'PMIOPort'

            connectedPhysicalBlocks=ee.internal.graph.findBlockInUpSystem(thisBlock);
            physicalBlockList=[physicalBlockList;connectedPhysicalBlocks];

        otherwise

        end
    end


    physicalBlockList=unique(physicalBlockList);
    parentBlock=get_param(sourceBlock,'Parent');
    idxFind=find(ismember(physicalBlockList,{sourceBlock,parentBlock}));
    if~isempty(idxFind)
        physicalBlockList(idxFind)=[];
    end
end