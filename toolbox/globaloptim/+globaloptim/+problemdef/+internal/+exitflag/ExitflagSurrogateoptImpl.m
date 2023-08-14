classdef ExitflagSurrogateoptImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





    properties(Constant)
        DisplayName=createDisplayName;
        Offset=optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset;
    end

    properties
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagGAImplVersion=1;
    end

end

function dispName=createDisplayName()
    dispName=globaloptim.problemdef.internal.exitflag.ExitflagGlobalSolverImpl.DisplayName;
    dispName(1+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)="ObjectiveLimitAttained";
    dispName(3+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)="FeasiblePointFound";
    dispName(10+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)="BoundsEqual";

end
