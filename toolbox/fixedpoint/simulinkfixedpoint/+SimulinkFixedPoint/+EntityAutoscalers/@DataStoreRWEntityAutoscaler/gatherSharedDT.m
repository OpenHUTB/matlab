function sharedLists=gatherSharedDT(h,blkObj)%#ok<INUSL>




    sharedLists={};




    dataStoreHandle=slprivate('getDataStoreHandle',blkObj);
    sigID.blkObj=get_param(dataStoreHandle,'Object');
    sigID.pathItem='1';
    oneList={sigID};
    sharedLists{1}=oneList;



