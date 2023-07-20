classdef INTType<plccore.type.AbstractType




    methods
        function obj=INTType
            obj.Kind='INT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitINTType(obj,input);
        end
    end

end


