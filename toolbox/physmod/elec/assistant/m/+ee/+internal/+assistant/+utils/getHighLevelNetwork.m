function highLevelBlockList=getHighLevelNetwork(blockList)






    depthList=ee.internal.assistant.utils.getDepth(blockList);
    minLevel=min(depthList);
    moveLevel=depthList-minLevel;

    highLevelList=blockList;
    for idxBlock=1:numel(blockList)
        thisMoveLevel=moveLevel(idxBlock);
        thisBlock=blockList{idxBlock};
        while thisMoveLevel>0
            thisBlock=get_param(thisBlock,'parent');
            thisMoveLevel=thisMoveLevel-1;
        end
        highLevelList{idxBlock}=thisBlock;
    end
    highLevelBlockList=unique(highLevelList);


    parents=unique(get_param(highLevelBlockList,'parent'));
    if numel(parents)~=1
        highLevelBlockList=parents;
    end

    for idxBlock=1:numel(highLevelBlockList)
        thisBlock=highLevelBlockList{idxBlock};
        PortConnectivity=get_param(thisBlock,'PortConnectivity');
        connectedBlockList=unique([PortConnectivity.DstBlock]);
        for i=1:numel(connectedBlockList)
            blockType=get_param(connectedBlockList(i),'BlockType');
            if strcmp(blockType,'PMIOPort')
                highLevelBlockList={};
                return
            end
        end
    end

end