classdef DINTType<plccore.type.AbstractType




    methods
        function obj=DINTType
            obj.Kind='DINT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitDINTType(obj,input);
        end
    end

end


