


classdef(Sealed)RisingStep<sltest.assessments.Unary
    properties(SetAccess=immutable)
threshold
    end

    methods
        function self=RisingStep(expr,threshold)
            self@sltest.assessments.Unary(expr);
            self.threshold=threshold;
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal-self.expr.internal.epsilonShift(1.0)>=self.threshold,'RisingStep(',self.expr.internal,',',self.threshold,')');
        end
    end
end
