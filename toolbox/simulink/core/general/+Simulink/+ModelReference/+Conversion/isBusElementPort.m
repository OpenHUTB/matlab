function isBusEle=isBusElementPort(blockHandle)




    blockHandle=get_param(blockHandle,'Handle');
    assert(ishandle(blockHandle));
    blkType=get_param(blockHandle,'BlockType');
    isInport=strcmp(blkType,'Inport');
    isOutport=strcmp(blkType,'Outport');
    isBusEle=false;
    if isInport||isOutport
        isBusEle=strcmpi(get_param(blockHandle,'IsBusElementPort'),'on');
    end
end