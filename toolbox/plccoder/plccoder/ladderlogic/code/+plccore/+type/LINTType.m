classdef LINTType<plccore.type.AbstractType




    methods
        function obj=LINTType
            obj.Kind='LINT';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitLINTType(obj,input);
        end
    end

end


