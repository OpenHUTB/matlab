function status=checkMatrixNonFinite(mrows,ncols,mat,row0,col0,ldm)
















%#codegen

    coder.allowpcode('plain');


    validateattributes(mrows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ncols,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mat,{'double'},{'2d'});
    validateattributes(row0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(col0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldm,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(mrows,ncols,ldm);

    INT_ONE=coder.internal.indexInt(1);
    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));
    FLAG_NAN=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('NaN'));
    FLAG_NEG_INF=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('NegInf'));
    FLAG_POS_INF=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('PosInf'));

    status=SUCCESS;

    allFinite=true;


    if(eml_option('NonFinitesSupport'))

        row=row0;
        col=col0;
        col_end=col+ncols-1;
        row_end=row0+mrows-1;
        while(allFinite&&col<=col_end)
            row=row0;
            while(allFinite&&row<=row_end)
                idx_mat=row+ldm*(col-INT_ONE);
                allFinite=isfinite(mat(idx_mat));
                row=row+1;
            end
            col=col+1;
        end

        if(~allFinite)
            col=col-1;
            row=row-1;
            idx_mat=row+ldm*(col-INT_ONE);
            if isnan(mat(idx_mat))
                status=FLAG_NAN;
            else
                if(mat(idx_mat)<0)
                    status=FLAG_NEG_INF;
                else
                    status=FLAG_POS_INF;
                end
            end
        end

    end

end

