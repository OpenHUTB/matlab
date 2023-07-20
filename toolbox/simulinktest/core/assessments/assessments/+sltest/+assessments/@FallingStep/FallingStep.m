


classdef(Sealed)FallingStep<sltest.assessments.Unary
    properties(SetAccess=immutable)
threshold
    end

    methods
        function self=FallingStep(expr,threshold)
            self@sltest.assessments.Unary(expr);
            self.threshold=threshold;
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.epsilonShift(1.0)-self.expr.internal>=self.threshold,'FallingStep(',self.expr.internal,',',self.threshold,')');
        end
    end
end
