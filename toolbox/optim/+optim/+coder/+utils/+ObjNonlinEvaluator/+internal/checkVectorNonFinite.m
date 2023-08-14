function status=checkVectorNonFinite(N,vec,iv0)
















%#codegen

    coder.allowpcode('plain');

    validateattributes(N,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(vec,{'double'},{'2d'});
    validateattributes(iv0,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(N);

    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));
    FLAG_NAN=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('NaN'));
    FLAG_NEG_INF=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('NegInf'));
    FLAG_POS_INF=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('PosInf'));

    status=SUCCESS;
    allFinite=true;


    if(eml_option('NonFinitesSupport'))


        idx_current=iv0;
        idx_end=idx_current+N-1;
        while(allFinite&&idx_current<=idx_end)
            allFinite=isfinite(vec(idx_current));
            idx_current=idx_current+1;
        end

        if(~allFinite)
            idx_current=idx_current-1;
            if isnan(vec(idx_current))
                status=FLAG_NAN;
            else
                if(vec(idx_current)<0)
                    status=FLAG_NEG_INF;
                else
                    status=FLAG_POS_INF;
                end
            end
        end

    end

end

