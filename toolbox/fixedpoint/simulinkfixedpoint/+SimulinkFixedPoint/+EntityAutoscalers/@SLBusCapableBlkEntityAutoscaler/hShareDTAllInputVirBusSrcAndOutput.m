function sharedLists=hShareDTAllInputVirBusSrcAndOutput(h,blkObj)






    sharedLists={};

    ph=blkObj.PortHandles;
    shareAllSrc={};
    for i=1:length(ph.Inport)
        if~hIsVirtualBus(h,ph.Inport(i))
            continue;

        end


        portObj=get_param(ph.Inport(i),'Object');
        srcSigIDs=getAllSourceSignal(h,portObj,false);


        if~isempty(srcSigIDs)
            shareAllSrc=[shareAllSrc,srcSigIDs];%#ok
        end
    end


    if~isempty(ph.Outport)&&length(ph.Outport)==1
        if~isempty(shareAllSrc)
            structSignalID.blkObj=blkObj;
            structSignalID.pathItem='1';
            shareAllSrc{end+1}=structSignalID;
        end
    end


    if length(shareAllSrc)>1
        sharedLists{1}=shareAllSrc;
    end



