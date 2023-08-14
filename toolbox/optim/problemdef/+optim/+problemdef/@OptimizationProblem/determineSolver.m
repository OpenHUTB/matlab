function solver=determineSolver(prob,probStruct,caller)













    hasIntCon=hasIntegerConstraints(prob,probStruct);



    [validSolvers,objectiveType,constraintType]=getValidSolvers(prob,hasIntCon);


    if isempty(validSolvers)


        if optim.internal.utils.hasGlobalOptimizationToolbox


            mID='optim_problemdef:OptimizationProblem:%s:IntegerNonlEqConstr';
        elseif strcmp(objectiveType,'Multi')
            mID='optim_problemdef:OptimizationProblem:%s:MultiObjective';
        else
            if any(strcmp(objectiveType,{'Quadratic','LinearLeastSquares'}))&&...
                ~any(strcmp(constraintType,{'SecondOrderCone','Nonlinear'}))
                mID='optim_problemdef:OptimizationProblem:%s:IntegerQP';
            else
                mID='optim_problemdef:OptimizationProblem:%s:IntegerNLP';
            end
        end


        throwAsCaller(MException(sprintf(mID,caller),...
        getString(message(sprintf(mID,'solve')))));
    end


    solver=validSolvers{1};
end
