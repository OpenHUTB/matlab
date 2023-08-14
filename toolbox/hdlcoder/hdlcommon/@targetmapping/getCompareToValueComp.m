function comp=getCompareToValueComp(hN,hInSignals,hSignalsOut,opName,constVal,compName,nfpOptions)

    if(nargin<7)
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    baseType=hInSignals.Type;
    outType=hSignalsOut.Type;
    if outType.isArrayType&&~baseType.isArrayType



        dims=outType.getDimensions;
        if outType.isRowVector
            dims=[1,dims];
        elseif outType.isColumnVector
            dims=[dims,1];
        end
        baseType=pirelab.createPirArrayType(baseType,dims);
    end

    constOut=hN.addSignal(baseType,'const');
    constOut.SimulinkRate=hInSignals(1).SimulinkRate;
    constName=sprintf('%s_const',compName);
    pirelab.getConstComp(hN,constOut,constVal,constName);
    relopName=sprintf('%s_relop',compName);
    comp=pirelab.getRelOpComp(hN,[hInSignals,constOut],hSignalsOut,opName,true,relopName,'',-1,nfpOptions);
end