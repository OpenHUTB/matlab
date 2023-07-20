classdef ExitflagUndefinedImpl<optim.internal.problemdef.exitflag.AbstractExitflagImpl





    properties(Constant)
        DisplayName="Undefined";
        Offset=optim.internal.problemdef.exitflag.ExitflagSolverImpl.Offset;
    end

    properties
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExitflagUndefinedImplVersion=1;
    end

    methods
        function val=subsref(obj,sub)
            if numel(sub)==2&&...
                strcmp(sub(1).type,'.')&&strcmp(sub(1).subs,'DisplayName')&&...
                strcmp(sub(2).type,'()')&&isnumeric(sub(2).subs{1})
                val=obj.DisplayName;
            else
                val=builtin('subsref',obj,sub);
            end
        end
    end

end