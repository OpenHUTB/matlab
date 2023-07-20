classdef ULINTType<plccore.type.AbstractType




    methods
        function obj=ULINTType
            obj.Kind='ULINT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitULINTType(obj,input);
        end
    end

end


