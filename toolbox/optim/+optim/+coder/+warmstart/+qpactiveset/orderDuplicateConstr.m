function[colMap,workspace_compare,workspace_int,workspace_tols]=...
    orderDuplicateConstr(colMap,A,b,AoldTrans,bold,ldAold,nVar,numOldCols,...
    workspace_compare,workspace_int,workspace_tols)




















































%#codegen

    coder.columnMajor;
    coder.allowpcode('plain');

    validateattributes(colMap,{coder.internal.indexIntClass},{'2d'});
    validateattributes(A,{'double'},{'2d'});
    validateattributes(b,{'double'},{'2d'});
    validateattributes(AoldTrans,{'double'},{'2d'});
    validateattributes(bold,{'double'},{'2d'});
    validateattributes(ldAold,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(numOldCols,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(workspace_compare,{'double'},{'2d'});
    validateattributes(workspace_int,{coder.internal.indexIntClass},{'2d'});
    validateattributes(workspace_tols,{'double'},{'2d'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);
    mrows=coder.internal.indexInt(size(A,1));




    iWC0=INT_ONE;
    for row=INT_ONE:mrows
        for col=INT_ZERO:(nVar-INT_ONE)
            workspace_compare(iWC0+col)=A(row+mrows*col);
        end
        workspace_compare(iWC0+nVar)=b(row);
        iWC0=iWC0+nVar+INT_ONE;
    end


    iA0=INT_ONE;
    for idx=INT_ONE:numOldCols
        for col=INT_ZERO:(nVar-INT_ONE)
            workspace_compare(iWC0+col)=AoldTrans(iA0+col);
        end
        workspace_compare(iWC0+nVar)=bold(idx);
        iWC0=iWC0+nVar+INT_ONE;
        iA0=iA0+ldAold;
    end








    [colMap,workspace_int,workspace_tols]=optim.coder.utils.uniquecoltol(...
    workspace_compare,nVar+INT_ONE,numOldCols+mrows,nVar+INT_ONE,...
    colMap,workspace_int,workspace_tols);

end