classdef SINTType<plccore.type.AbstractType




    methods
        function obj=SINTType
            obj.Kind='SINT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitSINTType(obj,input);
        end
    end

end


