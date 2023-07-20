function sharedLists=gatherSharedDT(h,blkObj)















    outModeStr=blkObj.outputMode;
    prdModeStr=blkObj.prodOutputMode;
    accModeStr=blkObj.accumMode;


    prdSameAsInp=isequal(prdModeStr,'Same as first input');

    accSameAsPrd=isequal(accModeStr,'Same as product output');

    accSameAsInp=...
    isequal(accModeStr,'Same as first input')||...
    (accSameAsPrd&&prdSameAsInp);

    outSameAsAcc=isequal(outModeStr,'Same as accumulator');

    outSameAsPrd=...
    isequal(outModeStr,'Same as product output')||...
    (outSameAsAcc&&accSameAsPrd);

    outSameAsInp=...
    isequal(outModeStr,'Same as first input')||...
    (outSameAsPrd&&prdSameAsInp)||...
    (outSameAsAcc&&accSameAsInp)||...
    (outSameAsAcc&&accSameAsPrd&&prdSameAsInp);






    structOutSignalID.blkObj=blkObj;
    structOutSignalID.pathItem='Output';
    structAccSignalID.blkObj=blkObj;
    structAccSignalID.pathItem='Accumulator';
    structPrdSignalID.blkObj=blkObj;
    structPrdSignalID.pathItem='Product output';

    listSharedWithAcc={structAccSignalID};
    listSharedWithPrd={structPrdSignalID};
    listSharedWithInp={};


    if(outSameAsInp||accSameAsInp||prdSameAsInp)

        hAllPorts=get_param(blkObj.Handle,'PortHandles');
        hInport1Cur1=hAllPorts.Inport(1);
        inportObject=get_param(hInport1Cur1,'Object');


        [srcBlkObj,srcPathItem,srcInfo]=h.getSourceSignal(inportObject);

        if~isempty(srcBlkObj)&&~isempty(srcPathItem)

            structSrcSignalID.blkObj=srcBlkObj;
            structSrcSignalID.pathItem=srcPathItem;
            structSrcSignalID.srcInfo=srcInfo;
            listSharedWithInp={structSrcSignalID};
        end
    end

    if prdSameAsInp

        listSharedWithInp=[listSharedWithInp,structPrdSignalID];
    end

    if accSameAsInp

        listSharedWithInp=[listSharedWithInp,structAccSignalID];
    elseif accSameAsPrd

        listSharedWithPrd=[listSharedWithPrd,structAccSignalID];
    end

    if outSameAsInp

        listSharedWithInp=[listSharedWithInp,structOutSignalID];
    elseif outSameAsPrd

        listSharedWithPrd=[listSharedWithPrd,structOutSignalID];
    elseif outSameAsAcc

        listSharedWithAcc=[listSharedWithAcc,structOutSignalID];
    end





    sharedLists={};
    if numel(listSharedWithInp)>1
        sharedLists{end+1}=listSharedWithInp;
    end
    if numel(listSharedWithAcc)>1
        sharedLists{end+1}=listSharedWithAcc;
    end
    if numel(listSharedWithPrd)>1
        sharedLists{end+1}=listSharedWithPrd;
    end
