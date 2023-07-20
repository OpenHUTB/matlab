classdef(Abstract)RungOp<plccore.common.Object




    methods
        function obj=RungOp
            obj.Kind='RungOp';
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRungOp(obj,input);
        end
    end

end

