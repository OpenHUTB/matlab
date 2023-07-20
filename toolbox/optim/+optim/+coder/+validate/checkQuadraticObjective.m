function checkQuadraticObjective(H,f,nameH,nameF)













%#codegen


    coder.allowpcode('plain');

    validateattributes(nameH,{'char'},{'scalar'});
    validateattributes(nameF,{'char'},{'scalar'});

    coder.internal.prefer_const(H,f,nameH,nameF);

    coder.internal.assert(isreal(H),'optimlib_codegen:common:MustBeRealValued',nameH);
    coder.internal.assert(isa(H,'double'),'optimlib_codegen:common:MustBeDoubleType',nameH);
    coder.internal.assert(~issparse(H),'optimlib_codegen:common:InvalidSparse',nameH);
    coder.internal.assert(all(isfinite(H(:))),'optimlib_codegen:common:InfNaNComplexDetected',nameH);

    coder.internal.assert(isreal(f),'optimlib_codegen:common:MustBeRealValued',nameF);
    coder.internal.assert(isa(f,'double'),'optimlib_codegen:common:MustBeDoubleType',nameF);
    coder.internal.assert(~issparse(f),'optimlib_codegen:common:InvalidSparse',nameF);
    coder.internal.assert(all(isfinite(f(:))),'optimlib_codegen:common:InfNaNComplexDetected',nameF);

end

