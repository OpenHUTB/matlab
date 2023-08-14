function options=setSolverGradientOptionsForAD(prob,options,probStruct,GradFieldName)













    if strcmp(GradFieldName,'GradConstr')
        ExternalDerivativeName="ConstraintDerivative";
        InternalDerivativeName="constraintDerivative";
    else
        objectiveSingular=regexprep(prob.ObjectivePtyName,'(\w*)s','$1');
        ExternalDerivativeName=objectiveSingular+"Derivative";
        InternalDerivativeName="objectiveDerivative";
    end

    if isempty(options)
        options=optimoptions(probStruct.solver);
    elseif isa(options,'optim.options.SolverOptions')&&ismember(GradFieldName,probStruct.setByUserOptions)
        warning(message('optim_problemdef:OptimizationProblem:solve:SpecifyGradientIgnored',...
        'SpecifyObjectiveGradient',ExternalDerivativeName));
    elseif isstruct(options)&&isfield(options,GradFieldName)&&~isempty(options.(GradFieldName))
        warning(message('optim_problemdef:OptimizationProblem:solve:SpecifyGradientIgnored',...
        GradFieldName,ExternalDerivativeName));
    end

    validDerivativeStrings=["reverse-AD";"forward-AD";"closed-form"];
    if any(strcmpi(probStruct.(InternalDerivativeName),validDerivativeStrings))
        options.(GradFieldName)='on';
    end

end