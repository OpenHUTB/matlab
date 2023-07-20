classdef ExitflagMultipleStartPointsSolverImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





    properties(Constant)
        DisplayName=createDisplayName
        Offset=computeOffset
    end

    properties
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagSolverImplVersion=1;
    end

end

function dispName=createDisplayName()

    dispName=strings(1,13);
    dispName(1)="FailureInSuppliedFcn";
    dispName(3)="NoSolutionFound";
    dispName(6)="TimeLimitExceeded";
    dispName(9)="NoFeasibleLocalMinimumFound";
    dispName(10)="OutputFcnStop";
    dispName(11)="SolverLimitExceeded";
    dispName(12)="LocalMinimumFoundAllConverged";
    dispName(13)="LocalMinimumFoundSomeConverged";

end

function offset=computeOffset



    offset=find(contains(globaloptim.problemdef.internal.exitflag.ExitflagMultipleStartPointsSolverImpl.DisplayName,"SolverLimitExceeded"));
end