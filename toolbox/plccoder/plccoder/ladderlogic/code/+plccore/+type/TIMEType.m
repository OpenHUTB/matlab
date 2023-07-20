classdef TIMEType<plccore.type.AbstractType




    methods
        function obj=TIMEType
            obj.Kind='TIME';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitTIMEType(obj,input);
        end
    end

end


