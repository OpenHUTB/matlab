function workspace=...
    twoStepFinDiffFormulas(formulaType,ncols,workspace,idx_row,idx_colStart,ldw,...
    delta,val_current,current_idx_start,val_left,val_right)














%#codegen

    coder.allowpcode('plain');

    validateattributes(formulaType,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ncols,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(idx_row,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(idx_colStart,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldw,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(delta,{'double'},{'scalar'});
    validateattributes(val_current,{'double'},{'2d'});
    validateattributes(current_idx_start,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(val_left,{'double'},{'2d'});
    validateattributes(val_right,{'double'},{'2d'});

    coder.internal.prefer_const(ldw,delta);

    INT_ONE=coder.internal.indexInt(1);
    CENTRAL=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('Central'));
    DOUBLE_RIGHT=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('DoubleRight'));

    colIdx=coder.internal.indexInt(idx_colStart-1);
    switch(formulaType)
    case CENTRAL

        for idx_col=1:ncols
            idx_wksp=idx_row+ldw*(colIdx+idx_col-INT_ONE);
            workspace(idx_wksp)=(-val_left(idx_col)+val_right(idx_col))/(2*delta);
        end
    case DOUBLE_RIGHT

        for idx_col=1:ncols
            idx_wksp=idx_row+ldw*(colIdx+idx_col-INT_ONE);
            workspace(idx_wksp)=(-3*val_current(current_idx_start+idx_col-1)+4*val_left(idx_col)-val_right(idx_col))/(2*delta);
        end
    otherwise

        for idx_col=1:ncols
            idx_wksp=idx_row+ldw*(colIdx+idx_col-INT_ONE);
            workspace(idx_wksp)=(val_left(idx_col)-4*val_right(idx_col)+3*val_current(current_idx_start+idx_col-1))/(2*delta);
        end
    end

end