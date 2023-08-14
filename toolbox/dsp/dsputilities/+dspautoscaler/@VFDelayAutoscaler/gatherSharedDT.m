function sharedLists=gatherSharedDT(h,blkObj)












    if isequal(blkObj.outputMode,'Same as first input')

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


        structSignalID.blkObj=blkObj;
        structSignalID.pathItem='1';
        curListPorts=[curListPorts,structSignalID];


        sharedLists={curListPorts};
    else

        sharedLists={};
    end
