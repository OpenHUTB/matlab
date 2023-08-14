function sharedLists=gatherSharedDT(h,blkObj)













    curListPorts={};
    hAllPorts=get_param(blkObj.Handle,'PortHandles');
    numOutports=numel(hAllPorts.Inport)/2;

    for outportIdx=1:numOutports

        inportIdx=(outportIdx*2)-1;
        hInportCur=hAllPorts.Inport(inportIdx);
        inportObj=get_param(hInportCur,'Object');



        [srcBlkObj,srcPathItem,srcInfo]=h.getSourceSignal(inportObj);



        if~isempty(srcBlkObj)&&~isempty(srcPathItem)

            structSignalID.blkObj=srcBlkObj;
            structSignalID.pathItem=srcPathItem;
            structSignalID.srcInfo=srcInfo;
            curListPorts=[curListPorts,structSignalID];%#ok


            structSignalID.blkObj=blkObj;
            structSignalID.pathItem=num2str(outportIdx);
            curListPorts=[curListPorts,structSignalID];%#ok
        end
    end


    sharedLists={curListPorts};
