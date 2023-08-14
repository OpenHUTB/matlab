function[autoSolver,validSolvers]=solvers(prob)











    validSolvers=string(getValidSolvers(prob));
    if isempty(validSolvers)
        autoSolver=validSolvers;
    else
        autoSolver=validSolvers(1);
    end
