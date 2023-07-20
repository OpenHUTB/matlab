


classdef(Sealed)FallingEdge<sltest.assessments.Unary
    methods
        function self=FallingEdge(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(~self.expr.internal&self.expr.internal.epsilonShift(1.0),'FallingEdge(',self.expr.internal,')');
        end
    end
end

