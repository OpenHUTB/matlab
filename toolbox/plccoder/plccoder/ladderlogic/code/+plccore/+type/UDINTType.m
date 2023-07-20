classdef UDINTType<plccore.type.AbstractType




    methods
        function obj=UDINTType
            obj.Kind='UDINT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitUDINTType(obj,input);
        end
    end

end


