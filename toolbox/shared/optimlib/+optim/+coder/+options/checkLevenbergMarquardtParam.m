function val=checkLevenbergMarquardtParam(val,name,solver)






%#codegen

    coder.allowpcode('plain');

    coder.internal.assert(coder.internal.isConst(val),...
    'optimlib_codegen:optimoptions:OptionValueNotConstant',name,'IfNotConst','Fail');

    if~isempty(val)

        switch name
        case 'Algorithm'
            coder.internal.assert(optim.coder.options.internal.checkStringMember(val,{'levenberg-marquardt'}),...
            'optimlib_codegen:optimoptions:InvalidType','Algorithm',solver,[char(13),'''levenberg-marquardt''']);
        case{'CheckGradients','SpecifyObjectiveGradient'}
            coder.internal.assert(optim.coder.options.internal.checkLogicalScalar(val),...
            'MATLAB:optimfun:optimoptioncheckfield:NotLogicalScalar',name);
        case 'Display'
            coder.internal.assert(optim.coder.options.internal.checkStringMember(val,{'off','none','iter','iter-detailed','final','final-detailed','testing'}),...
            'optimlib_codegen:optimoptions:InvalidType','Display',solver,[char(13),'''none'', ''off'', ''iter'', ''iter-detailed'', ''final'', ''final-detailed''']);
        case 'FiniteDifferenceType'
            coder.internal.assert(optim.coder.options.internal.checkStringMember(val,{'forward','central'}),...
            'optimlib_codegen:optimoptions:InvalidType','FiniteDifferenceType',solver,[char(13),'''forward'', ''central''']);
        case{'FunctionTolerance','StepTolerance','InitDamping'}
            coder.internal.assert(optim.coder.options.internal.checkPosReal(val),...
            'MATLAB:optimfun:optimoptioncheckfield:posRealStringType',name);
            coder.internal.assert(isscalar(val),...
            'MATLAB:optimfun:optimoptioncheckfield:posRealStringType',name);
        case{'MaxFunctionEvaluations','MaxIterations'}
            coder.internal.assert(optim.coder.options.internal.checkNonNegInt(val),...
            'MATLAB:optimfun:optimoptioncheckfield:nonNegIntegerStringType',name);
        case 'ScaleProblem'
            coder.internal.assert(optim.coder.options.internal.checkStringMember(val,{'none','jacobian'}),...
            'optimlib_codegen:optimoptions:InvalidType','ScaleProblem',solver,[char(13),'''none'', ''jacobian''']);
        case{'FiniteDifferenceStepSize','OutputFcn','PlotFcn','TypicalX'}

        otherwise
            coder.internal.assert(false,'MATLAB:optimfun:optimset:InvalidParamName',name);
        end
    end

end