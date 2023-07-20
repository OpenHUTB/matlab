function connectSignals(hElab,hSignalsIn,hSignalsOut,newPortName)








    vecSigName=sprintf('%s_vec',newPortName);


    VecSizeIn=length(hSignalsIn);
    VecSizeOut=length(hSignalsOut);


    hNetIn=hSignalsIn{1}.Owner;
    hNetOut=hSignalsOut{1}.Owner;


    if VecSizeIn>1
        baseType=hSignalsIn{1}.Type;
        inportType=pirelab.getPirVectorType(baseType,VecSizeIn);
        hSigIn=hNetIn.addSignal(inportType,vecSigName);
        pirelab.getMuxComp(hNetIn,[hSignalsIn{:}],hSigIn);
    else
        hSigIn=hSignalsIn{1};
    end

    if VecSizeOut>1
        baseType=hSignalsOut{1}.Type;
        outportType=pirelab.getPirVectorType(baseType,VecSizeOut);
        hSigOut=hNetOut.addSignal(outportType,vecSigName);
        pirelab.getDemuxComp(hNetOut,hSigOut,[hSignalsOut{:}]);
    else
        hSigOut=hSignalsOut{1};
    end

    [dimLenIn,baseTypeIn]=pirelab.getVectorTypeInfo(hSigIn);
    [dimLenOut,baseTypeOut]=pirelab.getVectorTypeInfo(hSigOut);

    if~isequal(dimLenIn,dimLenOut)||~baseTypeIn.isEqual(baseTypeOut)

        return;
    end


    hElab.setInternalSignal(newPortName,hSigIn);
    hElab.connectSignalFrom(newPortName,hSigOut);

end



