function val=checkFminconParam(val,name)






%#codegen

    coder.allowpcode('plain');

    coder.internal.assert(coder.internal.isConst(val),...
    'optimlib_codegen:optimoptions:OptionValueNotConstant',name,'IfNotConst','Fail');

    if~isempty(val)

        switch name
        case 'Algorithm'

            coder.internal.assert(optim.coder.options.internal.checkStringMember(val,{'sqp','sqp-legacy'}),...
            'optimlib_codegen:optimoptions:InvalidType','Algorithm','fmincon',[char(13),'''sqp'', ''sqp-legacy''']);
        case{'MaxIterations','MaxFunctionEvaluations'}
            coder.internal.assert(optim.coder.options.internal.checkNonNegInt(val),...
            'MATLAB:optimfun:optimoptioncheckfield:nonNegIntegerStringType',...
            name);
        case{'ConstraintTolerance','OptimalityTolerance','StepTolerance'}
            coder.internal.assert(optim.coder.options.internal.checkNonNegReal(val),...
            'MATLAB:optimfun:optimoptioncheckfield:nonNegRealStringType',...
            name);
        case 'FiniteDifferenceType'
            newLine=char(13);
            coder.internal.assert(optim.coder.options.internal.checkStringMember(val,{'forward','central'}),...
            'optimlib_codegen:optimoptions:InvalidType',val,'fmincon',[newLine,'''forward''',newLine,'''central''']);
        case 'FiniteDifferenceStepSize'
            coder.internal.assert(optim.coder.options.internal.checkPosReal(val),...
            'MATLAB:optimfun:optimoptioncheckfield:notAPosMatrix',...
            name);
        case 'TypicalX'
            coder.internal.assert(isreal(val),...
            'MATLAB:optimfun:options:checkfield:nonRealEntries',name);
        case 'ObjectiveLimit'
            coder.internal.assert(optim.coder.options.internal.checkRealScalarLessThanInf(val),...
            'MATLAB:optimfun:optimoptioncheckfield:PlusInfReal',name);
        case{'ScaleProblem','SpecifyConstraintGradient','SpecifyObjectiveGradient','NonFiniteSupport','IterDisplaySQP'}
            coder.internal.assert(optim.coder.options.internal.checkLogicalScalar(val),...
            'MATLAB:optimfun:optimoptioncheckfield:NotLogicalScalar',name);
        case{'CheckGradients','Diagnostics','DiffMaxChange','DiffMinChange','Display','FunValCheck','PlotFcn','OutputFcn','UseParallel'}

        otherwise
            coder.internal.assert(false,'MATLAB:optimfun:optimset:InvalidParamName',name);
        end
    end

end