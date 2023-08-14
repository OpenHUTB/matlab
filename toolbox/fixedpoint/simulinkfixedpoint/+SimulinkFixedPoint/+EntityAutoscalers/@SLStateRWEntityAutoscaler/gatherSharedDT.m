function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};





    ownerBlock=blkObj.StateOwnerBlock;
    stateSigID.blkObj=get_param(ownerBlock,'Object');
    stateSigID.pathItem='States';

    [inportID,outportID]=h.getPortsToShareWithState();
    blkSigID=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,inportID,outportID);




    if~isempty(blkSigID)
        oneList={stateSigID,blkSigID{1}};
        sharedLists{1}=oneList;
    end


end


