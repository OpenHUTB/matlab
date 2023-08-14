function options=optimoptions(prob,varargin)



















    solver=prob.determineSolver([],'optimoptions');


    options=optimoptions(solver,varargin{:});




    if any(strcmp(solver,{'fminunc','fmincon'}))&&isSetByUser(options,'GradObj')
        error(message('optim_problemdef:ProblemImpl:optimoptions:NoSpecifyGradient',...
        'SpecifyObjectiveGradient','OptimizationProblem','ObjectiveDerivative'));
    end
    if strcmp(solver,'fmincon')&&isSetByUser(options,'GradConstr')
        error(message('optim_problemdef:ProblemImpl:optimoptions:NoSpecifyGradient',...
        'SpecifyConstraintGradient','OptimizationProblem','ConstraintDerivative'));
    end
    if strcmp(solver,'lsqnonlin')&&isSetByUser(options,'Jacobian')
        error(message('optim_problemdef:ProblemImpl:optimoptions:NoSpecifyGradient',...
        'SpecifyObjectiveGradient','OptimizationProblem','ObjectiveDerivative'));
    end


    options=setFromOptimProblem(options);
