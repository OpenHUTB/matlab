classdef ExitflagFzeroImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





    properties(Constant)
        DisplayName=createDisplayName;
        Offset=optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset;
    end

    properties
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagFzeroImplVersion=1;
    end

end

function dispName=createDisplayName()
    dispName=optim.internal.problemdef.exitflag.ExitflagEqnImpl.DisplayName;
    dispName(-3+optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset)='FoundNaNOrInf';
    dispName(-4+optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset)='FoundComplex';
    dispName(-5+optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset)='SingularPoint';
    dispName(-6+optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset)='CannotDetectSignChange';
end