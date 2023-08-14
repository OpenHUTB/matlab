function status=checkScalarNonFinite(val)
















%#codegen

    coder.allowpcode('plain');

    validateattributes(val,{'double'},{'scalar'});

    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));
    FLAG_NAN=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('NaN'));
    FLAG_NEG_INF=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('NegInf'));
    FLAG_POS_INF=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('PosInf'));

    status=SUCCESS;




    if(eml_option('NonFinitesSupport')&&~isfinite(val))
        if isnan(val)
            status=FLAG_NAN;
        else
            if(val<0)
                status=FLAG_NEG_INF;
            else
                status=FLAG_POS_INF;
            end
        end
    end

end

