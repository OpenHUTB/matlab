classdef Function<plccore.common.POU




    properties(Access=protected)
ReturnType
    end

    methods
        function obj=Function(name,type,input_scope,output_scope,local_scope,arglist)
            obj@plccore.common.POU(name,input_scope,output_scope,[],local_scope);
            obj.Kind='Function';
            obj.ReturnType=type;
            obj.OutputScope.clear;
            obj.OutputScope.createVar(obj.Name,obj.ReturnType);
            if(nargin>5)
                obj.setArgList(arglist);
            end
        end

        function ret=returnType(obj)
            ret=obj.ReturnType;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitFunction(obj,input);
        end
    end
end


