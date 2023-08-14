function connectSignalsWithHierarchy(hSignalsIn,hSignalsOut,direction,newPortName,newSigName)








    VecSizeIn=length(hSignalsIn);
    VecSizeOut=length(hSignalsOut);


    hNetIn=hSignalsIn{1}.Owner;
    hNetOut=hSignalsOut{1}.Owner;


    if VecSizeIn>1
        baseType=hSignalsIn{1}.Type;
        inportType=pirelab.getPirVectorType(baseType,VecSizeIn);
        hSigIn=hNetIn.addSignal(inportType,newSigName);
        pirelab.getMuxComp(hNetIn,[hSignalsIn{:}],hSigIn);
    else
        hSigIn=hSignalsIn{1};
    end

    if VecSizeOut>1
        baseType=hSignalsOut{1}.Type;
        outportType=pirelab.getPirVectorType(baseType,VecSizeOut);
        hSigOut=hNetOut.addSignal(outportType,newSigName);
        pirelab.getDemuxComp(hNetOut,hSigOut,[hSignalsOut{:}]);
    else
        hSigOut=hSignalsOut{1};
    end

    [dimLenIn,baseTypeIn]=pirelab.getVectorTypeInfo(hSigIn);
    [dimLenOut,baseTypeOut]=pirelab.getVectorTypeInfo(hSigOut);

    if~isequal(dimLenIn,dimLenOut)||~baseTypeIn.isEqual(baseTypeOut)

        return;
    end


    if strcmpi(direction,'up')
        connectSignalsUp(hSigIn,hSigOut,newPortName,newSigName);
    elseif strcmpi(direction,'down')
        connectSignalsDown(hSigIn,hSigOut,newPortName,newSigName);
    end

end

function connectSignalsUp(hSigIn,hSigOut,newPortName,newSigName)


    hNetIn=hSigIn.Owner;
    hNetOut=hSigOut.Owner;

    hSigInType=hSigIn.Type;

    [hParentNetIn,hNetInInst]=pirtarget.getParentNetwork(hNetIn);


    hNetIn.addOutputPort(newPortName);
    hSigIn.addReceiver(hNetIn,hNetIn.NumberOfPirOutputPorts-1);
    hNetInInst.addOutputPort(newPortName);

    if strcmpi(hParentNetIn.RefNum,hNetOut.RefNum)

        hSigOut.addDriver(hNetInInst,hNetInInst.NumberOfPirOutputPorts-1);

    else
        hSigParent=hParentNetIn.addSignal(hSigInType,newSigName);
        hSigParent.addDriver(hNetInInst,hNetInInst.NumberOfPirOutputPorts-1);

        connectSignalsUp(hSigParent,hSigOut,newPortName,newSigName);
    end
end

function connectSignalsDown(hSigIn,hSigOut,newPortName,newSigName)


    hNetIn=hSigIn.Owner;
    hNetOut=hSigOut.Owner;

    hSigInType=hSigIn.Type;

    [hParentNetOut,hNetOutInst]=pirtarget.getParentNetwork(hNetOut);


    hNetOut.addInputPort(newPortName);
    hSigOut.addDriver(hNetOut,hNetOut.NumberOfPirInputPorts-1);
    hNetOutInst.addInputPort(newPortName);

    if strcmpi(hParentNetOut.RefNum,hNetIn.RefNum)

        hSigIn.addReceiver(hNetOutInst,hNetOutInst.NumberOfPirInputPorts-1);

    else
        hSigParent=hParentNetOut.addSignal(hSigInType,newSigName);
        hSigParent.addReceiver(hNetOutInst,hNetOutInst.NumberOfPirInputPorts-1);

        connectSignalsDown(hSigIn,hSigParent,newPortName,newSigName);
    end
end
