function val=checkQuadprogParam(val,name)






%#codegen

    coder.allowpcode('plain');

    coder.internal.assert(coder.internal.isConst(val),...
    'optimlib_codegen:optimoptions:OptionValueNotConstant',name,'IfNotConst','Fail');

    if~isempty(val)

        switch name
        case 'Algorithm'

            coder.internal.assert(optim.coder.options.internal.checkStringMember(val,{'active-set'}),...
            'optimlib_codegen:optimoptions:InvalidType','Algorithm','quadprog',[char(13),'''active-set''']);
        case{'MaxIterations'}
            coder.internal.assert(optim.coder.options.internal.checkNonNegInt(val),...
            'MATLAB:optimfun:optimoptioncheckfield:nonNegIntegerStringType',...
            name);
        case{'ConstraintTolerance','OptimalityTolerance','StepTolerance'}
            coder.internal.assert(optim.coder.options.internal.checkNonNegReal(val),...
            'MATLAB:optimfun:optimoptioncheckfield:nonNegRealStringType',...
            name);
        case{'ObjectiveLimit','PricingTolerance'}
            coder.internal.assert(optim.coder.options.internal.checkRealScalarLessThanInf(val),...
            'MATLAB:optimfun:optimoptioncheckfield:PlusInfReal',name);
        case{'IterDisplayQP'}
            coder.internal.assert(optim.coder.options.internal.checkLogicalScalar(val),...
            'MATLAB:optimfun:optimoptioncheckfield:NotLogicalScalar',name);
        case{'Display','FunctionTolerance','JacobianMultiplyFcn',...
            'LinearSolver','TypicalX','SubproblemAlgorithm'}

        otherwise
            coder.internal.assert(false,'MATLAB:optimfun:optimset:InvalidParamName',name);
        end
    end

end