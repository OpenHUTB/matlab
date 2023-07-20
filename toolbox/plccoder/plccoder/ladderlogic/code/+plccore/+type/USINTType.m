classdef USINTType<plccore.type.AbstractType




    methods
        function obj=USINTType
            obj.Kind='USINT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitUSINTType(obj,input);
        end
    end

end


