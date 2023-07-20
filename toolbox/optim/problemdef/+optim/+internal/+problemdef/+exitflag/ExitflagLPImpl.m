classdef ExitflagLPImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





    properties(Constant)
        DisplayName=createDisplayName;
        Offset=optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset;
    end

    properties
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagLPImplVersion=1;
    end

end

function dispName=createDisplayName()
    dispName=optim.internal.problemdef.exitflag.ExitflagSolverImpl.DisplayName;
    dispName(3+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)='OptimalWithPoorFeasibility';
    dispName(2+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)='IntegerFeasible';
    dispName(-4+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)='FoundNaN';
end
