function sharedLists=gatherSharedDT(h,blkObj)





    ph=blkObj.PortHandles;

    secondInputPortObj=get_param(ph.Inport(2),'Object');


    sharedLists{1}=getAllSourceSignal(h,secondInputPortObj,false);


