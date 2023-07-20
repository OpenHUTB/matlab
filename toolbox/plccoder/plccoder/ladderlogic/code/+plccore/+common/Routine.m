classdef Routine<plccore.common.POU




    properties(Access=protected)
Owner
    end

    methods
        function obj=Routine(name,prog)
            obj@plccore.common.POU(name,[],[],[],[]);
            obj.Kind='Routine';
            obj.Owner=prog;
        end

        function ret=program(obj)
            ret=obj.Owner;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRoutine(obj,input);
        end

    end

end


