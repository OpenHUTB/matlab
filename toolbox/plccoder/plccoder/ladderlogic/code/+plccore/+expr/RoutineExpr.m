classdef RoutineExpr<plccore.expr.AbstractExpr




    properties(Access=private)
Routine
    end

    methods
        function obj=RoutineExpr(routine)
            obj.Kind='RoutineExpr';
            obj.Routine=routine;
        end

        function ret=routine(obj)
            ret=obj.Routine;
        end

        function ret=toString(obj)
            ret=sprintf('%s',obj.routine.name);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitRoutineExpr(obj,input);
        end
    end
end

