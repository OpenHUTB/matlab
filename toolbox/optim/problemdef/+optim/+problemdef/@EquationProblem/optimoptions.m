function options=optimoptions(prob,varargin)



















    solver=prob.determineSolver([],'optimoptions');


    if strcmp(solver,'fzero')

        options=optimset('fzero');
        options=optimset(options,varargin{:});
    else
        options=optimoptions(solver,varargin{:});




        if any(strcmp(solver,{'lsqnonlin','fsolve'}))&&isSetByUser(options,'Jacobian')
            errId='optim_problemdef:EquationProblem:optimoptions:NoSpecifyGradient';
            msgId='optim_problemdef:ProblemImpl:optimoptions:NoSpecifyGradient';
            error(errId,getString(message(msgId,'SpecifyObjectiveGradient','EquationProblem','EquationDerivative')));
        end


        options=setFromOptimProblem(options);
    end
