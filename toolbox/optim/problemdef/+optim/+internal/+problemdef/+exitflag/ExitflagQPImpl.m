classdef ExitflagQPImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





    properties(Constant)
        DisplayName=createDisplayName;
        Offset=optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset;
    end

    properties
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagQPImplVersion=1;
    end

end

function dispName=createDisplayName()
    dispName=optim.internal.problemdef.exitflag.ExitflagSolverImpl.DisplayName;
    dispName(4+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)='LocalMinimumFound';
end
