classdef UINTType<plccore.type.AbstractType




    methods
        function obj=UINTType
            obj.Kind='UINT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitUINTType(obj,input);
        end
    end

end


