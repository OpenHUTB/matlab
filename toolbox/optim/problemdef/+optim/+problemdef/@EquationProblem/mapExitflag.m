function exitflag=mapExitflag(~,fval,exitflag,solver,varargin)









    if exitflag<=0||~any(strcmp(solver,{'lsqlin','lsqnonlin'}))
        return
    end


    tolFunValue=optim.problemdef.EquationProblem.getFunctionToleranceForSolve(...
    solver,varargin{:});



    resnorm=fval(:)'*fval(:);
    if resnorm>sqrt(tolFunValue)
        exitflag=-2;
    end