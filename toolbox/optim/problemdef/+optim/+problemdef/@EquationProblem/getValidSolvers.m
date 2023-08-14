function solvers=getValidSolvers(problem,varargin)











    solvers=optim.internal.problemdef.solvermap.EquationProblemSolverMap.getSolvers(...
    problem,varargin{:});
end
