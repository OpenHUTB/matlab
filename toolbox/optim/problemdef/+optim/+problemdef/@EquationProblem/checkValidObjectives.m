function equationIn=checkValidObjectives(equationIn,~)








    isInvalidConstr=@(c)~((isnumeric(c)&&builtin('_isEmptySqrBrktLiteral',c))||...
    isa(c,'optim.problemdef.OptimizationEquality')||...
    (isa(c,'optim.problemdef.OptimizationConstraint')&&strcmp(getRelation(c),'==')));

    if isstruct(equationIn)
        fnames=fieldnames(equationIn);
        for i=1:numel(fnames)
            thiseqn=equationIn.(fnames{i});
            if isInvalidConstr(thiseqn)
                throwAsCaller(MException(message('optim_problemdef:EquationProblem:InvalidEquation')));
            elseif~isempty(thiseqn)
                equationIn.(fnames{i})=downcast(thiseqn);
            end
        end
    else
        if isInvalidConstr(equationIn)
            throwAsCaller(MException(message('optim_problemdef:EquationProblem:InvalidEquation')));
        elseif~isempty(equationIn)
            equationIn=downcast(equationIn);
        end
    end

end
