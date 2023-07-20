classdef ConstExpr<plccore.expr.AbstractExpr




    properties(Access=protected)
ConstVal
    end

    methods
        function obj=ConstExpr(const_val)
            obj.Kind='ConstExpr';
            obj.ConstVal=const_val;
        end

        function ret=toString(obj)
            ret=sprintf('%s',obj.ConstVal.toString);
        end

        function ret=value(obj)
            ret=obj.ConstVal;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitConstExpr(obj,input);
        end
    end
end

