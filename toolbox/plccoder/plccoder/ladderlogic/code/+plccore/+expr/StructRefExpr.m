classdef StructRefExpr<plccore.expr.AbstractExpr




    properties(Access=protected)
StructExpr
FieldName
    end

    methods
        function obj=StructRefExpr(struct_expr,field_name)
            assert(isa(struct_expr,'plccore.expr.VarExpr')...
            ||isa(struct_expr,'plccore.expr.ArrayRefExpr')...
            ||isa(struct_expr,'plccore.expr.StructRefExpr'));
            assert(isa(field_name,'char'));
            obj.Kind='StructRefExpr';
            obj.StructExpr=struct_expr;
            obj.FieldName=field_name;
        end

        function ret=toString(obj)
            ret=sprintf('%s.%s',obj.structExpr.toString,obj.fieldName);
        end

        function ret=structExpr(obj)
            ret=obj.StructExpr;
        end

        function ret=fieldName(obj)
            ret=obj.FieldName;
        end

        function ret=setFieldName(obj,field_name)
            obj.FieldName=field_name;
            ret=obj.FieldName;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitStructRefExpr(obj,input);
        end
    end

end


