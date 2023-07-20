function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};
    sharedAllPorts=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedAllPorts);

    shareAllSrcList=hShareDTAllInputVirBusSrcAndOutput(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,shareAllSrcList);

