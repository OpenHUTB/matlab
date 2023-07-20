function[rowsOrCols,idxCellArray,idxErrMode]=getBlockInfo(~,hC)






    slbh=hC.SimulinkHandle;
    rowsOrCols=get_param(slbh,'RowsOrCols');
    idxCellArray=slResolve(get_param(slbh,'IdxCellArray'),slbh);
    idxErrMode=get_param(slbh,'IdxErrMode');
