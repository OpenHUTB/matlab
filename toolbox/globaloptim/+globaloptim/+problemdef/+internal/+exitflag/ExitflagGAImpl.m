classdef ExitflagGAImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





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
    dispName(4+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)="StepSizeTooSmall";
    dispName(5+optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset)="MinimumFitnessLimitReached";

end
