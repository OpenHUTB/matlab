classdef ConstFalse<plccore.common.ConstValue




    methods
        function obj=ConstFalse
            obj@plccore.common.ConstValue(plccore.type.BOOLType,'FALSE');
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitConstFalse(obj,input);
        end
    end
end


