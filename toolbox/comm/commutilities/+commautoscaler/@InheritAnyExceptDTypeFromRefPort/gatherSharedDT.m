function sharedLists=gatherSharedDT(h,blkObj)




    hPorts=blkObj.PortHandles;
    inportObj=get_param(hPorts.Inport(1),'Object');
    [srcBlk,srcSig,srcInfo]=h.getSourceSignal(inportObj);

    if isempty(srcBlk)||isempty(srcSig)
        sharedLists={};
    else
        record1.blkObj=srcBlk;
        record1.pathItem=srcSig;
        record1.srcInfo=srcInfo;
        record2.blkObj=blkObj;
        record2.pathItem='Output';
        sharedLists={{record1,record2}};
    end

    samePortShare=hShareSrcAtSamePort(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,samePortShare);


