classdef ArrayRefExpr<plccore.expr.AbstractExpr




    properties(Access=protected)
ArrayExpr
IndexExprList
    end

    methods
        function obj=ArrayRefExpr(array_expr,idx_expr_list)
            assert(isa(array_expr,'plccore.expr.VarExpr')...
            ||isa(array_expr,'plccore.expr.ArrayRefExpr')...
            ||isa(array_expr,'plccore.expr.StructRefExpr'));
            obj.Kind='ArrayRefExpr';
            obj.ArrayExpr=array_expr;
            obj.IndexExprList=idx_expr_list;
        end

        function ret=toString(obj)
            ret=sprintf('%s[',obj.ArrayExpr.toString);
            sz=length(obj.IndexExprList);
            for i=1:sz
                ret=sprintf('%s %s',ret,obj.IndexExprList{i}.toString);
                if i~=sz
                    ret=sprintf('%s,',ret);
                end
            end
            ret=sprintf('%s]',ret);
        end

        function ret=arrayExpr(obj)
            ret=obj.ArrayExpr;
        end

        function ret=getIndexCount(obj)
            ret=length(obj.IndexExprList);
        end

        function ret=indexExpr(obj,idx)
            assert(idx>=1&&idx<=length(obj.IndexExprList));
            ret=obj.IndexExprList{idx};
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitArrayRefExpr(obj,input);
        end
    end
end


