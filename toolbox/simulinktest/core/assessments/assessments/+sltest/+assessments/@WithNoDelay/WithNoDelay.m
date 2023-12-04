classdef(Sealed)WithNoDelay<sltest.assessments.Unary
    methods
        function self=WithNoDelay(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal,'with no delay, ',self.expr.internal);
        end
    end
end
