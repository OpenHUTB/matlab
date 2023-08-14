function savelinparsolution(obj,frequency,solution)


    if isa(obj.SolverStruct.Solution,'FieldSolver2d')
        obj.SolverStruct.Solution.Frequency=...
        [obj.SolverStruct.Solution.Frequency,frequency];

        obj.SolverStruct.Solution.FieldSolver2d=...
        [obj.SolverStruct.Solution.FieldSolver2d,solution];
    else
        obj.SolverStruct.Solution.Frequency=frequency;
        obj.SolverStruct.Solution.FieldSolver2d=solution;
    end

end

