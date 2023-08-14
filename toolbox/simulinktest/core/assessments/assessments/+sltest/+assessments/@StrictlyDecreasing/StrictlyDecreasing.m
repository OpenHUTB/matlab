


classdef(Sealed)StrictlyDecreasing<sltest.assessments.Unary
    methods
        function self=StrictlyDecreasing(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.slope<0.0,'StrictlyDecreasing(',self.expr.internal,')');
        end
    end
end

