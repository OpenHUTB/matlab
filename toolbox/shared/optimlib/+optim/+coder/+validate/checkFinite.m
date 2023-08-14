function[evalOK,x]=checkFinite(x,m,n)


















%#codegen


    coder.allowpcode('plain');
    coder.internal.prefer_const(x,m,n);

    validateattributes(m,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(n,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.assert(isa(x,'double'),'optimlib_codegen:common:ObjectiveMustOutputDouble');


    coder.internal.assert(isreal(x),'optimlib_codegen:common:ObjectiveMustOutputReal');
    coder.internal.assert(~issparse(x),'optimlib_codegen:common:InvalidSparseObjective');
    if m==1||n==1
        coder.internal.assert(numel(x)==m*n,'optimlib_codegen:common:IncorrectSizeObjective',m*n);
    elseif m>1&&n>1
        coder.internal.assert(numel(x)==m*n,'optimlib_codegen:common:IncorrectSizeObjectiveJacobian',m,n);
    end

    evalOK=true;
    if eml_option('NonFinitesSupport')
        for i=1:m*n
            evalOK=evalOK&&isfinite(x(i));
        end
    end

end
