function[idx,workspace_int,workspace_tols]=uniquecoltol(A,mrows,ncols,ldA,...
    idx,workspace_int,workspace_tols)















































%#codegen

    coder.allowpcode('plain');

    validateattributes(A,{'double'},{'2d'});
    validateattributes(mrows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ncols,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldA,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(idx,{coder.internal.indexIntClass},{'2d'});
    validateattributes(workspace_int,{coder.internal.indexIntClass},{'2d'});
    validateattributes(workspace_tols,{'double'},{'2d'});

    coder.internal.prefer_const(mrows,ncols,ldA);

    absTol=1e-12;
    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    if(mrows<INT_ONE||ncols<INT_ONE)
        return;
    end





    workspace_tols=coder.internal.blas.xcopy(mrows,1.0,INT_ONE,INT_ZERO,workspace_tols,INT_ONE,INT_ONE);

    ia0=INT_ZERO;
    for col=INT_ONE:ncols
        for row=INT_ONE:mrows
            workspace_tols(row)=max(workspace_tols(row),abs(A(ia0+row)));
        end
        ia0=ia0+ldA;
    end



    workspace_tols=coder.internal.blas.xscal(mrows,absTol,workspace_tols,INT_ONE,INT_ONE);




    for col=INT_ONE:ncols
        workspace_int(col)=col;
    end


    workspace_int=coder.internal.introsort(workspace_int,INT_ONE,ncols,...
    @(col1,col2)col_lt_cmp(A,col1,col2,mrows,ldA,workspace_tols));


    INT_MAX=intmax(coder.internal.indexIntClass);
    eqStreakStartLocalCol=INT_MAX;
    eqStreakMinGlobalCol=INT_MAX;

    global_idx_m1=workspace_int(INT_ONE);
    idx(global_idx_m1)=global_idx_m1;

    col=coder.internal.indexInt(2);
    while(col<=ncols)
        global_idx_m1=workspace_int(col-1);
        global_idx=workspace_int(col);
        colsEqual=col_eq_cmp(A,global_idx_m1,global_idx,mrows,ldA,workspace_tols);
        if colsEqual

            if(eqStreakStartLocalCol==INT_MAX)
                eqStreakStartLocalCol=col-1;
                eqStreakMinGlobalCol=global_idx_m1;
            end
            eqStreakMinGlobalCol=min(eqStreakMinGlobalCol,global_idx);
        else
            idx(global_idx)=global_idx;

            for dup_col_visited=eqStreakStartLocalCol:(col-1)
                dup_global_idx=workspace_int(dup_col_visited);
                idx(dup_global_idx)=eqStreakMinGlobalCol;
            end
            eqStreakStartLocalCol=INT_MAX;
            eqStreakMinGlobalCol=INT_MAX;
        end
        col=col+INT_ONE;
    end


    for dup_col_visited=eqStreakStartLocalCol:(col-1)
        dup_global_idx=workspace_int(dup_col_visited);
        idx(dup_global_idx)=eqStreakMinGlobalCol;
    end

end


function tf=col_lt_cmp(A,col1,col2,mrows,ldA,rowTols)
    coder.inline('always');

    [~,row]=col_eq_cmp(A,col1,col2,mrows,ldA,rowTols);
    tf=val_lt_tol(A(row+ldA*(col1-1)),A(row+ldA*(col2-1)),rowTols(row));

end

function[tf,row]=col_eq_cmp(A,col1,col2,mrows,ldA,rowTols)
    coder.inline('always');

    INT_ONE=coder.internal.indexInt(1);
    row=INT_ONE;

    tf=val_eq_tol(A(row+ldA*(col1-1)),A(row+ldA*(col2-1)),rowTols(row));
    while(tf&&row<mrows)
        row=row+INT_ONE;
        tf=val_eq_tol(A(row+ldA*(col1-1)),A(row+ldA*(col2-1)),rowTols(row));
    end

end


function tf=val_lt_tol(a,b,tol)
    coder.inline('always');
    tf=(a<b)||((b<a)&&(b>a-tol));
end

function tf=val_eq_tol(a,b,tol)
    coder.inline('always');
    tf=(abs(a-b)<=tol);
end

