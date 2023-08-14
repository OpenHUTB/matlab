function[newBlockList]=getFullBlockList(mdlHandle)




    if slcifeature('BEPSupport')==1
        blkList=slci.internal.getCompBlockList(mdlHandle);
    else
        blkList=slci.internal.getBlockList(mdlHandle);
    end
    newBlockList=blkList;
    for p=1:numel(blkList)
        thisBlk=blkList(p);
        blockType=get_param(thisBlk,'BlockType');

        if strcmpi(blockType,'SubSystem')
            newBlockList=[newBlockList;slci.internal.getFullBlockList(thisBlk)];%#ok
        end
    end
end


