classdef(Abstract)AbstractExitflagImpl<handle










    properties(Abstract,Constant)


DisplayName


Offset
    end

    properties(Abstract)
Solver
ProblemType
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AbstractExitflagImplVersion=1;
    end

end