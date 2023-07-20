classdef ExitflagFsolveImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





    properties(Constant)
        DisplayName=createDisplayName;
        Offset=optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset;
    end

    properties
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagFsolveImplVersion=1;
    end

end

function dispName=createDisplayName()
    dispName=optim.internal.problemdef.exitflag.ExitflagEqnImpl.DisplayName;
    dispName(-3+optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset)='TrustRegionRadiusTooSmall';
    dispName(-2+optim.internal.problemdef.exitflag.ExitflagEqnImpl.Offset)='ResultIsNotARoot';
end