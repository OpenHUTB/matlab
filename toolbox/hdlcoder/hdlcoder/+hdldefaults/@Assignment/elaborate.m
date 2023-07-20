function hNewC=elaborate(this,hN,hC)


    [idxBase,ndims,idxParamArray,...
    idxOptionArray,outputSizeArray]=this.getBlockInfo(hC);

    hNewC=pirelab.getAssignmentComp(hN,hC.PirInputSignals,...
    hC.PirOutputSignals,idxBase,idxOptionArray,idxParamArray,...
    outputSizeArray,ndims,hC.Name);
end

