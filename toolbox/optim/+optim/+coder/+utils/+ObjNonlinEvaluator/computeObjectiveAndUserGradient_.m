function[x,fval,grad_workspace,status]=...
    computeObjectiveAndUserGradient_(obj,x,grad_workspace,iGradStart,scales)





















%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});

    validateattributes(grad_workspace,{'double'},{'vector'});
    validateattributes(iGradStart,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(scales,{'struct'},{'scalar'});

    coder.internal.prefer_const(scales);

    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));

    INT_ONE=coder.internal.indexInt(1);

    if(isempty(obj.objfun))



        fval=0.0;
        status=SUCCESS;
        return;
    end





    [fval,grad_tmp]=obj.objfun(x);



    coder.internal.assert(isscalar(fval),'optimlib:fmincon:NonScalarObj');
    coder.internal.assert(isa(fval,'double'),'optimlib_codegen:common:ObjectiveMustOutputDouble');
    coder.internal.assert(isreal(fval),'optimlib_codegen:common:ObjectiveMustOutputReal');
    coder.internal.assert(~issparse(fval),'optimlib_codegen:common:InvalidSparseObjective');
    coder.internal.assert(~isempty(grad_tmp)&&numel(grad_tmp)==numel(x),'optimlib:commonMsgs:InvalidSizeOfGradient',numel(x));
    coder.internal.assert(isa(grad_tmp,'double'),'optimlib_codegen:common:ObjectiveMustOutputDouble');
    coder.internal.assert(isreal(grad_tmp),'optimlib:commonMsgs:ComplexGradient');
    coder.internal.assert(~issparse(grad_tmp),'optimlib_codegen:common:InvalidSparseObjective');

    grad_workspace=coder.internal.blas.xcopy(obj.nVar,grad_tmp,INT_ONE,INT_ONE,grad_workspace,iGradStart,INT_ONE);


    if(obj.ScaleProblem)

        fval=scales.objective*fval;

        grad_workspace=coder.internal.blas.xscal(obj.nVar,scales.objective,grad_workspace,iGradStart,INT_ONE);
    end


    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkScalarNonFinite(fval);


    if(status~=SUCCESS)
        return;
    end


    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkVectorNonFinite(obj.nVar,grad_workspace,iGradStart);

end
