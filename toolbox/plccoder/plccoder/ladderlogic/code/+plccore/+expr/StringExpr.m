classdef StringExpr<plccore.expr.AbstractExpr




    properties(Access=protected)
String
    end

    methods
        function obj=StringExpr(str)
            obj.Kind='StringExpr';
            obj.String=str;
        end

        function ret=toString(obj)
            ret=sprintf('%s',obj.str);
        end

        function ret=str(obj)
            ret=obj.String;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitStringExpr(obj,input);
        end
    end
end

