classdef ConstTrue<plccore.common.ConstValue




    methods
        function obj=ConstTrue
            obj@plccore.common.ConstValue(plccore.type.BOOLType,'TRUE');
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitConstTrue(obj,input);
        end
    end
end


