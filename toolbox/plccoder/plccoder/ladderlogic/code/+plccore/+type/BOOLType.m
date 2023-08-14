classdef BOOLType<plccore.type.AbstractType




    methods
        function obj=BOOLType
            obj.Kind='BOOL';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitBOOLType(obj,input);
        end
    end

end


