function sharedLists=gatherSharedDT(h,blkObj)




    record1.blkObj=blkObj;
    record1.pathItem='Output Signal';
    record2.blkObj=blkObj;
    record2.pathItem='Error Signal';
    sharedLists={{record1,record2}};


