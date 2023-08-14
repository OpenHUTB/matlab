function[solvers,objectiveType,constraintType]=getValidSolvers(problem,varargin)














    compile=true;
    [solvers,objectiveType,constraintType]=...
    optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.getSolvers(...
    problem,compile,varargin{:});
end
