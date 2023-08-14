classdef IntegerBitRefExpr<plccore.expr.AbstractExpr




    properties(Access=protected)
IntegerExpr
BitIndex
    end

    methods
        function obj=IntegerBitRefExpr(integer_expr,bit_index)
            assert(isa(integer_expr,'plccore.expr.VarExpr')...
            ||isa(integer_expr,'plccore.expr.ArrayRefExpr')...
            ||isa(integer_expr,'plccore.expr.StructRefExpr'));
            assert(isa(bit_index,'double'));
            obj.Kind='IntegerBitRefExpr';
            obj.IntegerExpr=integer_expr;
            obj.BitIndex=bit_index;
        end

        function ret=toString(obj)
            ret=sprintf('%s.%d',obj.integerExpr.toString,obj.bitIndex);
        end

        function ret=integerExpr(obj)
            ret=obj.IntegerExpr;
        end

        function ret=bitIndex(obj)
            ret=obj.BitIndex;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitIntegerBitRefExpr(obj,input);
        end
    end

end


