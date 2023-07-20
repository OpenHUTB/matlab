function solver=determineSolver(prob,probStruct,caller)













    hasIntCon=hasIntegerConstraints(prob,probStruct);


    if hasIntCon
        mID='optim_problemdef:EquationProblem:%s:IntegerEqn';
        throwAsCaller(MException(sprintf(mID,caller),...
        getString(message(sprintf(mID,'solve')))));
    end


    validSolvers=getValidSolvers(prob,hasIntCon);


    solver=validSolvers{1};
end
