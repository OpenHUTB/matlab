function hNewC=elaborate(this,hN,hC)


    [numDims,indexMode,indexOptionArray,indexParamArray,outputSizeArray,...
    inputPortWidth,nfpOptions]=this.getBlockInfo(hC);
    numDims=int2str(numDims);

    hNewC=pirelab.getSelectorComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    indexMode,indexOptionArray,indexParamArray,outputSizeArray,numDims,...
    hC.Name,inputPortWidth,nfpOptions);
end
