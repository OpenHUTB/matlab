function hNewC=elaborate(this,hN,hC)




    [zerOneIdxMode,idxMode,elements,fillValues,rowsOrCols,numInputs]=this.getBlockInfo(hC);

    hNewC=pirelab.getVariableSelectorComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    zerOneIdxMode,idxMode,elements,fillValues,...
    rowsOrCols,numInputs,hC.Name);

