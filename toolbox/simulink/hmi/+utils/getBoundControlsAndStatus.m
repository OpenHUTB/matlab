function[bStatus,ctrls,UUIDs]=getBoundControlsAndStatus(boundElem,srcBlockH,srcBlockorSFSigName,portIdx)




    ctrls={};
    UUIDs={};
    bStatus='';
    if isempty(boundElem)||~isValidBlock(boundElem)||~boundElem.isInstrumented()
        return
    end
    blk=boundElem.BlockPath.getBlock(1);
    boundBlkName=get_param(blk,'Name');
    boundBlkH=num2str(get_param(blk,'handle'),64);
    srcBlockH=num2str(srcBlockH,64);
    boundPortIdx=boundElem.OutputPortIndex;
    if(strcmp(srcBlockorSFSigName,boundBlkName)&&...
        strcmp(srcBlockH,boundBlkH)&&...
        portIdx==boundPortIdx)
        bStatus='default';
    end
end

function bValid=isValidBlock(boundElem)
    try
        get_param(boundElem.BlockPath.getBlock(1),'handle');
        bValid=true;
    catch
        bValid=false;
    end
end


