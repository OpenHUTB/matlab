function checkBounds(nVar,lb,ub)










%#codegen


    coder.allowpcode('plain');
    coder.internal.prefer_const(nVar,lb,ub);

    coder.internal.assert(isa(lb,'double'),'optimlib_codegen:common:MustBeDoubleType','lb');


    coder.internal.assert(isempty(lb)||numel(lb)==nVar,'optimlib_codegen:common:InvalidPartialBounds','lb',nVar);
    coder.internal.assert(isreal(lb),'optimlib_codegen:common:MustBeRealValued','lb');
    coder.internal.errorIf(issparse(lb),'optimlib_codegen:common:InvalidSparse','lb');
    coder.internal.errorIf(any(lb>=optim.coder.infbound,'all')||any(isnan(lb),'all'),'optimlib_codegen:common:InfNaNComplexDetectedLB');

    coder.internal.assert(isa(ub,'double'),'optimlib_codegen:common:MustBeDoubleType','ub');


    coder.internal.assert(isempty(ub)||numel(ub)==nVar,'optimlib_codegen:common:InvalidPartialBounds','ub',nVar);
    coder.internal.assert(isreal(ub),'optimlib_codegen:common:MustBeRealValued','ub');
    coder.internal.errorIf(issparse(ub),'optimlib_codegen:common:InvalidSparse','ub');
    coder.internal.errorIf(any(ub<=-optim.coder.infbound,'all')||any(isnan(ub),'all'),'optimlib_codegen:common:InfNaNComplexDetectedUB');

end
