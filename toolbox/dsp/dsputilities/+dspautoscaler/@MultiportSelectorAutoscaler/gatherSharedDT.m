function sharedLists=gatherSharedDT(h,blkObj)













    hAllPorts=get_param(blkObj.Handle,'PortHandles');
    hInport1Cur1=hAllPorts.Inport(1);
    inportObject=get_param(hInport1Cur1,'Object');
    curListPorts={};


    [srcBlkObj,srcPathItem,srcInfo]=h.getSourceSignal(inportObject);

    if~isempty(srcBlkObj)&&~isempty(srcPathItem)
        structSignalID.blkObj=srcBlkObj;
        structSignalID.pathItem=srcPathItem;
        structSignalID.srcInfo=srcInfo;


        curListPorts=[curListPorts,structSignalID];
    end


    for outPortIdx=1:length(hAllPorts.Outport)
        structSignalID.blkObj=blkObj;
        structSignalID.pathItem=num2str(outPortIdx);
        curListPorts=[curListPorts,structSignalID];%#ok<AGROW>
    end


    sharedLists={curListPorts};
