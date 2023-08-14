function probStruct=updateOptions(prob,probStruct)











    options=probStruct.options;




    if isa(options,'optim.options.SolverOptions')
        options=convertForSolver(options,probStruct.solver);
    end


    switch probStruct.solver
    case "fsolve"
        options=setSolverGradientOptionsForAD(prob,options,probStruct,'Jacobian');
    case "lsqnonlin"
        options=setSolverGradientOptionsForAD(prob,options,probStruct,'Jacobian');
    end


    probStruct.options=options;

end


