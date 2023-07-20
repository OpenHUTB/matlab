classdef ConstValue<plccore.common.Object




    properties(Access=protected)
Value
Type
    end

    methods
        function obj=ConstValue(type,value)
            obj.Kind='Value';
            obj.Type=type;
            obj.Value=value;
        end

        function ret=value(obj)
            ret=obj.Value;
        end

        function ret=type(obj)
            ret=obj.Type;
        end

        function ret=toString(obj)
            ret=sprintf('%s',obj.value);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitConstValue(obj,input);
        end
    end
end


