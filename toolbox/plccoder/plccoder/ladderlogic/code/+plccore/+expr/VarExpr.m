classdef VarExpr<plccore.expr.AbstractExpr




    properties(Access=protected)
Var
    end

    methods
        function obj=VarExpr(var)
            obj.Kind='VarExpr';
            obj.Var=var;
        end

        function ret=toString(obj)
            ret=sprintf('%s',obj.Var.name);
        end

        function ret=var(obj)
            ret=obj.Var;
        end

        function setVar(obj,var)
            obj.Var=var;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitVarExpr(obj,input);
        end
    end

end

