function validateSolverForMultiplePoint(p,globalSolver,solver)








    globalSolverName=class(globalSolver);
    ValidSolverProperty=globalSolverName+"Solvers";
    if~any(strcmp(solver,p.(ValidSolverProperty)))
        error(message('optim_problemdef:OptimizationProblem:solve:MultipleStartNotSupported',...
        globalSolverName,solver));
    end

