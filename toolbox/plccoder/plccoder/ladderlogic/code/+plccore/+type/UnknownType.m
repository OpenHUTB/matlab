classdef UnknownType<plccore.type.AbstractType




    properties
Name
    end

    methods
        function obj=UnknownType(name)
            obj.Kind='UnknownType';
            obj.Name=name;
        end

        function ret=name(obj)
            ret=obj.Name;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitUnknownType(obj,input);
        end
    end
end


