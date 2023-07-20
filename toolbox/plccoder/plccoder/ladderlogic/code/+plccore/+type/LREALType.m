classdef LREALType<plccore.type.AbstractType




    methods
        function obj=LREALType
            obj.Kind='LREAL';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitLREALType(obj,input);
        end
    end

end


