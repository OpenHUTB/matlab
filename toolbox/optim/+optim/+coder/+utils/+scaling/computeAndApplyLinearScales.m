function[A,b,workspace]=computeAndApplyLinearScales(A,b,mrows,ncols,workspace)















%#codegen

    coder.allowpcode('plain');


    validateattributes(A,{'double'},{'2d'});
    validateattributes(mrows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ncols,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});

    tol=2.0*eps('double');


    for idx_row=1:mrows
        workspace(idx_row)=abs(A(idx_row,1));
    end


    for idx_col=2:ncols
        for idx_row=1:mrows
            workspace(idx_row)=max(workspace(idx_row),abs(A(idx_row,idx_col)));
        end
    end

    for idx_row=1:mrows
        if(workspace(idx_row)<tol)
            workspace(idx_row)=1.0;
        end

        workspace(idx_row)=min(1.0,100.0/workspace(idx_row));
        workspace(idx_row)=max(1e-8,workspace(idx_row));
    end



    for idx_row=1:mrows
        b(idx_row)=b(idx_row)*workspace(idx_row);
    end

    for idx_col=1:ncols
        for idx_row=1:mrows
            A(idx_row,idx_col)=A(idx_row,idx_col)*workspace(idx_row);
        end
    end

end

