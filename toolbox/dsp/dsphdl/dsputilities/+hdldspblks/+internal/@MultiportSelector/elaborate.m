function hNewC=elaborate(this,hN,hC)




    [rowsOrCols,idxCellArray,idxErrMode]=getBlockInfo(this,hC);

    hNewC=pirelab.getMultiportSelectorComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    rowsOrCols,idxCellArray,idxErrMode,...
    hC.Name);

end
