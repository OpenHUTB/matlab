classdef FunctionInfo<handle

    properties

        Name(1,1)string;
        Signature(1,1)string;
        IsEntryFunction(1,1)logical=false;
        IsDefined(1,1)logical;
        IsDeclared(1,1)logical
        IsStub(1,1)logical=false;
    end

    properties(Hidden,Transient)
        Function=[];
    end

end