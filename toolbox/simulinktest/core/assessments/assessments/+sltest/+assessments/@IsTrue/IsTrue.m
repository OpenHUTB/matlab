


classdef(Sealed)IsTrue<sltest.assessments.Unary
    methods
        function self=IsTrue(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal,self.expr.internal,' must be true');
        end
    end
end

