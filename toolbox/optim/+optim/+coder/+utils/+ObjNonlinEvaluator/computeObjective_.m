function[x,fval,status]=computeObjective_(obj,x,scales)



















%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});

    validateattributes(scales,{'struct'},{'scalar'});

    coder.internal.prefer_const(scales);

    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));

    if(isempty(obj.objfun))


        fval=0.0;
        status=SUCCESS;
        return;
    end

    fval=obj.objfun(x);

    coder.internal.assert(isscalar(fval),'optimlib:fmincon:NonScalarObj');
    coder.internal.assert(isa(fval,'double'),'optimlib_codegen:common:ObjectiveMustOutputDouble');
    coder.internal.assert(isreal(fval),'optimlib_codegen:common:ObjectiveMustOutputReal');
    coder.internal.assert(~issparse(fval),'optimlib_codegen:common:InvalidSparseObjective');


    if(obj.ScaleProblem)
        fval=scales.objective*fval;
    end

    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkScalarNonFinite(fval);

end

