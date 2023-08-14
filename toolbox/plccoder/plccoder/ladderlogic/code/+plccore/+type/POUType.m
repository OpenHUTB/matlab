classdef POUType<plccore.type.AbstractType



    properties(Access=protected)
POU
    end

    methods
        function obj=POUType(POU)
            obj.Kind='POUType';
            obj.POU=POU;
        end

        function ret=toString(obj)
            ret=obj.POU.name;
        end

        function ret=pou(obj)
            ret=obj.POU;
        end

        function ret=name(obj)
            ret=obj.pou.name;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitPOUType(obj,input);
        end
    end
end


