


classdef(Sealed)StrictlyIncreasing<sltest.assessments.Unary
    methods
        function self=StrictlyIncreasing(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.slope>0.0,'StrictlyIncreasing(',self.expr.internal,')');
        end
    end
end

