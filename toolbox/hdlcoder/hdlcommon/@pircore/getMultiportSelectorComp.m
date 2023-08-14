function newComp=getMultiportSelectorComp(hN,hInSignals,hOutSignals,...
    rowsOrCols,idxCellArray,idxErrMode,compName)


    newComp=hN.addComponent2(...
    'kind','multiportselector_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'RowsOrCols',rowsOrCols,...
    'IdxCellArray',idxCellArray,...
    'IdxErrMode',idxErrMode);
end
