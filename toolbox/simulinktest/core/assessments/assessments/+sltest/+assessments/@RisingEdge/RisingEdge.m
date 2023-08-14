


classdef(Sealed)RisingEdge<sltest.assessments.Unary
    methods
        function self=RisingEdge(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal&epsilonShift(~self.expr.internal,1.0),'RisingEdge(',self.expr.internal,')');
        end
    end
end
