function probStruct=updateProbStruct(prob,caller,probStruct,solvername)













    if strcmp(probStruct.solver,solvername)

        return;
    end



    switch probStruct.solver

    case 'lsqlin'

        switch solvername
        case 'lsqnonneg'


            iValidateLSQNONNEG(probStruct);
        case 'fzero'


            if~linearProblemCanBeSolvedWithFzero(prob,probStruct)

                throwAsCaller(iErrorIncompatibleSolver(solvername,caller,probStruct.solver));
            else

                probStruct=createLinearEquationFunction(probStruct);
            end
        case 'fsolve'
            if hasBounds(prob)

                throwAsCaller(iErrorIncompatibleSolver(solvername,caller,probStruct.solver));
            else

                probStruct=createLinearEquationFunction(probStruct);
            end
        case 'lsqnonlin'
            probStruct=createLinearEquationFunction(probStruct);
        end

    case 'fzero'

        switch solvername
        case{'fsolve','lsqnonlin'}

        otherwise

            throwAsCaller(iErrorIncompatibleSolver(solvername,caller,probStruct.solver));
        end

    case 'fsolve'
        switch solvername
        case 'lsqnonlin'

        otherwise

            throwAsCaller(iErrorIncompatibleSolver(solvername,caller,probStruct.solver));
        end

    otherwise

        throwAsCaller(iErrorIncompatibleSolver(solvername,caller,probStruct.solver));

    end


    probStruct.solver=solvername;

end



function iValidateLSQNONNEG(probStruct)


    LB=probStruct.lb;
    if isempty(LB)||any(LB,'all')
        throwAsCaller(MException('optim_problemdef:EquationProblem:solve:LsqnonnegLB',...
        getString(message('optim_problemdef:ProblemImpl:solve:LsqnonnegLB'))));
    end


    if~all(isinf(probStruct.ub),'all')
        throwAsCaller(MException('optim_problemdef:EquationProblem:solve:LsqnonnegConstr',...
        getString(message('optim_problemdef:ProblemImpl:solve:LsqnonnegConstr'))));
    end

end



function probStruct=createLinearEquationFunction(probStruct)



    A=probStruct.C;
    b=probStruct.d;
    probStruct.objective=@(x)linearEquationFcn(x,A,b);
    probStruct=rmfield(probStruct,{'C','d'});
    probStruct.objectiveDerivative="closed-form";

end



function MEx=iErrorIncompatibleSolver(solvername,caller,autoSelectedSolver)

    MEx=MException(...
    "optim_problemdef:EquationProblem:"+caller+":IncompatibleSolver",...
    getString(message("optim_problemdef:ProblemImpl:"+caller+":IncompatibleSolver",...
    solvername,autoSelectedSolver)));

end



function okFzero=linearProblemCanBeSolvedWithFzero(prob,probStruct)

    if hasBounds(prob)
        okFzero=false;
        return;
    end


    varStruct=prob.Variables;
    varNames=fieldnames(varStruct);
    singleScalarVar=numel(varNames)==1&&numel(varStruct.(varNames{1}))==1;

    singleScalarEqn=isscalar(probStruct.C);

    okFzero=singleScalarVar&&singleScalarEqn;
end

function[fval,jac]=linearEquationFcn(x,A,b)

    fval=A*x-b;
    if nargout>1
        jac=A;
    end

end