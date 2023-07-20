classdef BitFieldType<plccore.type.AbstractType




    properties(Access=protected)
TargetFieldName
Index
    end

    methods
        function obj=BitFieldType(name,idx)
            obj.Kind='BIT';
            obj.TargetFieldName=name;
            obj.Index=idx;
        end

        function ret=target(obj)
            ret=obj.TargetFieldName;
        end

        function ret=index(obj)
            ret=obj.Index;
        end

        function ret=toString(obj)
            ret=sprintf('BIT=%s.%d',obj.target,obj.index);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitBitFieldType(obj,input);
        end
    end

end


