function[gradOK,val]=computeDualFeasError(fscales,nVar,gradLag,options)












%#codegen

    coder.allowpcode('plain');


    validateattributes(fscales,{'struct'},{'scalar'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(gradLag,{'double'},{'2d'});
    validateattributes(options,{'struct'},{'scalar'});

    coder.internal.prefer_const(nVar,options);

    INT_ONE=coder.internal.indexInt(1);

    gradOK=true;

    if~options.NonFiniteSupport
        idx_max=coder.internal.blas.ixamax(nVar,gradLag,INT_ONE,INT_ONE);
        val=abs(gradLag(idx_max))/fscales.objective;
    else
        val=0.0;
        for idx=1:nVar
            gradOK=optim.coder.utils.isFiniteScalar(gradLag(idx));
            if~gradOK
                return;
            end
            val=max(val,abs(gradLag(idx)));
        end

        val=val/fscales.objective;
    end

end

