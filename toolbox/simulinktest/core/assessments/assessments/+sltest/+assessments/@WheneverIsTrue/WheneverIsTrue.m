


classdef(Sealed)WheneverIsTrue<sltest.assessments.Unary
    methods
        function self=WheneverIsTrue(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal,self.expr.internal,' is true');
        end
    end
end
