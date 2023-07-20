function[ATrans,b,workspace]=computeAndApplyNonlinearScales(ATrans,b,iColStart,mrows,ncols,ldA,workspace)















%#codegen

    coder.allowpcode('plain');


    validateattributes(ATrans,{'double'},{'2d'});
    validateattributes(mrows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ncols,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});

    coder.internal.prefer_const(mrows,ncols,ldA);

    if(mrows*ncols==0)
        return;
    end

    INT_ONE=coder.internal.indexInt(1);
    tol=2.0*eps('double');



    idx_scale=coder.internal.indexInt(1);
    iAT0=1+ldA*(iColStart-1);
    for idx_col=iColStart:ncols
        idx_max=coder.internal.blas.ixamax(mrows,ATrans,iAT0,INT_ONE);
        workspace(idx_scale)=abs(ATrans(iAT0+idx_max-1));


        if(workspace(idx_scale)<tol)
            workspace(idx_scale)=1.0;
        end

        workspace(idx_scale)=min(1.0,100.0/workspace(idx_scale));
        workspace(idx_scale)=max(1e-8,workspace(idx_scale));



        ATrans=coder.internal.blas.xscal(mrows,workspace(idx_scale),ATrans,iAT0,INT_ONE);
        b(idx_col)=b(idx_col)*workspace(idx_scale);

        iAT0=iAT0+ldA;
        idx_scale=idx_scale+1;
    end

end

