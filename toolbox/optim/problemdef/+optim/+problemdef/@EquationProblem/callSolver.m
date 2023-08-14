function[x,fval,exitflag,output,lambda]=callSolver(~,probStruct)









    lambda=[];

    switch probStruct.solver
    case 'lsqlin'
        [x,~,fval,exitflag,output]=lsqlin(probStruct);

    case 'lsqnonneg'
        [x,~,fval,exitflag,output]=lsqnonneg(probStruct);


        fval=-fval;
    case 'fzero'
        iValidateX0ForNLP(probStruct)
        [x,fval,exitflag,output]=fzero(probStruct);

    case 'fsolve'
        iValidateX0ForNLP(probStruct)
        probStruct=iValidateOptionsForFsolve(probStruct);
        [x,fval,exitflag,output]=fsolve(probStruct);


        output.equationderivative=probStruct.objectiveDerivative;
    case 'lsqnonlin'
        iValidateX0ForNLP(probStruct)
        probStruct=iValidateOptionsForLsqnonlin(probStruct);
        [x,~,fval,exitflag,output]=lsqnonlin(probStruct);

        output.equationderivative=probStruct.objectiveDerivative;
    end

end

function iValidateX0ForNLP(probStruct)



    if isempty(probStruct.x0)
        error('optim_problemdef:EquationProblem:solve:MustSpecifyX0ForNLP',...
        getString(message('optim_problemdef:ProblemImpl:solve:MustSpecifyX0ForNLP')));
    end

end

function probStruct=iValidateOptionsForFsolve(probStruct)

    optim.internal.problemdef.ProblemImpl.checkForJacobianMultiplyFcn(...
    probStruct,'fsolve','fsolve_jacobian_example',"EquationProblem");

end

function probStruct=iValidateOptionsForLsqnonlin(probStruct)

    optim.internal.problemdef.ProblemImpl.checkForJacobianMultiplyFcn(...
    probStruct,'lsqnonlin','lsq_jacobian_example',"EquationProblem");

end
