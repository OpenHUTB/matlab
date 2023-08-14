


classdef(Sealed)BecomesTrue<sltest.assessments.Unary
    methods
        function self=BecomesTrue(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            risingExpr=risingEdge(self.expr);
            internal=alias(risingExpr.internal,self.expr.internal,' becomes true');
        end
    end
end

