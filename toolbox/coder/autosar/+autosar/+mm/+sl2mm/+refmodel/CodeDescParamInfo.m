classdef CodeDescParamInfo<handle





    properties
        BreakpointNames;
        GraphicalName;
    end
    properties(SetAccess=immutable)
        CodeDescObj;
    end
    methods
        function this=CodeDescParamInfo(codeDescObj)
            this.BreakpointNames={};
            this.CodeDescObj=codeDescObj;
            this.GraphicalName=codeDescObj.GraphicalName;
        end
    end
end
