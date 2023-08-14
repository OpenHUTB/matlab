classdef ToolstripContext<dig.ContextProvider




    properties(SetAccess=public)
        Name;
        Property='';
        AppObject=[];
    end
    methods
        function obj=ToolstripContext()
            obj.Name='ToolstripContext';
            obj.TypeChain={};
        end
    end
end
