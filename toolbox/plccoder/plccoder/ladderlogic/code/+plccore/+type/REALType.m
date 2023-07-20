classdef REALType<plccore.type.AbstractType




    methods
        function obj=REALType
            obj.Kind='REAL';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitREALType(obj,input);
        end
    end

end


