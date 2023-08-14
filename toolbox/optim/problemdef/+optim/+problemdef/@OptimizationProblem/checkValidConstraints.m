function conIn=checkValidConstraints(conIn)






    isInvalidConstr=@(c)~((isnumeric(c)&&builtin('_isEmptySqrBrktLiteral',c))||...
    isa(c,'optim.problemdef.OptimizationConstraint'));

    if isstruct(conIn)
        if~isscalar(conIn)||any(structfun(isInvalidConstr,conIn))
            throwAsCaller(MException(message('optim_problemdef:OptimizationProblem:InvalidConstraint')));
        end
    elseif isInvalidConstr(conIn)
        throwAsCaller(MException(message('optim_problemdef:OptimizationProblem:InvalidConstraint')));
    end

