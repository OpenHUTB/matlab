function portsToIgnoreTerm=rewireVariantSource(variantBlock,portsToDel,calledFromReducer)








    portsToIgnoreTerm=[];

    portHandles=get_param(variantBlock,'PortHandles');
    for lineIdx=1:numel(portsToDel)


        portIdxToDel=portsToDel(lineIdx);
        slvariants.internal.utils.deleteInputPortOfVSource(variantBlock,portHandles.Inport(portIdxToDel));
    end

    inPortHandles=portHandles.Inport;


    portsToRetain=setdiff(1:numel(inPortHandles),portsToDel);
    numToRetain=numel(portsToRetain);
    lineHand=get(inPortHandles(portsToRetain),'Line');
    lineHand=Simulink.variant.utils.i_cell2mat(lineHand);

    for lineIdx=1:numToRetain
        currLineH=lineHand(lineIdx);
        if currLineH<0
            continue;
        end


        srcPort=get(currLineH,'SrcPortHandle');
        if srcPort<0
            delete_line(currLineH);
        end
    end

    if calledFromReducer

        nSegments=numel(inPortHandles)+1;
        nSegmentsToRetain=numToRetain+1;
        if(nSegments~=nSegmentsToRetain)
            Simulink.variant.reducer.utils.resizeIVBlock(variantBlock,nSegments,nSegmentsToRetain);
        end
    end




end
