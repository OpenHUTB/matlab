function checkX0(x0)










%#codegen


    coder.allowpcode('plain');
    coder.internal.prefer_const(x0);


    coder.internal.assert(isa(x0,'double'),'optimlib_codegen:common:MustBeDoubleType','x0');


    coder.internal.errorIf(isempty(x0),'optimlib_codegen:common:EmptyX');
    coder.internal.assert(isreal(x0),'optimlib_codegen:common:MustBeRealValued','x0');
    coder.internal.errorIf(issparse(x0),'optimlib_codegen:common:InvalidSparse','x0');
    if eml_option('NonFinitesSupport')
        coder.internal.assert(all(isfinite(x0),'all'),'optimlib_codegen:common:InfNaNComplexDetected','x0');
    end

end
