classdef(Sealed)Abs<sltest.assessments.Unary
    methods
        function self=Abs(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.expr.internal.abs();
        end
    end
end
