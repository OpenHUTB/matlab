function checkLinearInputs(nVar,Aineq,bineq,Aeq,beq,lb,ub)













%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(nVar,Aineq,bineq,Aeq,beq,lb,ub);

    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});



    coder.internal.assert(isreal(Aineq),'optimlib_codegen:common:MustBeRealValued','A');
    coder.internal.assert(isa(Aineq,'double'),'optimlib_codegen:common:MustBeDoubleType','A');
    coder.internal.assert(~issparse(Aineq),'optimlib_codegen:common:InvalidSparse','A');
    coder.internal.assert(isempty(Aineq)||all(isfinite(Aineq(:))),'optimlib_codegen:common:InfNaNComplexDetected','A');
    coder.internal.assert(isreal(bineq),'optimlib_codegen:common:MustBeRealValued','B');
    coder.internal.assert(isa(bineq,'double'),'optimlib_codegen:common:MustBeDoubleType','B');
    coder.internal.assert(~issparse(bineq),'optimlib_codegen:common:InvalidSparse','B');
    coder.internal.assert(isempty(bineq)||all(isfinite(bineq(:))),'optimlib_codegen:common:InfNaNComplexDetected','B');

    coder.internal.assert(isreal(Aeq),'optimlib_codegen:common:MustBeRealValued','Aeq');
    coder.internal.assert(isa(Aeq,'double'),'optimlib_codegen:common:MustBeDoubleType','Aeq');
    coder.internal.assert(~issparse(Aeq),'optimlib_codegen:common:InvalidSparse','Aeq');
    coder.internal.assert(isempty(Aeq)||all(isfinite(Aeq(:))),'optimlib_codegen:common:InfNaNComplexDetected','Aeq');
    coder.internal.assert(isreal(beq),'optimlib_codegen:common:MustBeRealValued','Beq');
    coder.internal.assert(isa(beq,'double'),'optimlib_codegen:common:MustBeDoubleType','Beq');
    coder.internal.assert(~issparse(beq),'optimlib_codegen:common:InvalidSparse','Beq');
    coder.internal.assert(isempty(beq)||all(isfinite(beq(:))),'optimlib_codegen:common:InfNaNComplexDetected','Beq');

    optim.coder.validate.checkBounds(nVar,lb,ub);


    coder.internal.errorIf(~isempty(Aineq)&&size(Aineq,2)~=nVar,'optimlib_codegen:common:WrongNumberOfColumnsInA',nVar);
    coder.internal.errorIf(~isempty(Aineq)&&size(Aineq,1)~=numel(bineq),'optimlib_codegen:common:AAndBinInconsistent');
    coder.internal.errorIf(~isempty(Aeq)&&size(Aeq,2)~=nVar,'optimlib_codegen:common:WrongNumberOfColumnsInAeq',nVar);
    coder.internal.errorIf(~isempty(Aeq)&&size(Aeq,1)~=numel(beq),'optimlib_codegen:common:AeqAndBeqInconsistent');

end

